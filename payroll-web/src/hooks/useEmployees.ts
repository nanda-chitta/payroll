import { useCallback, useEffect, useRef, useState } from 'react'
import { apiDelete, apiGet, apiPatch, apiPost } from '../api'
import { STARTUP_RETRY_DELAY_MS, shouldRetryDuringStartup } from './startupRetry'
import { errorMessage } from './useLookups'
import type { Employee, EmployeeFilters, EmployeeFormValues, PaginationMeta } from '../types/payroll'

export type EmployeePagination = {
  page: number
  pageSize: number
}

const initialMeta: PaginationMeta = {
  page: 1,
  perPage: 25,
  total: 0,
}

export function useEmployees(filters: EmployeeFilters, pagination: EmployeePagination) {
  const [employees, setEmployees] = useState<Employee[]>([])
  const [meta, setMeta] = useState<PaginationMeta>(initialMeta)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState('')
  const startupStartedAt = useRef(Date.now())
  const hasLoadedOnce = useRef(false)
  const retryTimeout = useRef<number | null>(null)

  const clearRetry = useCallback(() => {
    if (retryTimeout.current) {
      window.clearTimeout(retryTimeout.current)
      retryTimeout.current = null
    }
  }, [])

  const loadEmployees = useCallback(async () => {
    clearRetry()
    setIsLoading(true)

    if (hasLoadedOnce.current) setError('')

    let keepLoading = false

    try {
      const params = new URLSearchParams({
        limit: pagination.pageSize.toString(),
        page: (pagination.page + 1).toString(),
      })
      if (filters.country) params.set('country', filters.country)
      if (filters.jobTitleId) params.set('jobTitleId', filters.jobTitleId)
      if (filters.query.trim()) params.set('query', filters.query.trim())
      if (filters.activeOnly) params.set('status', 'active')

      const data = await apiGet<{ employees: Employee[]; meta: PaginationMeta }>(`/employees?${params}`)
      setEmployees(data.employees)
      setMeta(data.meta)
      hasLoadedOnce.current = true
      startupStartedAt.current = Date.now()
      setError('')
    } catch (requestError) {
      if (isNotFound(requestError)) {
        setEmployees([])
        setMeta({ page: pagination.page + 1, perPage: pagination.pageSize, total: 0 })
        setError('')
        hasLoadedOnce.current = true
        return
      }

      if (!hasLoadedOnce.current && shouldRetryDuringStartup(startupStartedAt.current, requestError)) {
        keepLoading = true
        retryTimeout.current = window.setTimeout(() => {
          void loadEmployees()
        }, STARTUP_RETRY_DELAY_MS)
        return
      }

      setError(errorMessage(requestError))
    } finally {
      if (!keepLoading) setIsLoading(false)
    }
  }, [clearRetry, filters.activeOnly, filters.country, filters.jobTitleId, filters.query, pagination.page, pagination.pageSize])

  useEffect(() => {
    loadEmployees()
    return clearRetry
  }, [clearRetry, loadEmployees])

  const saveEmployee = useCallback(async (form: EmployeeFormValues) => {
    const payload = { employee: formPayload(form) }

    if (form.id) {
      await apiPatch(`/employees/${form.id}`, payload)
    } else {
      await apiPost('/employees', payload)
    }
  }, [])

  const deleteEmployee = useCallback(async (employee: Employee) => {
    await apiDelete(`/employees/${employee.id}`)
  }, [])

  return { employees, meta, isLoading, error, reload: loadEmployees, saveEmployee, deleteEmployee }
}

function isNotFound(error: unknown) {
  if (typeof error !== 'object' || !error) return false

  const requestError = error as { message?: unknown; status?: unknown }
  const message = typeof requestError.message === 'string' ? requestError.message.toLowerCase() : ''

  return requestError.status === 404 || message === 'not found' || message === 'record not found'
}

function formPayload(form: EmployeeFormValues) {
  return {
    ...form,
    departmentId: Number(form.departmentId),
    jobTitleId: Number(form.jobTitleId),
    salaryAmount: Number(form.salaryAmount),
  }
}

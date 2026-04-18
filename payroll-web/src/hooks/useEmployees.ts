import { useCallback, useEffect, useState } from 'react'
import { apiGet, apiRequest } from './useApi'
import { errorMessage } from './useLookups'
import type { Employee, EmployeeFilters, EmployeeFormValues } from '../types/payroll'

export function useEmployees(filters: EmployeeFilters) {
  const [employees, setEmployees] = useState<Employee[]>([])
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState('')

  const loadEmployees = useCallback(async () => {
    setIsLoading(true)
    setError('')

    try {
      const params = new URLSearchParams({ limit: '25' })
      if (filters.country) params.set('country', filters.country)
      if (filters.jobTitleId) params.set('job_title_id', filters.jobTitleId)
      if (filters.query.trim()) params.set('query', filters.query.trim())

      const data = await apiGet<{ employees: Employee[] }>(`/api/v1/employees?${params}`)
      setEmployees(data.employees)
    } catch (requestError) {
      setError(errorMessage(requestError))
    } finally {
      setIsLoading(false)
    }
  }, [filters.country, filters.jobTitleId, filters.query])

  useEffect(() => {
    loadEmployees()
  }, [loadEmployees])

  const saveEmployee = useCallback(async (form: EmployeeFormValues) => {
    const path = form.id ? `/api/v1/employees/${form.id}` : '/api/v1/employees'
    const method = form.id ? 'PATCH' : 'POST'

    await apiRequest(path, {
      method,
      body: JSON.stringify({ employee: formPayload(form) }),
    })
  }, [])

  const deleteEmployee = useCallback(async (employee: Employee) => {
    await apiRequest(`/api/v1/employees/${employee.id}`, { method: 'DELETE' })
  }, [])

  return { employees, isLoading, error, reload: loadEmployees, saveEmployee, deleteEmployee }
}

function formPayload(form: EmployeeFormValues) {
  return {
    ...form,
    department_id: Number(form.department_id),
    job_title_id: Number(form.job_title_id),
    salary_amount: Number(form.salary_amount),
  }
}

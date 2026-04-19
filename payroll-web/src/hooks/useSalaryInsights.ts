import { useCallback, useEffect, useRef, useState } from 'react'
import { apiGet } from '../api'
import { STARTUP_RETRY_DELAY_MS, shouldRetryDuringStartup } from './startupRetry'
import { errorMessage } from './useLookups'
import type { EmployeeFilters, SalaryInsights } from '../types/payroll'

export function useSalaryInsights(filters: Pick<EmployeeFilters, 'country' | 'jobTitleId'>) {
  const [insights, setInsights] = useState<SalaryInsights | null>(null)
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

  const loadInsights = useCallback(async () => {
    clearRetry()
    setIsLoading(true)

    if (hasLoadedOnce.current) setError('')

    let keepLoading = false

    try {
      const params = new URLSearchParams()
      if (filters.country) params.set('country', filters.country)
      if (filters.jobTitleId) params.set('jobTitleId', filters.jobTitleId)

      setInsights(await apiGet<SalaryInsights>(`/salary_insights?${params}`))
      hasLoadedOnce.current = true
      startupStartedAt.current = Date.now()
      setError('')
    } catch (requestError) {
      if (isNotFound(requestError)) {
        setInsights(null)
        setError('')
        hasLoadedOnce.current = true
        return
      }

      if (!hasLoadedOnce.current && shouldRetryDuringStartup(startupStartedAt.current, requestError)) {
        keepLoading = true
        retryTimeout.current = window.setTimeout(() => {
          void loadInsights()
        }, STARTUP_RETRY_DELAY_MS)
        return
      }

      setError(errorMessage(requestError))
    } finally {
      if (!keepLoading) setIsLoading(false)
    }
  }, [clearRetry, filters.country, filters.jobTitleId])

  useEffect(() => {
    loadInsights()
    return clearRetry
  }, [clearRetry, loadInsights])

  return { insights, isLoading, error, reload: loadInsights }
}

function isNotFound(error: unknown) {
  if (typeof error !== 'object' || !error) return false

  const requestError = error as { message?: unknown; status?: unknown }
  const message = typeof requestError.message === 'string' ? requestError.message.toLowerCase() : ''

  return requestError.status === 404 || message === 'not found' || message === 'record not found'
}

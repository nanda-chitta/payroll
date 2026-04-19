import { useCallback, useEffect, useState } from 'react'
import { apiGet } from '../api'
import { errorMessage } from './useLookups'
import type { EmployeeFilters, SalaryInsights } from '../types/payroll'

export function useSalaryInsights(filters: Pick<EmployeeFilters, 'country' | 'jobTitleId'>) {
  const [insights, setInsights] = useState<SalaryInsights | null>(null)
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState('')

  const loadInsights = useCallback(async () => {
    setIsLoading(true)
    setError('')

    try {
      const params = new URLSearchParams()
      if (filters.country) params.set('country', filters.country)
      if (filters.jobTitleId) params.set('jobTitleId', filters.jobTitleId)

      setInsights(await apiGet<SalaryInsights>(`/salary_insights?${params}`))
    } catch (requestError) {
      setError(errorMessage(requestError))
    } finally {
      setIsLoading(false)
    }
  }, [filters.country, filters.jobTitleId])

  useEffect(() => {
    loadInsights()
  }, [loadInsights])

  return { insights, isLoading, error, reload: loadInsights }
}

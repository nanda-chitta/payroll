import { useCallback, useEffect, useState } from 'react'
import { apiGet } from './useApi'
import type { Lookups } from '../types/payroll'

export const emptyLookups: Lookups = {
  departments: [],
  job_titles: [],
  countries: [],
  employment_types: [],
  statuses: [],
  pay_frequencies: [],
}

export function useLookups() {
  const [lookups, setLookups] = useState<Lookups>(emptyLookups)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState('')

  const loadLookups = useCallback(async () => {
    setIsLoading(true)
    setError('')

    try {
      setLookups(await apiGet<Lookups>('/api/v1/lookups'))
    } catch (requestError) {
      setError(errorMessage(requestError))
    } finally {
      setIsLoading(false)
    }
  }, [])

  useEffect(() => {
    loadLookups()
  }, [loadLookups])

  return { lookups, isLoading, error, reload: loadLookups }
}

export function errorMessage(error: unknown) {
  return error instanceof Error ? error.message : 'Something went wrong'
}

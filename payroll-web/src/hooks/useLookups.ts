import { useCallback, useEffect, useState } from 'react'
import { apiGet } from '../api'
import type { Lookups } from '../types/payroll'

export const emptyLookups: Lookups = {
  departments: [],
  jobTitles: [],
  countries: [],
  employmentTypes: [],
  statuses: [],
  payFrequencies: [],
}

export function useLookups() {
  const [lookups, setLookups] = useState<Lookups>(emptyLookups)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState('')

  const loadLookups = useCallback(async () => {
    setIsLoading(true)
    setError('')

    try {
      setLookups(await apiGet<Lookups>('/lookups'))
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
  return error instanceof Error || (typeof error === 'object' && error && 'message' in error)
    ? String((error as { message: unknown }).message)
    : 'Something went wrong'
}

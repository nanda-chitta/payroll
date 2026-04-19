import { useCallback, useEffect, useRef, useState } from 'react'
import { apiGet } from '../api'
import { STARTUP_RETRY_DELAY_MS, shouldRetryDuringStartup } from './startupRetry'
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
  const startupStartedAt = useRef(Date.now())
  const hasLoadedOnce = useRef(false)
  const retryTimeout = useRef<number | null>(null)

  const clearRetry = useCallback(() => {
    if (retryTimeout.current) {
      window.clearTimeout(retryTimeout.current)
      retryTimeout.current = null
    }
  }, [])

  const loadLookups = useCallback(async () => {
    clearRetry()
    setIsLoading(true)

    if (hasLoadedOnce.current) setError('')

    let keepLoading = false

    try {
      setLookups(await apiGet<Lookups>('/lookups'))
      hasLoadedOnce.current = true
      startupStartedAt.current = Date.now()
      setError('')
    } catch (requestError) {
      if (!hasLoadedOnce.current && shouldRetryDuringStartup(startupStartedAt.current, requestError)) {
        keepLoading = true
        retryTimeout.current = window.setTimeout(() => {
          void loadLookups()
        }, STARTUP_RETRY_DELAY_MS)
        return
      }

      setError(errorMessage(requestError))
    } finally {
      if (!keepLoading) setIsLoading(false)
    }
  }, [clearRetry])

  useEffect(() => {
    loadLookups()
    return clearRetry
  }, [clearRetry, loadLookups])

  return { lookups, isLoading, error, reload: loadLookups }
}

export function errorMessage(error: unknown) {
  return error instanceof Error || (typeof error === 'object' && error && 'message' in error)
    ? String((error as { message: unknown }).message)
    : 'Something went wrong'
}

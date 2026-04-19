const STARTUP_GRACE_PERIOD_MS = 15_000
export const STARTUP_RETRY_DELAY_MS = 1_500

export function shouldRetryDuringStartup(startedAt: number, error: unknown) {
  return Date.now() - startedAt < STARTUP_GRACE_PERIOD_MS && isStartupError(error)
}

function isStartupError(error: unknown) {
  if (typeof error !== 'object' || !error) return false

  const requestError = error as { message?: unknown; status?: unknown }
  const message = typeof requestError.message === 'string' ? requestError.message.toLowerCase() : ''

  return (
    requestError.status === 0 ||
    requestError.status === 502 ||
    requestError.status === 503 ||
    requestError.status === 504 ||
    message.includes('network error') ||
    message.includes('bad gateway') ||
    message.includes('failed to fetch') ||
    message.includes('gateway timeout') ||
    message.includes('request failed (502)') ||
    message.includes('request failed (503)') ||
    message.includes('request failed (504)')
  )
}

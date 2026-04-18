const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:3000'

export async function apiGet<T>(path: string): Promise<T> {
  const response = await apiRequest(path)
  return response.json()
}

export async function apiRequest(path: string, options: RequestInit = {}) {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    headers: {
      Accept: 'application/json',
      'Content-Type': 'application/json',
      ...options.headers,
    },
    ...options,
  })

  if (!response.ok) {
    const body = await response.json().catch(() => null)
    throw new Error(body?.error ?? formatErrors(body?.errors) ?? 'Request failed')
  }

  return response
}

function formatErrors(errors: Record<string, string[]> | undefined) {
  if (!errors) return null

  return Object.entries(errors)
    .map(([field, messages]) => `${field} ${messages.join(', ')}`)
    .join('; ')
}

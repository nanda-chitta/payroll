export function money(value: string | null | undefined) {
  if (!value) return '$0'

  return Number(value).toLocaleString('en-US', {
    currency: 'USD',
    maximumFractionDigits: 0,
    style: 'currency',
  })
}

export function formatErrors(
    errors: Record<string, string[]> | undefined
): string | null {
    if (!errors) return null

    return Object.entries(errors)
        .map(([field, messages]) => `${field} ${messages.join(', ')}`)
        .join('; ')
}

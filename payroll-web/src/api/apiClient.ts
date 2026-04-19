import axios from 'axios'
import type { AxiosError, AxiosInstance } from 'axios'
import camelcaseKeys from 'camelcase-keys'
import { formatErrors } from './apiUtils'

type ApiErrorPayload = {
    errorMsg?: string
    error?: string | { message?: string }
    errors?: Record<string, string[]>
}

function normalizeBaseUrl(baseUrl?: string) {
    if (!baseUrl) return ''

    return baseUrl.endsWith('/') ? baseUrl.slice(0, -1) : baseUrl
}

const API_BASE_URL = normalizeBaseUrl(import.meta.env.VITE_API_BASE_URL)
const API_ROOT = API_BASE_URL ? `${API_BASE_URL}/api/v1` : '/api/v1'

const api: AxiosInstance = axios.create({
    baseURL: API_ROOT,
    headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
    },
})

api.interceptors.response.use(
    (response) => {
        let data = response.data

        if (data && typeof data === 'object' && 'data' in data) {
            data = data.data
        }

        response.data =
            data && typeof data === 'object'
                ? camelcaseKeys(data, { deep: true })
                : data

        return response
    },
    (error: AxiosError) => {
        if (error.response) {
            const data = error.response.data as ApiErrorPayload

            return Promise.reject({
                message:
                    data?.errorMsg ||
                    errorText(data?.error) ||
                    (typeof data?.error === 'string' ? data.error : null) ||
                    responseText(error.response.data) ||
                    error.response.statusText ||
                    formatErrors(data?.errors) ||
                    `Request failed (${error.response.status})`,
                status: error.response.status,
                errors: data?.errors ?? null,
            })
        }

        return Promise.reject({
            message: 'Network error',
            status: 0,
        })
    }
)

function errorText(error: ApiErrorPayload['error']) {
    if (!error || typeof error === 'string') return null

    return error.message ?? null
}

function responseText(data: unknown) {
    if (typeof data !== 'string') return null

    const text = data.trim()
    if (!text) return null
    if (text.startsWith('<!DOCTYPE html') || text.startsWith('<html')) return null

    return text
}

export default api

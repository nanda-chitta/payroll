import type { AxiosRequestConfig } from 'axios'
import api from './apiClient'

export async function apiGet<T>(
    path: string,
    config?: AxiosRequestConfig
): Promise<T> {
    const res = await api.get<T>(path, config)
    return res.data
}

export async function apiPost<T>(
    path: string,
    payload?: unknown,
    config?: AxiosRequestConfig
): Promise<T> {
    const res = await api.post<T>(path, payload, config)
    return res.data
}

export async function apiPatch<T>(
    path: string,
    payload?: unknown,
    config?: AxiosRequestConfig
): Promise<T> {
    const res = await api.patch<T>(path, payload, config)
    return res.data
}

export async function apiDelete<T>(
    path: string,
    config?: AxiosRequestConfig
): Promise<T> {
    const res = await api.delete<T>(path, config)
    return res.data
}
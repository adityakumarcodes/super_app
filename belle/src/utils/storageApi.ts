import { useQuery } from '@tanstack/react-query'

import { NOTES_API_BASE } from './notesApi'

export type UploadResult = {
    path: string
    url: string
}

export type SignedUrlResult = {
    url: string
    expiresIn: number
}

// Signed URLs are valid for one hour on the backend; refresh a little early.
export const SIGNED_URL_STALE_TIME = 50 * 60 * 1000

export function isStoragePath(value?: string | null): value is string {
    return Boolean(value) && !/^(?:https?:|data:|blob:|\/)/i.test(value!) && value!.includes('/')
}

async function readError(response: Response, fallback: string) {
    const body = await response.json().catch(() => undefined)

    if (!body || typeof body !== 'object' || !('message' in body)) {
        return fallback
    }

    const { message } = body as { message?: unknown }
    return Array.isArray(message) ? message.join(' ') : typeof message === 'string' ? message : fallback
}

export async function uploadImage(file: File): Promise<UploadResult> {
    const formData = new FormData()
    formData.append('file', file)

    const response = await fetch(`${NOTES_API_BASE}/storage/upload`, {
        method: 'POST',
        credentials: 'include',
        body: formData,
    })

    if (!response.ok) {
        throw new Error(await readError(response, `Image upload failed (${response.status})`))
    }

    const result = await response.json() as UploadResult
    if (!result.path) {
        throw new Error('The upload response did not include a storage path.')
    }

    return result
}

export async function fetchSignedUrl(path: string): Promise<SignedUrlResult> {
    const response = await fetch(
        `${NOTES_API_BASE}/storage/url?path=${encodeURIComponent(path)}`,
        { credentials: 'include' },
    )

    if (!response.ok) {
        throw new Error(await readError(response, `Could not load image (${response.status})`))
    }

    return response.json() as Promise<SignedUrlResult>
}

export async function fetchSignedUrls(paths: string[]) {
    const entries = await Promise.all(
        paths.map(async (path) => {
            const { url } = await fetchSignedUrl(path)
            return [path, url] as const
        }),
    )

    return Object.fromEntries(entries) as Record<string, string>
}

export function signedUrlQuery(paths: string[]) {
    return {
        queryKey: ['storage-signed-urls', paths],
        queryFn: () => fetchSignedUrls(paths),
        staleTime: SIGNED_URL_STALE_TIME,
    }
}

/**
 * Resolves a stored value to a display URL.
 * Already-hosted URLs (http, data, blob, absolute paths) are returned untouched.
 */
export function useSignedUrl(value?: string | null): string | null {
    const path = isStoragePath(value) ? value : null
    const { data } = useQuery({
        queryKey: ['storage-signed-urls', [path]],
        queryFn: () => fetchSignedUrls([path!]),
        enabled: Boolean(path),
        staleTime: SIGNED_URL_STALE_TIME,
    })

    if (!path) return value ?? null
    return data?.[path] ?? null
}

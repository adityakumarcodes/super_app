
import type { Note, NoteWriteInput } from './notes'

export const NOTES_API_BASE = ((import.meta.env.VITE_API_BASE as string) || 'http://localhost:3000/api').replace(/\/$/, '')

function getErrorMessage(body: unknown, fallback: string) {
    if (!body || typeof body !== 'object' || !('message' in body)) return fallback

    const { message } = body as { message?: unknown }
    return Array.isArray(message) ? message.join(' ') : typeof message === 'string' ? message : fallback
}

async function request<T>(path: string, init: RequestInit = {}): Promise<T> {
    const headers = new Headers(init.headers)
    if (init.body) headers.set('Content-Type', 'application/json')

    const response = await fetch(`${NOTES_API_BASE}${path}`, {
        ...init,
        credentials: 'include',
        headers,
    })

    if (!response.ok) {
        const body = await response.json().catch(() => undefined)
        throw new Error(getErrorMessage(body, `Request failed (${response.status})`))
    }

    if (response.status === 204) return undefined as T
    return response.json() as Promise<T>
}

export function createNote(note: NoteWriteInput) {
    return request<Note>('/notes', {
        method: 'POST',
        body: JSON.stringify(note),
    })
}

export function updateNote(id: string | number, note: NoteWriteInput) {
    return request<Note>(`/notes/${encodeURIComponent(String(id))}`, {
        method: 'PATCH',
        body: JSON.stringify(note),
    })
}

export function deleteNote(id: string | number) {
    return request<void>(`/notes/${encodeURIComponent(String(id))}`, {
        method: 'DELETE',
    })
}

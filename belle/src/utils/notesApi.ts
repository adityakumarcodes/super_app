
import type { Note, NoteWriteInput } from './notes'

export const NOTES_API_BASE = (import.meta.env.VITE_BACKEND_API as string)

function getErrorMessage(body: unknown, fallback: string) {
    if (!body || typeof body !== 'object' || !('message' in body)) return fallback

    const { message } = body as { message?: unknown }
    return Array.isArray(message) ? message.join(' ') : typeof message === 'string' ? message : fallback
}

async function request<T>(path: string, init: RequestInit = {}): Promise<T> {
    const headers = new Headers(init.headers)
    if (init.body && !(init.body instanceof FormData)) headers.set('Content-Type', 'application/json')

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

export function updateNote(id: string | number, note: NoteWriteInput, coverFile?: File | null) {
    if (coverFile) {
        const formData = new FormData()
        formData.append('cover', coverFile)
        formData.append('title', note.title ?? '')
        formData.append('blocks', JSON.stringify(note.blocks ?? []))
        return request<Note>(`/notes/${encodeURIComponent(String(id))}`, {
            method: 'PATCH',
            body: formData,
        })
    }

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

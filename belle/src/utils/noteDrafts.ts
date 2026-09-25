import type { OutputData } from '@editorjs/editorjs'

export type NoteBlock = {
    id: number | string
    blockKey?: string | null
    type: string
    data: Record<string, unknown>
}

export type Note = {
    id: number | string
    title?: string | null
    description?: string | null
    imageUrl?: string | null
    blocks?: NoteBlock[]
    editorVersion?: string | null
    createdAt?: string
    updatedAt?: string
    isLocal?: boolean
}

const draftsKey = 'belle-note-drafts'
const overridesKey = 'belle-note-overrides'

function readNotes(key: string): Note[] {
    try {
        const value = localStorage.getItem(key)
        return value ? JSON.parse(value) as Note[] : []
    } catch {
        return []
    }
}

function writeNotes(key: string, notes: Note[]) {
    localStorage.setItem(key, JSON.stringify(notes))
}

export function getDrafts() {
    return readNotes(draftsKey)
}

export function getOverride(id: string) {
    return readNotes(overridesKey).find((note) => String(note.id) === id)
}

export function getOverrides() {
    return readNotes(overridesKey)
}

export function saveNote(note: Note) {
    const key = note.isLocal ? draftsKey : overridesKey
    const notes = readNotes(key)
    const next = notes.filter((entry) => String(entry.id) !== String(note.id))
    writeNotes(key, [{ ...note, updatedAt: new Date().toISOString() }, ...next])
}

export function deleteLocalNote(id: string) {
    writeNotes(draftsKey, getDrafts().filter((note) => String(note.id) !== id))
    writeNotes(overridesKey, readNotes(overridesKey).filter((note) => String(note.id) !== id))
}

export function editorDataToBlocks(data: OutputData): NoteBlock[] {
    return data.blocks.map((block, index) => ({
        id: block.id ?? `local-block-${index}`,
        blockKey: block.id,
        type: block.type,
        data: block.data as Record<string, unknown>,
    }))
}
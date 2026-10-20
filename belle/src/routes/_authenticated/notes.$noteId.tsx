import { createFileRoute, Link, useNavigate } from '@tanstack/react-router'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { ArrowLeft, Check, Pencil, Trash2, X } from 'lucide-react'
import { useMemo, useRef, useState } from 'react'
import NoteDetails, { type NoteDetailsHandle } from '../../components/NoteDetails'
import NoteCoverImage from '../../components/NoteCoverImage'
import useFetchQuery from '../../utils/useFetchQuery'
import Spinner from '../../components/Spinner'
import { deleteNote, NOTES_API_BASE, updateNote } from '../../utils/notesApi'
import { editorDataToBlocks, type Note, type NoteWriteInput } from '../../utils/notes'

export const Route = createFileRoute('/_authenticated/notes/$noteId')({
  component: RouteComponent,
})

function RouteComponent() {
  const { noteId } = Route.useParams()
  const navigate = useNavigate()
  const [isEditing, setIsEditing] = useState(false)
  const [isDeleteOpen, setIsDeleteOpen] = useState(false)
  const [notice, setNotice] = useState<string | null>(null)
  const [saveError, setSaveError] = useState<string | null>(null)
  const [draftTitle, setDraftTitle] = useState('')
  const [coverFile, setCoverFile] = useState<File | null>(null)
  const coverInputRef = useRef<HTMLInputElement | null>(null)
  const noteDetailsRef = useRef<NoteDetailsHandle | null>(null)
  const queryClient = useQueryClient()
  const { data: note, isLoading, isError, error, refetch } = useFetchQuery<Note>({ queryKey: ['note', noteId], queryLink: `${NOTES_API_BASE}/notes/${noteId}`, queryOptions: { enabled: !!noteId } })
  const updateMutation = useMutation({ mutationFn: ({ note, cover }: { note: NoteWriteInput; cover: File | null }) => updateNote(noteId, note, cover) })
  const deleteMutation = useMutation({ mutationFn: () => deleteNote(noteId) })

  const editorData = useMemo(() => ({
    time: note?.updatedAt ? new Date(note.updatedAt).getTime() : 0,
    blocks: (note?.blocks ?? []).map((block) => ({
      id: block.blockKey ?? String(block.id),
      type: block.type,
      data: block.data,
    })),
  }), [note?.blocks, note?.id, note?.updatedAt])

  if (isLoading) return <Spinner />

  if (isError) {
    return <div className='p-8 text-center'>
      <h1 className='text-3xl'>This note could not load</h1>
      <p className='mt-2 text-secondary'>{error instanceof Error ? error.message : 'Please check your connection and try again.'}</p>
      <button type='button' onClick={() => void refetch()} className='theme-accent-bg control-pill mt-5 border border-strong px-5 py-2.5'>Try again</button>
    </div>
  }

  if (!note) {
    return <div className='p-8'>Note not found.</div>
  }

  const beginEditing = () => {
    setDraftTitle(note.title ?? '')
    setCoverFile(null)
    setSaveError(null)
    setNotice(null)
    setIsEditing(true)
  }

  const cancelEditing = () => {
    setIsEditing(false)
    setSaveError(null)
  }

  const saveNote = async () => {
    setSaveError(null)

    try {
      const output = await noteDetailsRef.current?.save()
      if (!output) {
        throw new Error('The note editor is still loading. Please try again.')
      }

      await updateMutation.mutateAsync({
        note: {
          title: draftTitle.trim() || 'Untitled note',
          imageUrl: note.imageUrl ?? null,
          blocks: editorDataToBlocks(output),
          }, cover: coverFile
      })
      setIsEditing(false)
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: ['notes'] }),
        queryClient.invalidateQueries({ queryKey: ['note', noteId] }),
      ])
      setNotice('Note saved.')
    } catch (saveError) {
      setSaveError(saveError instanceof Error ? saveError.message : 'The note could not be saved. Please try again.')
    }
  }

  const removeNote = async () => {
    await deleteMutation.mutateAsync()
    queryClient.removeQueries({ queryKey: ['note', noteId] })
    await queryClient.invalidateQueries({ queryKey: ['notes'] })
    await navigate({ to: '/notes' })
  }

  return (
    <div className='flex min-h-screen flex-col overflow-y-auto'>
      <div className="mx-auto w-full max-w-5xl px-4 py-10 md:px-8">
        <header className="mb-12">
          <div className="mb-8 flex items-center justify-between gap-3">
            <Link to="/notes" className="control-pill inline-flex items-center gap-2 border border-strong px-4 py-2 hover-surface-card"><ArrowLeft size={18} />Back</Link>
            <div className="flex gap-2">
              {isEditing ? <>
                <button type="button" disabled={updateMutation.isPending} onClick={cancelEditing} className="control-pill border border-strong px-4 py-2 hover-surface-card disabled:opacity-70">Cancel</button>
                <button type="button" disabled={updateMutation.isPending} onClick={() => void saveNote()} className="theme-accent-bg control-pill inline-flex items-center gap-2 border border-strong px-4 py-2 disabled:cursor-wait disabled:opacity-70"><Check size={17} />{updateMutation.isPending ? 'Saving…' : 'Save'}</button>
              </> : <>
                <button type="button" onClick={beginEditing} className="control-pill inline-flex items-center gap-2 border border-strong px-4 py-2 hover-surface-card"><Pencil size={17} />Edit</button>
                <button type="button" onClick={() => setIsDeleteOpen(true)} className="control-pill inline-flex items-center gap-2 border border-strong px-4 py-2 text-red-700 hover:bg-red-50" aria-label="Delete note"><Trash2 size={17} /></button>
              </>}
            </div>
          </div>
          {notice && <div className="theme-accent-soft mb-6 flex items-center justify-between rounded-xl border border-strong px-4 py-3 text-sm"><span>{notice}</span><button type="button" onClick={() => setNotice(null)} aria-label="Dismiss message"><X size={16} /></button></div>}
          {saveError && <p className="mb-6 text-sm text-red-700" role="alert">{saveError}</p>}
          <div className="max-w-4xl">
            {isEditing ? <>
              <input value={draftTitle} onChange={(event) => setDraftTitle(event.target.value)} placeholder="Untitled" aria-label="Note title" className="w-full bg-transparent font-bodoni text-5xl leading-tight tracking-tight outline-none placeholder:text-stone-400 md:text-7xl" />
              <input ref={coverInputRef} type="file" accept="image/*" className="hidden" onChange={(event) => setCoverFile(event.target.files?.[0] ?? null)} />
              {coverFile && <p className="mt-2 text-sm text-secondary">{coverFile.name}</p>}
            </> : <>
              <h1 className="font-bodoni text-5xl leading-tight tracking-tight md:text-7xl">
                {note.title || "Untitled note"}
              </h1>

            </>}
          </div>

          {note.imageUrl && (
            <div className="group relative mt-8 overflow-hidden rounded-4xl">
              <NoteCoverImage
                value={note.imageUrl}
                alt={note.title || "Note cover"}
                className="h-75 w-full object-cover transition-transform duration-700 ease-out group-hover:scale-105 md:h-112.5" />
              {isEditing && (
                <button type="button" onClick={() => coverInputRef.current?.click()} className="absolute right-3 top-3 control-pill border border-strong bg-white/90 px-3 py-2 text-sm">Update cover</button>
              )}
            </div>
          )}
        </header>

        <main className="mx-auto max-w-4xl">
          <NoteDetails ref={noteDetailsRef} data={editorData} editable={isEditing} />
        </main>
      </div>
      {isDeleteOpen && <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/30 p-5 backdrop-blur-sm" role="dialog" aria-modal="true" aria-label="Delete note">
        <div className="surface-body w-full max-w-md p-6 shadow-2xl">
          <div className="flex items-start justify-between"><div><p className="text-sm text-secondary">This cannot be undone</p><h2 className="mt-1 text-3xl">Delete this note?</h2></div><button type="button" onClick={() => setIsDeleteOpen(false)} aria-label="Close confirmation"><X /></button></div>
          <p className="mt-3 text-secondary">This note will be permanently deleted.</p>
          {deleteMutation.isError && <p className="mt-3 text-sm text-red-700" role="alert">{deleteMutation.error instanceof Error ? deleteMutation.error.message : 'The note could not be deleted. Please try again.'}</p>}
          <div className="mt-6 flex justify-end gap-3"><button type="button" onClick={() => setIsDeleteOpen(false)} className="control-pill border border-strong px-4 py-2">Keep note</button><button type="button" disabled={deleteMutation.isPending} onClick={() => void removeNote()} className="control-pill border border-red-800 bg-red-700 px-4 py-2 text-white disabled:cursor-wait disabled:opacity-70">{deleteMutation.isPending ? 'Deleting…' : 'Delete'}</button></div>
        </div>
      </div>}
    </div>
  )
}

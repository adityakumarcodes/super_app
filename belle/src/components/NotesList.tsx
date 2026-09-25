
import { Link } from "@tanstack/react-router";
import { FileText, Plus, Search, X } from "lucide-react";
import { useMemo, useState } from "react";
import useFetchQuery from '../utils/useFetchQuery'
import NotesActionFab from './NotesActionFab';
import NoteComposerModal from './NoteCompose';
import Spinner from "./Spinner";
import { getDrafts, getOverrides, saveNote, type Note } from '../utils/noteDrafts';

const images = import.meta.glob(
    "../assets/images/notes/*.{jpg,jpeg,jfif,png}",
    {
        eager: true,
        import: "default",
    },
) as Record<string, string>;

const getNoteImage = (note: Note) => {
    if (!note.imageUrl) return undefined;

    // Handle remote images not hosted locally
    if (!note.imageUrl.includes('localhost')) {
        return note.imageUrl;
    }

    // Handle local images
    const imageName = note.imageUrl.split('/').pop();
    return imageName ? images[`../assets/images/notes/${imageName}`] : undefined;
};

export default function NotesList() {
    const [filter, setFilter] = useState<'All' | 'Recent' | 'With cover' | 'Text only'>('All');
    const [search, setSearch] = useState('');
    const [drafts, setDrafts] = useState<Note[]>(getDrafts);
    const [isComposerOpen, setIsComposerOpen] = useState(false);
    const [notice, setNotice] = useState<string | null>(null);
    const BASE = (import.meta.env.VITE_API_BASE as string) || 'http://localhost:3000/api'
    const { data: pages = [], isLoading, isError, error, refetch } = useFetchQuery<Note[]>({ queryKey: ['notes'], queryLink: `${BASE}/notes` })

    const notes = useMemo(() => {
        const overrides = getOverrides()
        const serverNotes = pages.map((page) => {
            const override = overrides.find((entry) => String(entry.id) === String(page.id))
            return override ? { ...page, ...override, blocks: override.blocks ?? page.blocks } : page
        })
        const merged = [...drafts, ...serverNotes.filter((page) => !drafts.some((draft) => String(draft.id) === String(page.id)))]
        const query = search.trim().toLowerCase()
        return merged.filter((note) => {
            const matchesSearch = !query || `${note.title ?? ''} ${note.description ?? ''}`.toLowerCase().includes(query)
            const matchesFilter = filter === 'All' || (filter === 'With cover' && Boolean(note.imageUrl)) || (filter === 'Text only' && !note.imageUrl) || (filter === 'Recent' && Boolean(note.updatedAt ?? note.createdAt))
            return matchesSearch && matchesFilter
        })
    }, [drafts, filter, pages, search])

    if (isLoading && drafts.length === 0) return <Spinner />;

    const saveLocalNote = (note: Note) => {
        saveNote(note)
        setDrafts(getDrafts())
        setIsComposerOpen(false)
        setNotice('Saved in this browser. It will sync once note write endpoints are connected.')
    }

    return (<>
        <div className="mx-auto mb-8 max-w-6xl">

            <label className="surface-raised flex flex-1 items-center gap-2 rounded-xl px-3 py-2" htmlFor="note-search">
                <Search size={18} className="text-secondary" />
                <input id="note-search" value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search notes" className="w-full bg-transparent outline-none" />
                {search && <button type="button" onClick={() => setSearch('')} aria-label="Clear search"><X size={16} /></button>}
            </label>

        </div>
        <div className="mb-8 flex flex-wrap justify-center gap-3">
            {(['All', 'Recent', 'With cover', 'Text only'] as const).map((item) => (
                <button
                    key={item}
                    onClick={() => setFilter(item)}
                    className={filter === item ? 'theme-accent-bg control-pill border border-strong px-4 py-2' : 'control-pill border border-strong px-4 py-2 hover-surface-card'}
                >
                    {item}
                </button>
            ))}
        </div>
        {notice && <div className="theme-accent-soft mx-auto mb-5 flex max-w-4xl items-center justify-between rounded-xl border border-strong px-4 py-3 text-sm"><span>{notice}</span><button type="button" onClick={() => setNotice(null)} aria-label="Dismiss message"><X size={16} /></button></div>}
        {isError ? (
            <div className="surface-card mx-auto max-w-xl p-8 text-center">
                <h2 className="text-3xl">Your notes could not load</h2>
                <p className="mt-2 text-secondary">{error instanceof Error ? error.message : 'Please check your connection and try again.'}</p>
                <button type="button" onClick={() => void refetch()} className="theme-accent-bg control-pill mt-5 border border-strong px-5 py-2.5">Try again</button>
            </div>
        ) : notes.length === 0 ? (
            <div className="surface-card mx-auto max-w-xl p-10 text-center">
                <FileText className="mx-auto" size={34} />
                <h2 className="mt-4 text-3xl">No notes found</h2>
                <p className="mt-2 text-secondary">{search ? 'Try a different search term or filter.' : 'Capture your first thought and make it easy to return to.'}</p>
                {!search && <button type="button" onClick={() => setIsComposerOpen(true)} className="theme-accent-bg control-pill mt-5 inline-flex items-center gap-2 border border-strong px-5 py-2.5"><Plus size={18} />Create a note</button>}
            </div>
        ) : <div className="grid gap-4 p-1 sm:grid-cols-2 xl:grid-cols-3">
            {notes.map((note: Note) => {
                const image = getNoteImage(note);

                return (
                    <Link
                        key={note.id}
                        to="/notes/$noteId"
                        params={{ noteId: String(note.id) }}
                        className="surface-card group overflow-hidden transition-transform hover:-translate-y-1">
                        {image ? (
                            <img
                                src={image}
                                alt={note.title || `Note ${note.id}`}
                                loading="lazy"
                                className="aspect-[4/3] w-full object-cover transition-transform duration-500 group-hover:scale-105"
                            />
                        ) : (
                            <div className="min-h-44 p-5">
                                <p className="mb-5 text-xs uppercase tracking-[0.18em] text-secondary">{note.isLocal ? 'Local draft' : 'Note'}</p>
                                <h2 className="mb-2 text-3xl">
                                    {note.title || `Note ${note.id}`}
                                </h2>

                                <p className="line-clamp-3">
                                    {note.description || 'No description provided.'}
                                </p>
                            </div>
                        )}
                    </Link>
                );
            })}
        </div>}

        <NotesActionFab onNewNote={() => setIsComposerOpen(true)} onNotice={setNotice} />
        {isComposerOpen && <NoteComposerModal onClose={() => setIsComposerOpen(false)} onSave={saveLocalNote} />}
    </>
    );
}
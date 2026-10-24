import { Link } from "@tanstack/react-router";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Search, X } from "lucide-react";
import { useState } from "react";

import useFetchQuery from "../utils/useFetchQuery";
import { createNote, NOTES_API_BASE } from "../utils/notesApi";
import type { Note, NoteWriteInput } from "../utils/notes";

import NoteCoverImage from "./NoteCoverImage";
import NotesActionFab, { type NewNoteDraft } from "./NotesActionFab";
import NoteComposerModal from "./NoteComposerModal";
import Spinner from "./Spinner";

export default function NotesList() {
  const [filter, setFilter] = useState<
    "All" | "Recent" | "With cover" | "Text only"
  >("All");

  const [search, setSearch] = useState("");
  const [notice, setNotice] = useState<string | null>(null);

  const queryClient = useQueryClient();
  const createMutation = useMutation({
    mutationFn: (input: NoteWriteInput) => createNote(input),
  });

  // Controls the full-page note editor.
  const [isComposerOpen, setIsComposerOpen] = useState(false);

  // Initial values supplied by the create-note dialog.
  const [newNoteDraft, setNewNoteDraft] = useState<NewNoteDraft | null>(null);

  const {
    data: pages = [],
    isLoading,
    isError,
    error,
    refetch,
  } = useFetchQuery<Note[]>({
    queryKey: ["notes"],
    queryLink: `${NOTES_API_BASE}/notes`,
  });

  const query = search.trim().toLowerCase();

  const notes = pages.filter((note) => {
    const matchesSearch =
      !query || `${note.title ?? ""}`.toLowerCase().includes(query);

    const matchesFilter =
      filter === "All" ||
      (filter === "With cover" && Boolean(note.imageUrl)) ||
      (filter === "Text only" && !note.imageUrl) ||
      (filter === "Recent" && Boolean(note.updatedAt ?? note.createdAt));

    return matchesSearch && matchesFilter;
  });

  const handleNewNote = (draft: NewNoteDraft) => {
    setNewNoteDraft(draft);
    setIsComposerOpen(true);
    setNotice(null);
  };

  const handleCloseComposer = () => {
    setIsComposerOpen(false);
    setNewNoteDraft(null);
  };

  if (isLoading) {
    return <Spinner />;
  }

  // Keep the editor separate from the notes list.
  // The composer already renders a full-screen editing surface.
  if (isComposerOpen) {
    return (
      <NoteComposerModal
        initialTitle={newNoteDraft?.title ?? ""}
        initialCoverFile={newNoteDraft?.coverFile ?? null}
        onClose={handleCloseComposer}
        onSave={async (note) => {
          await createMutation.mutateAsync({
            title: note.title?.trim() || "Untitled note",
            imageUrl: note.imageUrl ?? null,
            blocks: (note.blocks ?? []).map((block) => ({
              blockKey: block.blockKey ?? null,
              type: block.type,
              data: block.data,
            })),
          });

          await queryClient.invalidateQueries({ queryKey: ["notes"] });
          handleCloseComposer();
          setNotice("Note saved.");
        }}
      />
    );
  }

  return (
    <>
      <div className="mx-auto mb-8 max-w-6xl">
        <label
          className="surface-raised flex flex-1 items-center gap-2 rounded-xl px-3 py-2"
          htmlFor="note-search"
        >
          <Search size={18} className="text-secondary" />

          <input
            id="note-search"
            value={search}
            onChange={(event) => setSearch(event.target.value)}
            placeholder="Search notes"
            className="w-full bg-transparent outline-none"
          />

          {search && (
            <button
              type="button"
              onClick={() => setSearch("")}
              aria-label="Clear search"
            >
              <X size={16} />
            </button>
          )}
        </label>
      </div>

      <div className="mb-8 flex flex-wrap justify-center gap-3">
        {(["All", "Recent", "With cover", "Text only"] as const).map((item) => (
          <button
            key={item}
            type="button"
            onClick={() => setFilter(item)}
            className={
              filter === item
                ? "theme-accent-bg control-pill border border-strong px-4 py-2"
                : "control-pill border border-strong px-4 py-2 hover-surface-card"
            }
          >
            {item}
          </button>
        ))}
      </div>

      {notice && (
        <div className="theme-accent-soft mx-auto mb-5 flex max-w-4xl items-center justify-between rounded-xl border border-strong px-4 py-3 text-sm">
          <span>{notice}</span>

          <button
            type="button"
            onClick={() => setNotice(null)}
            aria-label="Dismiss message"
          >
            <X size={16} />
          </button>
        </div>
      )}

      {isError ? (
        <div className="surface-card mx-auto max-w-xl p-8 text-center">
          <h2 className="text-3xl">Your notes could not load</h2>

          <p className="mt-2 text-secondary">
            {error instanceof Error
              ? error.message
              : "Please check your connection and try again."}
          </p>

          <button
            type="button"
            onClick={() => void refetch()}
            className="theme-accent-bg control-pill mt-5 border border-strong px-5 py-2.5"
          >
            Try again
          </button>
        </div>
      ) : notes.length === 0 ? (
        <div className="surface-card mx-auto max-w-xl p-10 text-center">
          <h2 className="mt-4 text-3xl">No notes found</h2>
          <p className="mt-2 text-secondary">
            Capture your first thought and make it easy to return to
          </p>
        </div>
      ) : (
        <div className="grid gap-4 p-1 sm:grid-cols-2 xl:grid-cols-3">
          {notes.map((note) => {
            const image = note.imageUrl;

            return (
              <Link
                key={note.id}
                to="/notes/$noteId"
                params={{ noteId: String(note.id) }}
                className="surface-card group overflow-hidden transition-transform hover:-translate-y-1"
              >
                {image ? (
                  <NoteCoverImage
                    value={image}
                    src={note.coverUrl}
                    alt={note.title || `Note ${note.id}`}
                    loading="lazy"
                    className="aspect-4/3 w-full object-cover transition-transform duration-500 group-hover:scale-105"
                  />
                ) : (
                  <div className="min-h-44 p-5">
                    <p className="mb-5 text-xs uppercase tracking-[0.18em] text-secondary">
                      Note
                    </p>

                    <h2 className="mb-2 text-3xl">
                      {note.title || `Note ${note.id}`}
                    </h2>
                  </div>
                )}
              </Link>
            );
          })}
        </div>
      )}

      <NotesActionFab onNewNote={handleNewNote} onNotice={setNotice} />
    </>
  );
}

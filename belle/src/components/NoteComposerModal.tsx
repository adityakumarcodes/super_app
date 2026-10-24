import EditorJS, { type OutputData } from "@editorjs/editorjs";
import { Check, ImagePlus, LoaderCircle, Trash2, X } from "lucide-react";
import { useEffect, useRef, useState } from "react";
import { EDITOR_JS_TOOLS } from "../constants/editorConfig";
import { editorDataToBlocks, type Note } from "../utils/noteDrafts";
import { uploadImage } from "../utils/storageApi";

type NoteComposerModalProps = {
  note?: Note;
  initialTitle?: string;
  initialCoverFile?: File | null;
  onClose: () => void;
  onSave: (note: Note) => void | Promise<void>;
};

export default function NoteComposerModal({
  note,
  initialTitle = "",
  initialCoverFile = null,
  onClose,
  onSave,
}: NoteComposerModalProps) {
  const [title, setTitle] = useState(note?.title ?? initialTitle);
  const [coverFile, setCoverFile] = useState<File | null>(initialCoverFile);
  const [coverPreview, setCoverPreview] = useState<string | null>(() =>
    initialCoverFile ? URL.createObjectURL(initialCoverFile) : null,
  );
  const [coverRemoved, setCoverRemoved] = useState(false);
  const [coverError, setCoverError] = useState<string | null>(null);
  const [saveError, setSaveError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const previewUrlRef = useRef<string | null>(coverPreview);
  const editorRef = useRef<EditorJS | null>(null);
  const coverInputRef = useRef<HTMLInputElement>(null);
  const holderId = "note-composer-editor";
  const savedCoverUrl = coverRemoved ? null : (note?.coverUrl ?? null);
  const coverImage = coverPreview ?? savedCoverUrl;

  useEffect(
    () => () => {
      if (previewUrlRef.current) {
        URL.revokeObjectURL(previewUrlRef.current);
      }
    },
    [],
  );

  const selectCoverFile = (file: File | null) => {
    if (previewUrlRef.current) {
      URL.revokeObjectURL(previewUrlRef.current);
    }

    const preview = file ? URL.createObjectURL(file) : null;
    previewUrlRef.current = preview;
    setCoverFile(file);
    setCoverPreview(preview);
  };

  useEffect(() => {
    const data: OutputData = {
      time: Date.now(),
      blocks: (note?.blocks ?? []).map((block) => ({
        id: block.blockKey ?? String(block.id),
        type: block.type,
        data: block.data,
      })),
    };

    const editor = new EditorJS({
      holder: holderId,
      tools: EDITOR_JS_TOOLS,
      data,
      placeholder: "Start writing your note…",
      autofocus: !note,
    });
    editorRef.current = editor;

    return () => {
      if (typeof editor.destroy === "function") {
        editor.destroy();
      } else {
        document.getElementById(holderId)?.replaceChildren();
      }

      if (editorRef.current === editor) {
        editorRef.current = null;
      }
    };
  }, [note]);

  const save = async () => {
    if (saving) return;

    setSaving(true);
    setSaveError(null);

    try {
      const output = (await editorRef.current?.save()) ?? {
        time: Date.now(),
        blocks: [],
      };

      // The upload endpoint returns a storage path and a signed URL.
      // Only the path is persisted; signed URLs expire after an hour.
      const uploadedCover = coverFile ? await uploadImage(coverFile) : null;
      const imageUrl = uploadedCover
        ? uploadedCover.path
        : coverRemoved
          ? null
          : (note?.imageUrl ?? null);

      await onSave({
        ...note,
        id: note?.id ?? `draft-${crypto.randomUUID()}`,
        title: title.trim() || "Untitled note",
        imageUrl,
        blocks: editorDataToBlocks(output),
        isLocal: note?.isLocal ?? !note,
        createdAt: note?.createdAt ?? new Date().toISOString(),
      });
    } catch (error) {
      setSaveError(
        error instanceof Error
          ? error.message
          : "The note could not be saved. Please try again.",
      );
    } finally {
      setSaving(false);
    }
  };

  const selectCover = (file?: File) => {
    if (!file) return;
    if (!file.type.startsWith("image/")) {
      setCoverError("Choose an image file for the cover.");
      return;
    }
    if (file.size > 5 * 1024 * 1024) {
      setCoverError("Choose an image smaller than 5 MB for the cover.");
      return;
    }

    selectCoverFile(file);
    setCoverRemoved(false);
    setCoverError(null);
  };

  const removeCover = () => {
    selectCoverFile(null);
    setCoverRemoved(true);
    setCoverError(null);

    if (coverInputRef.current) {
      coverInputRef.current.value = "";
    }
  };

  return (
    <div
      className="surface-body fixed inset-0 z-50 overflow-y-auto"
      role="dialog"
      aria-modal="true"
      aria-label="Note editor"
    >
      <section className="min-h-screen w-full">
        <header className="sticky top-0 z-10 border-b border-subtle bg-(--surface-body)/95 px-4 py-3 backdrop-blur md:px-8">
          <div className="mx-auto flex max-w-5xl items-center justify-between gap-4">
            <button
              type="button"
              disabled={saving}
              onClick={onClose}
              className="control-pill inline-flex items-center gap-2 px-3 py-2 text-sm text-secondary hover:bg-black/5 disabled:opacity-70"
              aria-label="Close editor"
            >
              <X size={18} />
              Close
            </button>
            <div className="flex items-center gap-2">
              <span className="hidden text-sm text-secondary sm:inline">
                {note ? "Editing note" : "New note"}
              </span>
              <button
                type="button"
                disabled={saving}
                onClick={() => void save()}
                className="theme-accent-bg control-pill inline-flex items-center gap-2 border border-strong px-4 py-2 font-medium disabled:cursor-wait disabled:opacity-70"
              >
                {saving ? (
                  <LoaderCircle size={18} className="animate-spin" />
                ) : (
                  <Check size={18} />
                )}
                {saving ? "Saving…" : "Save"}
              </button>
            </div>
          </div>
        </header>
        <main className="mx-auto w-full max-w-5xl px-4 pb-20 pt-10 md:px-8">
          <header className="mb-12 max-w-4xl">
            <input
              ref={coverInputRef}
              type="file"
              accept="image/*"
              className="hidden"
              onChange={(event) => selectCover(event.target.files?.[0])}
            />
            {coverImage ? (
              <div className="group relative mb-8 overflow-hidden rounded-3xl border border-strong">
                <img
                  src={coverImage}
                  alt="Selected note cover"
                  className="h-52 w-full object-cover md:h-64"
                />
                <button
                  type="button"
                  disabled={saving}
                  onClick={removeCover}
                  className="control-pill absolute right-3 top-3 inline-flex items-center gap-2 border border-strong bg-(--surface-body)/95 px-3 py-2 text-sm shadow-sm disabled:opacity-70"
                >
                  <Trash2 size={15} />
                  Remove cover
                </button>
              </div>
            ) : (
              <button
                type="button"
                disabled={saving}
                onClick={() => coverInputRef.current?.click()}
                className="control-pill mb-8 inline-flex items-center gap-2 border border-subtle px-3 py-2 text-sm text-secondary hover-surface-card disabled:opacity-70"
              >
                <ImagePlus size={17} />
                Add cover
              </button>
            )}
            {coverError && (
              <p className="-mt-5 mb-5 text-sm text-red-700" role="alert">
                {coverError}
              </p>
            )}
            <input
              id="note-title"
              value={title}
              onChange={(event) => setTitle(event.target.value)}
              placeholder="Untitled"
              aria-label="Note title"
              className="w-full bg-transparent font-bodoni text-5xl leading-tight tracking-tight outline-none placeholder:text-stone-400 md:text-7xl"
            />
          </header>
          <div className="mx-auto max-w-4xl border-t border-subtle pt-8">
            <div id={holderId} />
          </div>
          {saveError && (
            <p
              className="mx-auto mt-6 max-w-4xl text-sm text-red-700"
              role="alert"
            >
              {saveError}
            </p>
          )}
        </main>
      </section>
    </div>
  );
}

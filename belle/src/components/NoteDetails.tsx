import EditorJS, { type OutputData } from "@editorjs/editorjs";
import {
    forwardRef,
    useEffect,
    useImperativeHandle,
    useMemo,
    useRef,
} from "react";
import { EDITOR_JS_TOOLS } from "../constants/editorConfig";

interface NoteDetailsProps {
    data: OutputData;
    editable?: boolean;
}

export type NoteDetailsHandle = {
    save: () => Promise<OutputData>;
};

const NoteDetails = forwardRef<NoteDetailsHandle, NoteDetailsProps>(function NoteDetails(
    { data, editable = false },
    ref,
) {
    const holderRef = useRef<HTMLDivElement | null>(null);
    const editorRef = useRef<EditorJS | null>(null);
    const images = useMemo(() => import.meta.glob(
        "../assets/images/notes/*.jpg",
        {
            eager: true,
            import: "default",
        },
    ) as Record<string, string>, []);

    const editorData = useMemo<OutputData>(() => {
        if (editable) {
            return data;
        }

        return {
            ...data,
            blocks: data.blocks.map((block) => {
                if (block.type !== "image") {
                    return block;
                }

                const imageData = block.data as {
                    file?: {
                        url?: string;
                    };
                };

                const imageName = imageData.file?.url?.split("/").pop();

                const localImage = imageName
                    ? images[`../assets/images/notes/${imageName}`]
                    : undefined;

                if (!localImage) {
                    return block;
                }

                return {
                    ...block,
                    data: {
                        ...imageData,
                        file: {
                            ...imageData.file,
                            url: localImage,
                        },
                    },
                };
            }),
        };
    }, [data, editable, images]);

    useImperativeHandle(ref, () => ({
        async save() {
            const editor = editorRef.current;
            if (!editor) {
                throw new Error("The note editor is still loading. Please try again.");
            }

            await editor.isReady;
            return editor.save();
        },
    }), []);

    useEffect(() => {
        const holder = holderRef.current;
        if (!holder) {
            return;
        }

        const editor = new EditorJS({
            holder,
            tools: EDITOR_JS_TOOLS,
            data: editorData,
            readOnly: !editable,
            autofocus: editable,
            placeholder: editable ? "Start writing your note…" : undefined,
        });
        editorRef.current = editor;

        return () => {
            if (editorRef.current === editor) {
                editorRef.current = null;
            }

            if (typeof editor.destroy === "function") {
                editor.destroy();
            } else {
                holder.replaceChildren();
            }
        };
    }, [editable, editorData]);

    return (
        <div className="p-2 text-left">
            {editable && <p className="mb-3 text-sm text-secondary">Content — click below to write, then use the + menu to add a different block type.</p>}
            <div ref={holderRef} />
        </div>
    );
});

export default NoteDetails;

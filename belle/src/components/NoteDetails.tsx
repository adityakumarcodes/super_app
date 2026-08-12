import EditorJS, { type OutputData } from "@editorjs/editorjs";
import { useEffect } from "react";
import { EDITOR_JS_TOOLS } from "../constants/editorConfig";

interface NoteDetailsProps {
    data: OutputData;
    imageUrl?: string;
}

const NoteDetails = ({ data }: NoteDetailsProps) => {
    const images = import.meta.glob(
        "../assets/images/notes/*.jpg",
        {
            eager: true,
            import: "default",
        },
    ) as Record<string, string>;

    useEffect(() => {
        const renderData: OutputData = {
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

        const editor = new EditorJS({
            holder: "editorjs",
            tools: EDITOR_JS_TOOLS,
            data: renderData,
            // readOnly: true,
        });

        return () => {
            if (typeof editor.destroy === "function") {
                editor.destroy();
            } else {
                document.getElementById("editorjs")?.replaceChildren();
            }
        };
    }, [data]);

    return (
        <div className="p-2 text-left">
            <div id="editorjs" />
        </div>
    );
};

export default NoteDetails;
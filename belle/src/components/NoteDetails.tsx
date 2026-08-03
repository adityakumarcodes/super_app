import EditorJS, { type OutputData } from '@editorjs/editorjs';
import { useEffect, useMemo } from 'react';
import { EDITOR_JS_TOOLS } from '../constants/editorConfig';

interface NoteDetailsProps {
    data: OutputData;
    imageUrl?: string;
}

const NoteDetails = ({ data, imageUrl }: NoteDetailsProps) => {
    const images = import.meta.glob(
        '../assets/images/notes/*.{jpg,jpeg,jfif,png}',
        { eager: true, import: 'default' },
    ) as Record<string, string>;

    const noteImage = imageUrl
        ? images[`../assets/images/notes/${imageUrl.split('/').pop()}`] ?? imageUrl
        : undefined;

    const renderData = useMemo<OutputData>(() => ({
        ...data,
        blocks: data.blocks.map((block) => {
            if (block.type !== 'image') {
                return block;
            }

            const imageData = block.data as { file?: { url?: string } };
            const imageName = imageData.file?.url?.split('/').pop();
            const localImage = imageName
                ? images[`../assets/images/notes/${imageName}`]
                : undefined;

            return localImage
                ? {
                    ...block,
                    data: {
                        ...imageData,
                        file: { ...imageData.file, url: localImage },
                    },
                }
                : block;
        }),
    }), [data]);

    useEffect(() => {
        const editor = new EditorJS({
            holder: 'editorjs',
            tools: EDITOR_JS_TOOLS,
            data: renderData,
            // readOnly: true,
        });

        return () => {
            if (typeof editor.destroy === 'function') {
                editor.destroy();
            } else {
                document.getElementById('editorjs')?.replaceChildren();
            }
        };
    }, [renderData]);

    return (
        <div className="p-2 text-left">
            {noteImage ? (
                <img
                    src={noteImage}
                    alt="Note image"
                    className="mb-4 w-1/3 object-cover rounded-xl"
                />
            ) : null}
            <div id='editorjs' />
        </div>
    )
}

export default NoteDetails
// https://assets-global.website-files.com/632c2ca7090891667181cf26/6357c4fd5250b4baf26e7460_Rich%20text-transcode.mp4

import EditorJS from '@editorjs/editorjs';
import { EDITOR_JS_TOOLS } from '../constants/editorConfig';

const INITIAL_DATA = {
    time: 1701368244004,
    blocks: [
        {
            "type": "header",
            "data": {
                "text": "Why Telegram is the best messenger",
                "level": 1
            }
        },
    ],
    version: "2.31.6",
};

const NoteDetails = () => {
    const editor = new EditorJS({
        holder: "editorjs",
        tools: EDITOR_JS_TOOLS,
        data: INITIAL_DATA
    });
    return (
        <div className="p-2 text-left">
            <div id='editorjs' />
        </div>
    )
}

export default NoteDetails
// https://assets-global.website-files.com/632c2ca7090891667181cf26/6357c4fd5250b4baf26e7460_Rich%20text-transcode.mp4
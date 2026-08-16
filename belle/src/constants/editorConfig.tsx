import type { ToolConfig } from "@editorjs/editorjs";

import Header from "@editorjs/header";
import EditorjsList from "@editorjs/list";
import ImageTool from '@editorjs/image';
import Delimiter from '@editorjs/delimiter';
import MyCallout from "../components/MyCallout";

export const EDITOR_JS_TOOLS: ToolConfig = {
  header: {
    class: Header,
    inlineToolbar: true,
    shortcut: 'CMD+SHIFT+H',
    config: {
      placeholder: 'Enter a heading',
      levels: [1, 2, 3, 4, 5, 6],
      defaultLevel: 1
    },
  },
  callout: {
    class: MyCallout,
    inlineToolbar: true,
  },
  list: {
    class: EditorjsList,
    inlineToolbar: true,
    config: {
      defaultStyle: 'unordered'
    }
  },

  image: {
    class: ImageTool,
  },


  delimiter: {
    class: Delimiter,
  },

  // image: {
  //   class: ImageTool,
  //   config: {
  //     // endpoints: {
  //     //   byFile: 'http://localhost:8008/uploadFile', // Your backend file uploader endpoint
  //     //   byUrl: 'http://localhost:8008/fetchUrl', // Your endpoint that provides uploading by Url
  //     // },
  //     uploader: {
  //       uploadByFile: async (file) => {
  //         console.log('uploading');
  //         const { data, error } = await supabase.storage
  //           .from('notes')
  //           .upload(`images/${file?.name}`, file);

  //         console.log(data ?? error);
  //         console.log(file);

  //         return {
  //           success: 1,
  //           file: { url: 'https://kapnkypovldoarardosa.supabase.co/storage/v1/object/public/notes/images/' + file.name },
  //         };
  //       },
  //       uploadByUrl: async (url) => {
  //         const response = await fetch(url);
  //         const file = await response.blob();
  //         console.log(file);
  //         const { data, error } = await supabase.storage
  //           .from('notes')
  //           .upload(`images/${file?.name}`, file);

  //         console.log(data ?? error);

  //         return {
  //           success: 1,
  //           file: { url: url },
  //         };
  //       }
  //     }
  //   }
  // },
};

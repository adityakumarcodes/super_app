import type { ToolConfig } from "@editorjs/editorjs";

import Header from "@editorjs/header";
import EditorjsList from "@editorjs/list";
import ImageTool from "@editorjs/image";
import Delimiter from "@editorjs/delimiter";
import Paragraph from "@editorjs/paragraph";

const API_URL =
  import.meta.env.VITE_API_URL ?? "http://localhost:3000/api";

export const EDITOR_JS_TOOLS: ToolConfig = {
  paragraph: {
    class: Paragraph,
    inlineToolbar: true,
  },

  header: {
    class: Header,
    inlineToolbar: true,
    shortcut: "CMD+SHIFT+H",
    config: {
      placeholder: "Enter a heading",
      levels: [1, 2, 3, 4, 5, 6],
      defaultLevel: 1,
    },
  },

  list: {
    class: EditorjsList,
    inlineToolbar: true,
    config: {
      defaultStyle: "unordered",
    },
  },

  delimiter: {
    class: Delimiter,
  },

  image: {
    class: ImageTool,
    config: {
      field: "file",
      types: "image/*",

      uploader: {
        uploadByFile: async (file: File) => {
          const formData = new FormData();
          formData.append("file", file);

          const response = await fetch(`${API_URL}/storage/upload`, {
            method: "POST",
            credentials: "include",
            body: formData,
          });

          const result = await response.json();

          if (!response.ok) {
            throw new Error(
              result.message ?? "Failed to upload image",
            );
          }

          if (!result.path || !result.url) {
            throw new Error(
              "Upload response must contain path and url",
            );
          }

          return {
            success: 1,
            file: {
              url: result.url,
              path: result.path,
            },
          };
        },
      },
    },
  },
};
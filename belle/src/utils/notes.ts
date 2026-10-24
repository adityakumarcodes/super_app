import type { OutputData } from "@editorjs/editorjs";

export type NoteBlock = {
  id: number | string;
  blockKey?: string | null;
  type: string;
  data: Record<string, unknown>;
  order?: number;
  text?: string | null;
};

export type NoteBlockInput = {
  blockKey?: string | null;
  type: string;
  data: Record<string, unknown>;
};

export type Note = {
  id: number | string;
  title?: string | null;
  imageUrl?: string | null;
  coverUrl?: string | null;
  content?: string | null;
  blocks?: NoteBlock[];
  createdAt?: string;
  updatedAt?: string;
};

export type NoteWriteInput = {
  title: string;
  imageUrl: string | null;
  blocks: NoteBlockInput[];
};

export function editorDataToBlocks(data: OutputData): NoteBlockInput[] {
  return data.blocks.map((block, index) => ({
    blockKey: block.id ?? `block-${index}`,
    type: block.type,
    data: block.data as Record<string, unknown>,
  }));
}

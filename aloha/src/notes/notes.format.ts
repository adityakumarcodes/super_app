/**
 * Converts between note text and Editor.js blocks so every client can read and
 * write notes the same way. Only the tools enabled in the web editor config
 * (belle/src/constants/editorConfig.tsx) are supported:
 *
 *   # .. ######        header (levels 1-6)
 *   - item / * item    list, unordered
 *   1. item            list, ordered
 *   - [ ] / - [x] item list, checklist
 *   ---                delimiter
 *   ![caption](path)   image (storage path or http url)
 *   anything else      paragraph; a blank line starts a new block
 *
 * Inline HTML (e.g. <b>) is kept as-is, so text -> blocks -> text is lossless.
 */

export type EditorBlock = {
  type: string;
  data: Record<string, unknown>;
};

type ListStyle = 'unordered' | 'ordered' | 'checklist';

type ListItem = {
  content: string;
  meta: Record<string, unknown>;
  items: ListItem[];
};

const HEADER = /^(#{1,6})\s+(.*)$/;
const DELIMITER = /^-{3,}$/;
const IMAGE = /^!\[(.*)\]\((\S+)\)$/;
const CHECKLIST = /^[-*]\s+\[([ xX])\]\s+(.*)$/;
const UNORDERED = /^[-*]\s+(.*)$/;
const ORDERED = /^\d+[.)]\s+(.*)$/;
const LINE_BREAK = /<br\s*\/?>/gi;

function parseListLine(
  line: string,
): { style: ListStyle; item: ListItem } | undefined {
  const checklist = CHECKLIST.exec(line);
  if (checklist) {
    const checked = checklist[1].toLowerCase() === 'x';
    return {
      style: 'checklist',
      item: { content: checklist[2], meta: { checked }, items: [] },
    };
  }

  const unordered = UNORDERED.exec(line);
  if (unordered)
    return {
      style: 'unordered',
      item: { content: unordered[1], meta: {}, items: [] },
    };

  const ordered = ORDERED.exec(line);
  if (ordered)
    return {
      style: 'ordered',
      item: { content: ordered[1], meta: {}, items: [] },
    };

  return undefined;
}

function imageBlock(caption: string, source: string): EditorBlock {
  const file = /^https?:\/\//i.test(source)
    ? { url: source }
    : { path: source };
  return {
    type: 'image',
    data: {
      file,
      caption,
      withBorder: false,
      stretched: false,
      withBackground: false,
    },
  };
}

/**
 * Parses text line by line. Consecutive text lines are buffered into one
 * paragraph and consecutive list lines of the same style into one list; both
 * buffers are flushed when another kind of line (or a blank line) appears.
 */
export function contentToBlocks(content: string): EditorBlock[] {
  const blocks: EditorBlock[] = [];
  let paragraph: string[] = [];
  let list: { style: ListStyle; items: ListItem[] } | undefined;

  const flushParagraph = () => {
    if (paragraph.length)
      blocks.push({
        type: 'paragraph',
        data: { text: paragraph.join('<br>') },
      });
    paragraph = [];
  };
  const flushList = () => {
    if (list)
      blocks.push({
        type: 'list',
        data: { style: list.style, meta: {}, items: list.items },
      });
    list = undefined;
  };
  const flush = () => {
    flushParagraph();
    flushList();
  };

  for (const rawLine of content.replace(/\r\n?/g, '\n').split('\n')) {
    const line = rawLine.trim();
    if (!line) {
      flush();
      continue;
    }

    const header = HEADER.exec(line);
    const image = IMAGE.exec(line);
    if (header) {
      flush();
      blocks.push({
        type: 'header',
        data: { text: header[2], level: header[1].length },
      });
    } else if (DELIMITER.test(line)) {
      flush();
      blocks.push({ type: 'delimiter', data: {} });
    } else if (image) {
      flush();
      blocks.push(imageBlock(image[1], image[2]));
    } else {
      const listLine = parseListLine(line);
      if (!listLine) {
        flushList();
        paragraph.push(line);
        continue;
      }

      flushParagraph();
      if (!list || list.style !== listLine.style) {
        flushList();
        list = { style: listLine.style, items: [] };
      }
      list.items.push(listLine.item);
    }
  }

  flush();
  return blocks;
}

function asRecord(value: unknown): Record<string, unknown> {
  return value && typeof value === 'object' && !Array.isArray(value)
    ? (value as Record<string, unknown>)
    : {};
}

function asString(value: unknown): string {
  return typeof value === 'string' ? value : '';
}

function listToContent(data: Record<string, unknown>): string | null {
  const items = Array.isArray(data.items) ? data.items : [];
  const lines: string[] = [];

  for (const [index, rawItem] of items.entries()) {
    // List v1 stored plain strings; v2 stores { content, meta, items }.
    const item = asRecord(rawItem);
    const content =
      typeof rawItem === 'string' ? rawItem : asString(item.content);
    if (Array.isArray(item.items) && item.items.length) return null;

    if (data.style === 'checklist') {
      lines.push(`- [${asRecord(item.meta).checked ? 'x' : ' '}] ${content}`);
    } else if (data.style === 'ordered') {
      lines.push(`${index + 1}. ${content}`);
    } else {
      lines.push(`- ${content}`);
    }
  }

  return lines.join('\n');
}

function blockToContent(block: {
  type?: unknown;
  data?: unknown;
}): string | null {
  const data = asRecord(block.data);

  switch (block.type) {
    case 'paragraph':
      return asString(data.text).replace(LINE_BREAK, '\n');
    case 'header': {
      const level = Math.min(Math.max(Number(data.level) || 1, 1), 6);
      return `${'#'.repeat(level)} ${asString(data.text)}`;
    }
    case 'delimiter':
      return '---';
    case 'image': {
      const file = asRecord(data.file);
      const source = asString(file.path) || asString(file.url);
      return source ? `![${asString(data.caption)}](${source})` : null;
    }
    case 'list':
      return listToContent(data);
    default:
      return null;
  }
}

/** Returns the note as text, or null when a block cannot be expressed as text. */
export function blocksToContent(
  blocks: { type?: unknown; data?: unknown }[],
): string | null {
  const parts: string[] = [];
  for (const block of blocks) {
    const part = blockToContent(block);
    if (part === null) return null;
    if (part.trim()) parts.push(part);
  }
  return parts.join('\n\n');
}

import { blocksToContent, contentToBlocks } from './notes.format';

describe('contentToBlocks', () => {
  it('maps each syntax to the matching Editor.js tool', () => {
    const blocks = contentToBlocks(
      [
        '## Title',
        '',
        'Hello <b>world</b>',
        'second line',
        '',
        '- one',
        '- two',
        '1. first',
        '- [x] done',
        '- [ ] todo',
        '---',
        '![Cover](notes/u1/a.png)',
      ].join('\n'),
    );

    expect(blocks).toEqual([
      { type: 'header', data: { text: 'Title', level: 2 } },
      {
        type: 'paragraph',
        data: { text: 'Hello <b>world</b><br>second line' },
      },
      {
        type: 'list',
        data: {
          style: 'unordered',
          meta: {},
          items: [
            { content: 'one', meta: {}, items: [] },
            { content: 'two', meta: {}, items: [] },
          ],
        },
      },
      {
        type: 'list',
        data: {
          style: 'ordered',
          meta: {},
          items: [{ content: 'first', meta: {}, items: [] }],
        },
      },
      {
        type: 'list',
        data: {
          style: 'checklist',
          meta: {},
          items: [
            { content: 'done', meta: { checked: true }, items: [] },
            { content: 'todo', meta: { checked: false }, items: [] },
          ],
        },
      },
      { type: 'delimiter', data: {} },
      {
        type: 'image',
        data: {
          file: { path: 'notes/u1/a.png' },
          caption: 'Cover',
          withBorder: false,
          stretched: false,
          withBackground: false,
        },
      },
    ]);
  });

  it('treats http image sources as urls', () => {
    const [block] = contentToBlocks('![](https://example.com/a.png)');
    expect(block.data.file).toEqual({ url: 'https://example.com/a.png' });
  });

  it('returns no blocks for blank text', () => {
    expect(contentToBlocks(' \n\n ')).toEqual([]);
  });
});

describe('blocksToContent', () => {
  it('round-trips text written by contentToBlocks', () => {
    const content = [
      '# Plan',
      'Buy <i>milk</i>\nand bread',
      '- a\n- b',
      '1. x\n2. y',
      '- [x] done\n- [ ] todo',
      '---',
      '![cap](notes/u1/b.png)',
    ].join('\n\n');

    expect(blocksToContent(contentToBlocks(content))).toBe(content);
  });

  it('reads list v1 string items', () => {
    const blocks = [
      { type: 'list', data: { style: 'ordered', items: ['a', 'b'] } },
    ];
    expect(blocksToContent(blocks)).toBe('1. a\n2. b');
  });

  it('returns null for blocks that cannot be written as text', () => {
    expect(blocksToContent([{ type: 'table', data: {} }])).toBeNull();

    const nested = [
      {
        type: 'list',
        data: {
          style: 'unordered',
          items: [{ content: 'a', meta: {}, items: [{ content: 'b' }] }],
        },
      },
    ];
    expect(blocksToContent(nested)).toBeNull();
  });
});

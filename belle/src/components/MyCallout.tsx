import type { API, BlockTool, BlockToolConstructorOptions } from '@editorjs/editorjs';

type CalloutData = {
    text: string;
};

export default class MyCallout implements BlockTool {
    private api: API;
    private data: CalloutData;
    private wrapper: HTMLDivElement | null = null;

    static get toolbox() {
        return {
            title: 'Callout',
            icon: '💡',
        };
    }

    constructor({
        data,
        api,
    }: BlockToolConstructorOptions<CalloutData>) {
        this.api = api;
        this.data = data ?? {
            text: '',
        };
    }

    render() {
        this.wrapper = document.createElement('div');

        this.wrapper.className =
            'my-callout flex gap-3 rounded-lg bg-orange-50 p-4 border-2 ';

        const icon = document.createElement('div');

        icon.className = 'shrink-0 text-xl';
        icon.textContent = '💡';

        const content = document.createElement('div');

        content.className =
            'min-w-0 flex-1 text-sm leading-6 text-slate-800';

        content.contentEditable = 'true';
        content.innerHTML = this.data.text;

        this.wrapper.appendChild(icon);
        this.wrapper.appendChild(content);

        this.contentElement = content;

        return this.wrapper;
    }

    private contentElement: HTMLDivElement | null = null;

    save(block: HTMLElement): CalloutData {
        const content = block.querySelector(
            '[contenteditable="true"]',
        ) as HTMLElement | null;

        return {
            text: content?.innerHTML ?? '',
        };
    }

    static get sanitize() {
        return {
            text: {
                br: true,
                b: true,
                i: true,
                a: {
                    href: true,
                },
            },
        };
    }
}
import type { ComponentType } from 'react'

type ChatItem = {
    id: number
    title: string
    preview: string
    time: string
    unread: number
}

type Action = {
    key: string
    label: string
    Icon: ComponentType<{ strokeWidth?: number }>
}

type ChatListProps = {
    chats: ChatItem[]
    selectedChatId: number
    menu: string
    actions: Action[]
    onMenuChange: (label: string) => void
    onSelectChat: (id: number) => void
}

export default function ChatList({
    chats,
    selectedChatId,
    menu,
    actions,
    onMenuChange,
    onSelectChat,
}: ChatListProps) {
    return (
        <div className="flex-3 h-full border-r border-black p-4">
            <div className="mb-6 flex items-center justify-between">
                <h1 className="mt-2">Chats</h1>
            </div>
            <div className="flex flex-wrap gap-3 my-4">
                {actions.map(({ key, label, Icon }) => (
                    <button
                        key={key}
                        onClick={() => onMenuChange(label)}
                        className={
                            menu === label
                                ? 'inline-flex items-center gap-2 bg-orange-200 border-2 py-2 px-4 rounded-full'
                                : 'inline-flex items-center gap-2 border-2 py-2 px-4 rounded-full'
                        }
                    >
                        <Icon strokeWidth={1.25} />
                        <span>{label}</span>
                    </button>
                ))}
            </div>

            <div className="mt-6 space-y-3">
                {chats.map((chat) => (
                    <div
                        key={chat.id}
                        role="button"
                        tabIndex={0}
                        onClick={() => onSelectChat(chat.id)}
                        className={`${chat.id === selectedChatId ? 'p-4 bg-slate-200 border-2 border-black rounded-lg' : 'p-4 hover:bg-slate-100'} transition-colors`}
                    >
                        <div className="flex items-start justify-between gap-4">
                            <div>
                                <h4 className="text-slate-900 line-clamp-1">{chat.title}</h4>
                                <p className="mt-2 text-sm text-slate-500">{chat.preview}</p>
                            </div>
                            <div className="text-right">
                                {chat.unread > 0 ? (
                                    <span className="mt-2 inline-flex rounded-full bg-black px-2 py-2 text-s font-semibold text-white">
                                        {chat.unread}
                                    </span>
                                ) : null}
                                <p className="text-xs text-slate-400">{chat.time}</p>
                            </div>
                        </div>
                    </div>
                ))}
            </div>
        </div>
    )
}

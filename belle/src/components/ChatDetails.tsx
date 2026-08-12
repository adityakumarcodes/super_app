type ChatItem = {
    id: number
    title: string
    preview: string
    time: string
    unread: number
}

type Message = {
    role: 'assistant' | 'user'
    content: string
}

type ChatDetailsProps = {
    selectedChat: ChatItem
    messages: Message[]
}

export default function ChatDetails({ selectedChat, messages }: ChatDetailsProps) {
    return (
        <div className="flex-7 h-full">
            <div className="mb-6 flex items-center justify-between border-b-2">
                <h4 className="mt-2 p-4">{selectedChat.title}</h4>
            </div>

            <div className="space-y-3 overflow-y-auto p-4">
                {messages.map((message, index) => (
                    <div
                        key={index}
                        className={`w-fit max-w-[80%] rounded-4xl border-2 px-5 py-3 text-base leading-6 transition-all duration-200 ${message.role === 'user'
                            ? 'ml-auto border-2 bg-orange-200 text-slate-900'
                            : 'border-2 bg-slate-100 text-slate-900'
                            }`}
                    >
                        {message.content}
                    </div>
                ))}
            </div>
        </div>
    )
}

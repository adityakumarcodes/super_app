import { createFileRoute } from '@tanstack/react-router'
import { useState } from 'react'
import { CalendarDays, MapPin, Paperclip, Users } from 'lucide-react'

type ChatItem = {
  id: number
  title: string
  preview: string
  time: string
  unread: number
}

const chats: ChatItem[] = [
  {
    id: 1,
    title: 'Design studio brainstorm',
    preview: 'Let’s shape the homepage with a softer palette.',
    time: '09:12 AM',
    unread: 3,
  },
  {
    id: 2,
    title: 'Brand voice update',
    preview: 'Keep the tone warm, fresh, and expressive.',
    time: 'Yesterday',
    unread: 0,
  },
  {
    id: 3,
    title: 'Product landing review',
    preview: 'The hero copy should feel airy and confident.',
    time: 'Mon',
    unread: 1,
  },
  {
    id: 4,
    title: 'Inspirational mood board',
    preview: 'I found a great palette of evening hues.',
    time: 'Last week',
    unread: 0,
  },
]

const messages = [
  { role: 'assistant', content: 'Hi there! Ready to refine the new chat UI?' },
  { role: 'user', content: 'Yes, show me how the layout looks with sample content.' },
  { role: 'assistant', content: 'Here is a clean two-column layout with chat list and conversation details.' },
  { role: 'user', content: 'Perfect — that’s exactly what I need.' },
]

export const Route = createFileRoute('/chat')({
  component: RouteComponent,
})

function RouteComponent() {
  const [menu, setMenu] = useState('Schedule meeting')
  const [selectedChatId, setSelectedChatId] = useState<number>(chats[0].id)
  const actions = [
    { key: 'schedule', label: 'Schedule meeting', Icon: CalendarDays },
    { key: 'file', label: 'Send file', Icon: Paperclip },
    { key: 'location', label: 'Share location', Icon: MapPin },
    { key: 'group', label: 'Create group', Icon: Users },
  ]
  const selectedChat = chats.find((c) => c.id === selectedChatId) ?? chats[0]
  return (
    <div className="h-screen w-full bg-slate-50 ">
      <div className="flex h-full w-full gap-4  bg-white">
        <div className="flex-3 h-full border-r border-black p-4">
          <div className="mb-6 flex items-center justify-between ">
            <h1 className="mt-2 ">Chats</h1>
          </div>
          <div className="flex flex-wrap gap-3 my-4">
            {actions.map(({ key, label, Icon }) => (
              <button
                key={key}
                onClick={() => setMenu(label)}
                className={
                  menu === label
                    ? 'inline-flex items-center gap-2 bg-orange-200 border-2  py-2 px-4 rounded-full'
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
                onClick={() => setSelectedChatId(chat.id)}
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

        <div className="flex-7 h-full p-4">
          <div className="mb-6 flex items-center justify-between border-b-2">
            <h4 className="mt-2">{selectedChat.title}</h4>
          </div>

          <div className="space-y-4 overflow-y-auto pr-2">
            {messages.map((message, index) => (
              <div
                key={index}
                className={`max-w-[80%] rounded-3xl px-5 py-4 text-sm leading-6 ${message.role === 'user'
                  ? 'ml-auto bg-orange-200 text-slate-900'
                  : 'bg-slate-100 text-slate-900'
                  }`}
              >
                {message.content}
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}

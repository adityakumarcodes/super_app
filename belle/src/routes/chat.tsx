import { createFileRoute } from '@tanstack/react-router'
import { useState } from 'react'
import { CalendarDays, MapPin, Paperclip, Search, Users } from 'lucide-react'
import ChatDetails from '../components/ChatDetails'
import ChatList from '../components/ChatList'

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

const chats: ChatItem[] = [
  {
    id: 1,
    title: 'Design studio brainstorm',
    preview: 'Let\'s shape the homepage with a softer palette.',
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

type Action = {
  key: string
  label: string
  Icon: React.ElementType
  iconPosition?: 'leading' | 'trailing'
}


const messages: Message[] = [
  { role: 'assistant', content: 'Hi there! Ready to refine the new chat UI?' },
  { role: 'user', content: 'Yes, show me how the layout looks with sample content.' },
  { role: 'assistant', content: 'Here is a clean two-column layout with chat list and conversation details.' },
  { role: 'user', content: 'Perfect — that\'s exactly what I need.' },
]

export const Route = createFileRoute('/chat')({
  component: RouteComponent,
})

function RouteComponent() {
  const [menu, setMenu] = useState('Schedule meeting')
  const [selectedChatId, setSelectedChatId] = useState<number>(chats[0].id)
  const actions = [
    { key: 'schedule', label: 'Schedule meeting', Icon: CalendarDays },
    { key: 'location', label: 'Share location', Icon: MapPin },
    { key: 'group', label: 'Create group', Icon: Users },
    { key: 'search', label: 'Search', Icon: Search },
  ]
  const selectedChat = chats.find((c) => c.id === selectedChatId) ?? chats[0]

  return (
    <div className="h-screen w-full bg-slate-50">
      <div className="flex h-full w-full bg-white">
        <ChatList
          chats={chats}
          selectedChatId={selectedChatId}
          menu={menu}
          actions={actions}
          onMenuChange={setMenu}
          onSelectChat={setSelectedChatId}
        />
        <ChatDetails selectedChat={selectedChat} messages={messages} />
      </div>
    </div>
  )
}


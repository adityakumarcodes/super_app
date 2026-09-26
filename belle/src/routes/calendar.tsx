import { createFileRoute } from '@tanstack/react-router'
import { ChevronLeft, ChevronRight, Plus, Trash2, X } from 'lucide-react'
import { useEffect, useMemo, useState } from 'react'
import type { FormEvent } from 'react'

export const Route = createFileRoute('/calendar')({ component: RouteComponent })

type CalendarView = 'Month' | 'Week' | 'Day'
type CalendarCategory = 'Personal' | 'Work sync' | 'Health & Wellness' | 'Baking & Groceries'
type CalendarEvent = { id: string; title: string; date: string; time: string; category: CalendarCategory; description: string }
type EventDraft = Omit<CalendarEvent, 'id'>

const storageKey = 'belle-calendar-events'
const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
const categories: Array<{ name: CalendarCategory; color: string }> = [
    { name: 'Personal', color: 'bg-[#8fa77e]' },
    { name: 'Work sync', color: 'bg-[#4f4f4f]' },
    { name: 'Health & Wellness', color: 'bg-[#c5b36d]' },
    { name: 'Baking & Groceries', color: 'bg-[#d38d57]' },
]

function dateKey(date: Date) {
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
}

function dateFromKey(value: string) {
    const [year, month, day] = value.split('-').map(Number)
    return new Date(year, month - 1, day)
}

function formatTime(time: string) {
    const [hours, minutes] = time.split(':').map(Number)
    const suffix = hours >= 12 ? 'PM' : 'AM'
    return `${hours % 12 || 12}:${String(minutes).padStart(2, '0')} ${suffix}`
}

function getSeedEvents(): CalendarEvent[] {
    const now = new Date()
    const thisMonth = (day: number) => dateKey(new Date(now.getFullYear(), now.getMonth(), day))
    return [
        { id: 'calendar-seed-teatime', title: 'Teatime', date: thisMonth(6), time: '16:00', category: 'Personal', description: '' },
        { id: 'calendar-seed-groceries', title: 'Groceries', date: thisMonth(11), time: '10:00', category: 'Baking & Groceries', description: 'Tomatoes, Broccoli, Sourdough' },
        { id: 'calendar-seed-design-sync', title: 'Design sync', date: thisMonth(11), time: '14:00', category: 'Work sync', description: '' },
        { id: 'calendar-seed-baking', title: 'Baking class', date: thisMonth(19), time: '17:00', category: 'Baking & Groceries', description: 'Sourdough fermentation basics' },
        { id: 'calendar-seed-delivery', title: 'Weekly Grocery Delivery', date: dateKey(now), time: '10:00', category: 'Baking & Groceries', description: 'Tomatoes, Broccoli, Sourdough' },
    ]
}

function loadEvents(): CalendarEvent[] {
    try {
        const stored = localStorage.getItem(storageKey)
        if (!stored) return getSeedEvents()
        const value: unknown = JSON.parse(stored)
        if (!Array.isArray(value)) return getSeedEvents()
        const saved = value.filter((event): event is CalendarEvent => (
            typeof event === 'object' && event !== null
            && 'id' in event && typeof event.id === 'string'
            && 'title' in event && typeof event.title === 'string'
            && 'date' in event && typeof event.date === 'string'
            && 'time' in event && typeof event.time === 'string'
            && 'description' in event && typeof event.description === 'string'
            && 'category' in event && categories.some(({ name }) => name === event.category)
        ))
        return saved.length ? saved : getSeedEvents()
    } catch {
        return getSeedEvents()
    }
}

function getMonthDays(date: Date) {
    const firstDay = new Date(date.getFullYear(), date.getMonth(), 1)
    const gridStart = new Date(firstDay)
    gridStart.setDate(firstDay.getDate() - firstDay.getDay())
    return Array.from({ length: 42 }, (_, index) => {
        const day = new Date(gridStart)
        day.setDate(gridStart.getDate() + index)
        return day
    })
}

function getWeekDays(date: Date) {
    const start = new Date(date)
    start.setDate(date.getDate() - date.getDay())
    return Array.from({ length: 7 }, (_, index) => {
        const day = new Date(start)
        day.setDate(start.getDate() + index)
        return day
    })
}

function createDraft(date: string): EventDraft {
    return { title: '', date, time: '10:00', category: 'Personal', description: '' }
}

function EventChip({ event, onClick }: { event: CalendarEvent; onClick: () => void }) {
    return <button type="button" onClick={(click) => { click.stopPropagation(); onClick() }} className="mt-2 block max-w-full truncate rounded-[8px] theme-accent-bg px-2 py-1 text-left text-[0.72rem] font-medium text-[#1d1b1a] shadow-[inset_0_0_0_1px_rgba(0,0,0,0.06)]" title={`${event.title} at ${formatTime(event.time)}`}>{event.title}</button>
}

function RouteComponent() {
    const today = dateKey(new Date())
    const [events, setEvents] = useState<CalendarEvent[]>(loadEvents)
    const [view, setView] = useState<CalendarView>('Month')
    const [displayDate, setDisplayDate] = useState(() => new Date())
    const [selectedDate, setSelectedDate] = useState(today)
    const [selectedCategory, setSelectedCategory] = useState<CalendarCategory | null>(null)
    const [draft, setDraft] = useState<EventDraft>(() => createDraft(today))
    const [editingEventId, setEditingEventId] = useState<string | null>(null)
    const [isComposerOpen, setIsComposerOpen] = useState(false)
    const [formError, setFormError] = useState<string | null>(null)

    useEffect(() => {
        try { localStorage.setItem(storageKey, JSON.stringify(events)) } catch { /* Calendar remains usable for this session. */ }
    }, [events])

    const visibleEvents = useMemo(() => events
        .filter((event) => !selectedCategory || event.category === selectedCategory)
        .sort((left, right) => `${left.date}T${left.time}`.localeCompare(`${right.date}T${right.time}`)), [events, selectedCategory])
    const eventsByDate = useMemo(() => {
        const result = new Map<string, CalendarEvent[]>()
        visibleEvents.forEach((event) => result.set(event.date, [...(result.get(event.date) ?? []), event]))
        return result
    }, [visibleEvents])
    const upcomingEvents = useMemo(() => visibleEvents.filter((event) => event.date >= today).slice(0, 2), [today, visibleEvents])
    const monthDays = useMemo(() => getMonthDays(displayDate), [displayDate])
    const weekDaysForView = useMemo(() => getWeekDays(dateFromKey(selectedDate)), [selectedDate])
    const selectedDayEvents = eventsByDate.get(selectedDate) ?? []
    const monthTitle = new Intl.DateTimeFormat('en-US', { month: 'long', year: 'numeric' }).format(displayDate)
    const selectedDayTitle = new Intl.DateTimeFormat('en-US', { weekday: 'long', month: 'long', day: 'numeric' }).format(dateFromKey(selectedDate))

    const closeComposer = () => { setIsComposerOpen(false); setFormError(null) }
    const openNewEvent = (date = selectedDate) => { setEditingEventId(null); setDraft(createDraft(date)); setFormError(null); setIsComposerOpen(true) }
    const openEditEvent = (event: CalendarEvent) => {
        setEditingEventId(event.id)
        setDraft({ title: event.title, date: event.date, time: event.time, category: event.category, description: event.description })
        setFormError(null)
        setIsComposerOpen(true)
    }
    const selectDay = (date: Date) => { setSelectedDate(dateKey(date)); setDisplayDate(new Date(date.getFullYear(), date.getMonth(), 1)) }
    const moveMonth = (amount: number) => setDisplayDate((current) => new Date(current.getFullYear(), current.getMonth() + amount, 1))
    const saveEvent = (event: FormEvent<HTMLFormElement>) => {
        event.preventDefault()
        if (!draft.title.trim()) { setFormError('Add an event title to save it.'); return }
        const savedEvent: CalendarEvent = { ...draft, id: editingEventId ?? crypto.randomUUID(), title: draft.title.trim(), description: draft.description.trim() }
        setEvents((current) => editingEventId ? current.map((item) => item.id === editingEventId ? savedEvent : item) : [...current, savedEvent])
        setSelectedDate(savedEvent.date)
        setDisplayDate(dateFromKey(savedEvent.date))
        closeComposer()
    }
    const deleteEvent = () => { if (editingEventId) setEvents((current) => current.filter((event) => event.id !== editingEventId)); closeComposer() }
    const renderDayEvents = (date: Date) => {
        const items = eventsByDate.get(dateKey(date)) ?? []
        return <>{items.slice(0, 3).map((event) => <EventChip key={event.id} event={event} onClick={() => openEditEvent(event)} />)}
            {items.length > 3 && <button type="button" onClick={(click) => { click.stopPropagation(); selectDay(date); setView('Day') }} className="mt-2 block text-left text-[0.72rem] font-medium text-[#675f5b] underline">+{items.length - 3} more</button>}
        </>
    }

    return <div className="mx-auto flex max-w-[1400px] gap-8 px-4 py-6">
        <aside className="w-[290px] shrink-0 border-r border-[#d8d1c8] bg-[#f4f1ee] p-5 pt-8">
            <div className="mb-6 flex items-center gap-3"><h2 className="text-[2.1rem] leading-none text-[#1d1b1a]">Calendar</h2></div>
            <button type="button" onClick={() => openNewEvent()} className="mb-8 flex w-full items-center justify-center gap-2 rounded-full border border-[#2b2929] theme-accent-bg px-4 py-2.5 text-[1.02rem] font-medium shadow-[0_0_0_1px_rgba(0,0,0,0.08)]"><Plus size={16} />Add new event</button>

            <div><p className="mb-3 text-[0.76rem] font-medium uppercase tracking-[0.18em] text-[#6e665f]">Upcoming</p><div className="space-y-4">
                {upcomingEvents.length ? upcomingEvents.map((event) => <button key={event.id} type="button" onClick={() => openEditEvent(event)} className="block w-full rounded-[16px] border border-[#2b2929] bg-[#f7f4f0] p-3 text-left shadow-[0_0_0_1px_rgba(0,0,0,0.03)]">
                    <div className="mb-1 text-[0.7rem] font-medium uppercase tracking-[0.16em] text-[#675f5b]">{event.date === today ? `Today at ${formatTime(event.time)}` : `${new Intl.DateTimeFormat('en-US', { month: 'short', day: 'numeric' }).format(dateFromKey(event.date))} at ${formatTime(event.time)}`}</div>
                    <div className="text-[1.1rem] font-medium">{event.title}</div>{event.description && <div className="text-sm text-[#5e5754]">{event.description}</div>}
                </button>) : <p className="rounded-[16px] border border-dashed border-[#b8afa6] p-3 text-sm text-[#5e5754]">No upcoming events in this category.</p>}
            </div></div>
        </aside>

        <main className="flex-1 py-4">
            <div className="flex items-center justify-between gap-4 pb-6"><div className="flex items-center gap-2">
                <button type="button" onClick={() => moveMonth(-1)} className="rounded-full p-2 text-[#3f3a37] hover:bg-black/5" aria-label="Previous month"><ChevronLeft size={20} /></button>
                <h2 className="text-[3.4rem] leading-none text-[#1d1b1a]">{monthTitle}</h2>
                <button type="button" onClick={() => moveMonth(1)} className="rounded-full p-2 text-[#3f3a37] hover:bg-black/5" aria-label="Next month"><ChevronRight size={20} /></button>
            </div><div className="flex items-center gap-2 rounded-full border border-[#2d2a2a] bg-transparent p-1">
                    {(['Month', 'Week', 'Day'] as CalendarView[]).map((item) => <button key={item} type="button" onClick={() => setView(item)} className={`rounded-full px-4 py-2 text-[0.95rem] ${view === item ? 'theme-accent-bg text-[#1a1816]' : 'text-[#3f3a37]'}`} aria-pressed={view === item}>{item}</button>)}
                </div></div>

            {view === 'Month' && <div className="grid grid-cols-7 overflow-hidden rounded-[20px] border border-[#2d2a2a] bg-[#f7f4f0]">
                {weekDays.map((day) => <div key={day} className="border-b border-r border-[#2d2a2a] bg-[#f3efe9] px-3 py-3 text-center text-[0.98rem] font-medium text-[#1d1b1a] last:border-r-0">{day}</div>)}
                {monthDays.map((day, index) => {
                    const key = dateKey(day); const isToday = key === today
                    return <div key={key} role="button" tabIndex={0} onClick={() => selectDay(day)} onKeyDown={(event) => { if (event.key === 'Enter' || event.key === ' ') selectDay(day) }} className={`relative min-h-[140px] border-b border-r border-[#2d2a2a] p-2 text-left ${day.getMonth() === displayDate.getMonth() ? 'bg-[#f7f4f0] text-[#1e1d1c]' : 'bg-[#eee9e3] text-[#8c837b]'} ${index % 7 === 6 ? 'border-r-0' : ''} ${key === selectedDate ? 'ring-2 ring-inset ring-[#2d2a2a]' : ''}`} aria-label={`Select ${day.toLocaleDateString()}`}>
                        <div className={`inline-flex h-7 min-w-7 items-center justify-center rounded-full px-1 text-[0.95rem] font-medium ${isToday ? 'theme-accent-bg' : ''}`}>{day.getDate()}</div>{renderDayEvents(day)}
                    </div>
                })}
            </div>}

            {view === 'Week' && <div className="grid grid-cols-7 overflow-hidden rounded-[20px] border border-[#2d2a2a] bg-[#f7f4f0]">
                {weekDaysForView.map((day, index) => {
                    const key = dateKey(day)
                    return <div key={key} role="button" tabIndex={0} onClick={() => selectDay(day)} onKeyDown={(event) => { if (event.key === 'Enter' || event.key === ' ') selectDay(day) }} className={`min-h-[430px] border-r bg-[#f7f4f0] p-3 text-left text-[#1e1d1c] ${index === 6 ? 'border-r-0' : 'border-[#2d2a2a]'} ${key === selectedDate ? 'ring-2 ring-inset ring-[#2d2a2a]' : ''}`}>
                        <div className="mb-3 text-center"><div className="text-[0.8rem] uppercase tracking-[0.14em] text-[#6e665f]">{weekDays[index]}</div><div className={`mx-auto mt-1 flex h-8 w-8 items-center justify-center rounded-full font-medium ${key === today ? 'theme-accent-bg' : ''}`}>{day.getDate()}</div></div>{renderDayEvents(day)}
                    </div>
                })}
            </div>}

            {view === 'Day' && <section className="min-h-[430px] rounded-[20px] border border-[#2d2a2a] bg-[#f7f4f0] p-6"><div className="mb-6 flex items-center justify-between gap-4 border-b border-[#d8d1c8] pb-5"><div><p className="text-[0.76rem] font-medium uppercase tracking-[0.18em] text-[#6e665f]">Schedule</p><h3 className="mt-1 text-3xl text-[#1d1b1a]">{selectedDayTitle}</h3></div><button type="button" onClick={() => openNewEvent(selectedDate)} className="rounded-full border border-[#2b2929] theme-accent-bg px-4 py-2 text-sm font-medium">Add event</button></div>
                {selectedDayEvents.length ? <div className="space-y-3">{selectedDayEvents.map((event) => <button key={event.id} type="button" onClick={() => openEditEvent(event)} className="flex w-full items-start gap-4 rounded-[16px] border border-[#2b2929] bg-[#f3efe9] p-4 text-left"><time className="shrink-0 text-sm font-medium text-[#675f5b]">{formatTime(event.time)}</time><span><span className="block text-lg font-medium text-[#1d1b1a]">{event.title}</span>{event.description && <span className="mt-1 block text-sm text-[#5e5754]">{event.description}</span>}</span></button>)}</div> : <div className="flex min-h-[250px] items-center justify-center rounded-[16px] border border-dashed border-[#b8afa6] text-center text-[#5e5754]"><div><p>No events planned.</p><button type="button" onClick={() => openNewEvent(selectedDate)} className="mt-3 text-sm font-medium underline">Add the first event</button></div></div>}
            </section>}
        </main>

        {isComposerOpen && <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/25 p-4" role="presentation"><section className="w-full max-w-md rounded-[20px] border border-[#2b2929] bg-[#f7f4f0] p-5 shadow-xl" role="dialog" aria-modal="true" aria-label={editingEventId ? 'Edit event' : 'Add new event'}>
            <div className="mb-5 flex items-center justify-between gap-4"><h3 className="text-3xl text-[#1d1b1a]">{editingEventId ? 'Edit event' : 'Add new event'}</h3><button type="button" onClick={closeComposer} className="rounded-full p-2 text-[#3f3a37] hover:bg-black/5" aria-label="Close event form"><X size={20} /></button></div>
            <form onSubmit={saveEvent} className="space-y-4">
                <label className="block text-sm font-medium text-[#3f3a37]">Title<input autoFocus value={draft.title} onChange={(event) => setDraft((current) => ({ ...current, title: event.target.value }))} className="mt-1.5 w-full rounded-[10px] border border-[#b8afa6] bg-white px-3 py-2 outline-none focus:border-[#2b2929]" placeholder="Event title" /></label>
                <div className="grid grid-cols-2 gap-3"><label className="block text-sm font-medium text-[#3f3a37]">Date<input type="date" value={draft.date} onChange={(event) => setDraft((current) => ({ ...current, date: event.target.value }))} className="mt-1.5 w-full rounded-[10px] border border-[#b8afa6] bg-white px-3 py-2 outline-none focus:border-[#2b2929]" /></label><label className="block text-sm font-medium text-[#3f3a37]">Time<input type="time" value={draft.time} onChange={(event) => setDraft((current) => ({ ...current, time: event.target.value }))} className="mt-1.5 w-full rounded-[10px] border border-[#b8afa6] bg-white px-3 py-2 outline-none focus:border-[#2b2929]" /></label></div>
                <label className="block text-sm font-medium text-[#3f3a37]">Category<select value={draft.category} onChange={(event) => setDraft((current) => ({ ...current, category: event.target.value as CalendarCategory }))} className="mt-1.5 w-full rounded-[10px] border border-[#b8afa6] bg-white px-3 py-2 outline-none focus:border-[#2b2929]">{categories.map((category) => <option key={category.name} value={category.name}>{category.name}</option>)}</select></label>
                <label className="block text-sm font-medium text-[#3f3a37]">Notes <span className="font-normal text-[#6e665f]">(optional)</span><textarea value={draft.description} onChange={(event) => setDraft((current) => ({ ...current, description: event.target.value }))} rows={3} className="mt-1.5 w-full resize-none rounded-[10px] border border-[#b8afa6] bg-white px-3 py-2 outline-none focus:border-[#2b2929]" placeholder="Add details" /></label>
                {formError && <p className="text-sm text-red-700">{formError}</p>}<div className="flex items-center justify-between gap-3 pt-1">{editingEventId ? <button type="button" onClick={deleteEvent} className="inline-flex items-center gap-2 rounded-full px-3 py-2 text-sm text-[#8a3029] hover:bg-[#f1dfdc]"><Trash2 size={16} />Delete</button> : <span />}<button type="submit" className="rounded-full border border-[#2b2929] theme-accent-bg px-4 py-2 text-sm font-medium">Save event</button></div>
            </form>
        </section></div>}
    </div>
}
import { createFileRoute } from '@tanstack/react-router'
import { Plus } from 'lucide-react'

export const Route = createFileRoute('/calendar')({
    component: RouteComponent,
})

const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']

const calendarDays = [
    [26, 27, 28, 29, 30, 31, 1],
    [2, 3, 4, 5, 6, 7, 8],
    [9, 10, 11, 12, 13, 14, 15],
    [16, 17, 18, 19, 20, 21, 22],
    [23, 24, 25, 26, 27, 28, 29],
    [30, 31, 1, 2, 3, 4, 5],
]

const events = [
    { day: 6, label: 'Teatime', kind: 'peach' },
    { day: 11, label: 'Groceries', kind: 'peach' },
    { day: 11, label: 'Design sync', kind: 'peach' },
    { day: 19, label: 'Baking class', kind: 'peach' },
]

function RouteComponent() {
    return (

        <div className="mx-auto px-4 py-6 flex max-w-[1400px] gap-8">
            <aside className="w-[290px] shrink-0 border-r border-[#d8d1c8] bg-[#f4f1ee] p-5 pt-8">
                <div className="mb-6 flex items-center gap-3">
                    <h2 className="text-[2.1rem] leading-none text-[#1d1b1a]">Calendar</h2>
                </div>

                <button className="mb-8 flex w-full items-center justify-center gap-2 rounded-full border border-[#2b2929] theme-accent-bg px-4 py-2.5 text-[1.02rem] font-medium shadow-[0_0_0_1px_rgba(0,0,0,0.08)]">
                    <Plus size={16} />
                    Add new event
                </button>

                <div className="mb-8">
                    <p className="mb-3 text-[0.76rem] font-medium uppercase tracking-[0.18em] text-[#6e665f]">Categories</p>
                    <div className="space-y-3 text-[1.02rem] text-[#1d1b1a]">
                        <div className="flex items-center gap-2"><span className="h-2.5 w-2.5 rounded-full bg-[#8fa77e]" /> Personal</div>
                        <div className="flex items-center gap-2"><span className="h-2.5 w-2.5 rounded-full bg-[#4f4f4f]" /> Work sync</div>
                        <div className="flex items-center gap-2"><span className="h-2.5 w-2.5 rounded-full bg-[#c5b36d]" /> Health & Wellness</div>
                        <div className="flex items-center gap-2"><span className="h-2.5 w-2.5 rounded-full bg-[#d38d57]" /> Baking & Groceries</div>
                    </div>
                </div>

                <div>
                    <p className="mb-3 text-[0.76rem] font-medium uppercase tracking-[0.18em] text-[#6e665f]">Upcoming</p>
                    <div className="space-y-4">
                        <div className="rounded-[16px] border border-[#2b2929] bg-[#f7f4f0] p-3 shadow-[0_0_0_1px_rgba(0,0,0,0.03)]">
                            <div className="mb-1 text-[0.7rem] font-medium uppercase tracking-[0.16em] text-[#675f5b]">Today at 10:00 AM</div>
                            <div className="text-[1.1rem] font-medium">Weekly Grocery Delivery</div>
                            <div className="text-sm text-[#5e5754]">Tomatoes, Broccoli, Sourdough</div>
                        </div>

                        <div className="rounded-[16px] border border-[#2b2929] bg-[#f7f4f0] p-3 shadow-[0_0_0_1px_rgba(0,0,0,0.03)]">
                            <div className="mb-1 text-[0.7rem] font-medium uppercase tracking-[0.16em] text-[#675f5b]">Friday, Oct 18</div>
                            <div className="text-[1.1rem] font-medium">Artisanal Baking Class</div>
                            <div className="text-sm text-[#5e5754]">Sourdough fermentation basics</div>
                        </div>
                    </div>
                </div>
            </aside>

            <main className="flex-1 py-4">
                <div className="flex items-center justify-between gap-4 pb-6">
                    <h2 className="text-[3.4rem] leading-none text-[#1d1b1a]">October</h2>
                    <div className="flex items-center gap-2 rounded-full border border-[#2d2a2a] bg-transparent p-1">
                        {['Month', 'Week', 'Day'].map((view, index) => (
                            <button
                                key={view}
                                className={`rounded-full px-4 py-2 text-[0.95rem] ${index === 0 ? 'theme-accent-bg text-[#1a1816]' : 'text-[#3f3a37]'
                                    }`}
                            >
                                {view}
                            </button>
                        ))}
                    </div>
                </div>

                <div className="grid grid-cols-7 overflow-hidden rounded-[20px] border border-[#2d2a2a] bg-[#f7f4f0]">
                    {weekDays.map((day) => (
                        <div key={day} className="border-b border-r border-[#2d2a2a] bg-[#f3efe9] px-3 py-3 text-center text-[0.98rem] font-medium text-[#1d1b1a] last:border-r-0">
                            {day}
                        </div>
                    ))}

                    {calendarDays.flat().map((day, index) => {
                        const event = events.find((eventItem) => eventItem.day === day)

                        return (
                            <div
                                key={`${day}-${index}`}
                                className={`relative min-h-[140px] border-r border-b border-[#2d2a2a] bg-[#f7f4f0] p-2 text-[#1e1d1c] ${index % 7 === 6 ? 'border-r-0' : ''
                                    }`}
                            >
                                <div className="text-[0.95rem] font-medium">{day}</div>

                                {event && (
                                    <div className="mt-2 inline-flex max-w-full items-center rounded-[8px] theme-accent-bg px-2 py-1 text-[0.72rem] font-medium text-[#1d1b1a] shadow-[inset_0_0_0_1px_rgba(0,0,0,0.06)]">
                                        {event.label}
                                    </div>
                                )}
                            </div>
                        )
                    })}
                </div>
            </main>
        </div>

    )
}

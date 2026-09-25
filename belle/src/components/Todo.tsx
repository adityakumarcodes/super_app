
import { Check, ListTodo, Plus, X } from 'lucide-react'
import { useState } from 'react'

type Todo = {
    id: string
    label: string
    done: boolean
}

const storageKey = 'belle-home-todos'

function readTodos(): Todo[] {
    try {
        const value = localStorage.getItem(storageKey)
        return value ? JSON.parse(value) as Todo[] : []
    } catch {
        return []
    }
}

export default function Todo() {
    const [todos, setTodos] = useState<Todo[]>(readTodos)
    const [draft, setDraft] = useState('')

    const updateTodos = (next: Todo[]) => {
        setTodos(next)
        localStorage.setItem(storageKey, JSON.stringify(next))
    }

    const addTodo = () => {
        const label = draft.trim()
        if (!label) return
        updateTodos([{ id: crypto.randomUUID(), label, done: false }, ...todos])
        setDraft('')
    }

    const completed = todos.filter((todo) => todo.done).length

    return (
        <section id="home-todos" className="surface-card mx-auto mt-5 max-w-5xl p-4 sm:p-6">
            <header className="flex items-center justify-between gap-4 border-b border-subtle pb-4">
                <div className="flex items-center gap-3">
                    <span className="theme-accent-soft flex h-10 w-10 items-center justify-center rounded-full border border-strong"><ListTodo size={20} /></span>
                    <div>
                        <p className="text-sm text-secondary">Keep momentum</p>
                        <h2 className="font-bodoni text-3xl leading-none">Today’s to-dos</h2>
                    </div>
                </div>
                <span className="control-pill border border-subtle px-3 py-1 text-sm text-secondary">{completed}/{todos.length} done</span>
            </header>

            <form onSubmit={(event) => { event.preventDefault(); addTodo() }} className="mt-4 flex gap-2">
                <input value={draft} onChange={(event) => setDraft(event.target.value)} placeholder="Add a task" aria-label="New task" className="surface-raised min-w-0 flex-1 rounded-xl px-3 py-2.5 outline-none focus:border-[var(--theme-accent)]" />
                <button type="submit" className="theme-accent-bg control-pill inline-flex shrink-0 items-center gap-2 border border-strong px-4 py-2.5 font-medium"><Plus size={18} />Add</button>
            </form>

            {todos.length === 0 ? (
                <p className="py-8 text-center text-sm text-secondary">Nothing on the list yet. Add one small next step.</p>
            ) : (
                <ul className="mt-4 space-y-2">
                    {todos.map((todo) => (
                        <li key={todo.id} className="surface-raised flex items-center gap-3 rounded-xl px-3 py-2.5">
                            <button type="button" onClick={() => updateTodos(todos.map((item) => item.id === todo.id ? { ...item, done: !item.done } : item))} className={`flex h-6 w-6 shrink-0 items-center justify-center rounded-full border border-strong ${todo.done ? 'theme-accent-bg' : 'bg-transparent'}`} aria-label={todo.done ? `Mark ${todo.label} incomplete` : `Mark ${todo.label} complete`}>
                                {todo.done && <Check size={15} />}
                            </button>
                            <span className={`min-w-0 flex-1 ${todo.done ? 'text-secondary line-through' : 'text-primary'}`}>{todo.label}</span>
                            <button type="button" onClick={() => updateTodos(todos.filter((item) => item.id !== todo.id))} className="rounded-full p-1 text-secondary hover:bg-black/5 hover:text-primary" aria-label={`Remove ${todo.label}`}><X size={17} /></button>
                        </li>
                    ))}
                </ul>
            )}
        </section>
    )
}





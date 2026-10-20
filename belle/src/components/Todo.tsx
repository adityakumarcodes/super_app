import { Check, Plus, X } from 'lucide-react'
import { useEffect, useState } from 'react'

type Todo = {
    id: string
    label: string
    done: boolean
}

const storageKey = 'belle-home-todos'

function readTodos(): Todo[] {
    try {
        const parsed = JSON.parse(localStorage.getItem(storageKey) ?? '[]')
        return Array.isArray(parsed) ? parsed : []
    } catch {
        return []
    }
}

type TodoRowProps = {
    todo: Todo
    onToggle: (id: string) => void
    onRemove: (id: string) => void
}

function TodoRow({ todo, onToggle, onRemove }: TodoRowProps) {
    return (
        <li className="surface-raised flex items-center gap-3 rounded-xl px-3 py-2.5">
            <button
                type="button"
                onClick={() => onToggle(todo.id)}
                aria-label={todo.done ? `Mark ${todo.label} incomplete` : `Mark ${todo.label} complete`}
                className={`flex h-6 w-6 shrink-0 items-center justify-center rounded-full border border-strong ${todo.done ? 'theme-accent-bg' : 'bg-transparent'}`}
            >
                {todo.done && <Check size={15} />}
            </button>
            <span className={`min-w-0 flex-1 ${todo.done ? 'text-secondary line-through' : 'text-primary'}`}>{todo.label}</span>
            <button
                type="button"
                onClick={() => onRemove(todo.id)}
                aria-label={`Remove ${todo.label}`}
                className="rounded-full p-1 text-secondary hover:bg-black/5 hover:text-primary"
            >
                <X size={17} />
            </button>
        </li>
    )
}

export default function Todo() {
    const [todos, setTodos] = useState<Todo[]>(readTodos)
    const [draft, setDraft] = useState('')

    useEffect(() => {
        try {
            localStorage.setItem(storageKey, JSON.stringify(todos))
        } catch {
            return
        }
    }, [todos])

    const addTodo = () => {
        const label = draft.trim()
        if (!label) return
        setTodos((current) => [{ id: crypto.randomUUID(), label, done: false }, ...current])
        setDraft('')
    }

    const toggleTodo = (id: string) =>
        setTodos((current) => current.map((todo) => todo.id === id ? { ...todo, done: !todo.done } : todo))

    const removeTodo = (id: string) =>
        setTodos((current) => current.filter((todo) => todo.id !== id))

    const completed = todos.filter((todo) => todo.done).length

    return (
        <section className="surface-card p-4">
            <form onSubmit={(event) => { event.preventDefault(); addTodo() }} className="flex gap-2">
                <input
                    value={draft}
                    onChange={(event) => setDraft(event.target.value)}
                    placeholder={`Add a task | ${completed}/${todos.length} done`}
                    aria-label="New task"
                    className="surface-raised min-w-0 flex-1 rounded-xl px-3 py-2.5 outline-none focus:border-[var(--theme-accent)]"
                />
                <button type="submit" className="theme-accent-bg control-pill inline-flex shrink-0 items-center gap-2 border border-strong px-4 py-2.5 font-medium">
                    <Plus size={18} />Add
                </button>
            </form>

            {todos.length === 0 ? (
                <p className="py-8 text-center text-sm text-secondary">Nothing on the list yet. Add one small next step.</p>
            ) : (
                <ul className="mt-4 space-y-2">
                    {todos.map((todo) => (
                        <TodoRow key={todo.id} todo={todo} onToggle={toggleTodo} onRemove={removeTodo} />
                    ))}
                </ul>
            )}
        </section>
    )
}

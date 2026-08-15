import { Link } from "@tanstack/react-router";
import { useState } from "react";
import useFetchQuery from '../utils/useFetchQuery'
import Spinner from "./Spinner";

type Note = {
    id: number | string
    title?: string
    description?: string
    imageUrl?: string
}
type NotesCategory = 'All' | 'Technology' | 'Startup' | 'Lifestyle';
const images = import.meta.glob(
    "../assets/images/notes/*.{jpg,jpeg,jfif,png}",
    {
        eager: true,
        import: "default",
    },
) as Record<string, string>;

export default function NotesList() {
    const [menu, setMenu] = useState<NotesCategory>('All');
    const BASE = (import.meta.env.VITE_API_BASE as string) || 'http://localhost:3000/api'
    const { data: pages = [], isLoading } = useFetchQuery<Note[]>({ queryKey: ['notes'], queryLink: `${BASE}/notes` })

    if (isLoading) return <Spinner />;

    return (<>
        <div className="flex flex-wrap justify-center gap-6 my-10">
            {(['All', 'Technology', 'Startup', 'Lifestyle'] as const).map((item) => (
                <button
                    key={item}
                    onClick={() => setMenu(item)}
                    className={menu === item ? 'bg-orange-200 py-2 px-4 rounded-full border-2' : 'border-2 py-2 px-4 rounded-full'}
                >
                    {item}
                </button>
            ))}
        </div>
        <div className="grid gap-2 p-2 grid-cols-4">
            {pages.map((note: Note) => {
                const imageName = note.imageUrl?.split('/').pop();
                const localImage = imageName
                    ? images[`../assets/images/notes/${imageName}`]
                    : undefined;
                const remoteImage = note.imageUrl && !note.imageUrl.includes('localhost')
                    ? note.imageUrl
                    : undefined;
                const image = localImage ?? remoteImage;

                return (
                    <Link
                        key={note.id}
                        to="/notes/$noteId"
                        params={{ noteId: String(note.id) }}
                        search={{ title: note.title }}
                        className="m-2 cursor-pointer border-2">
                        {image ? (
                            <img
                                src={image}
                                alt={note.title || `Note ${note.id}`}
                                loading="lazy"
                                className="w-full aspect-square object-cover"
                            // fix for img jumping is give img size 
                            />
                        ) : (
                            <div className="p-4">
                                <h2 className="mb-2 text-xl">
                                    {note.title || `Note ${note.id}`}
                                </h2>

                                <p className="line-clamp-3">
                                    {note.description || 'No description provided.'}
                                </p>
                            </div>
                        )}
                    </Link>
                );
            })}
        </div></>
    );
}

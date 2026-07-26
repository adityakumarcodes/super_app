import { Link } from '@tanstack/react-router';

interface NoteItemProps {
    image: string;
    category: string;
    title: string;
    description: string;
    id: string | number;
    author: string;
    authorImg: string;
}

const NoteItem = (props: NoteItemProps) => {

    return (
        <div>
            <div className="flex max-w-125 bg-white border-2 border-black hover:shadow-xl rounded-md select-none">
                <div className="w-2/5">
                    <Link
                        to="/notes/$noteId"
                        params={{ noteId: String(props.id) }}
                        search={{ title: props.title, description: props.description }}
                    >
                        <img
                            src={props.image}
                            alt={props.title}
                            className="rounded-l-md object-cover w-full h-full"
                            loading="lazy"
                        />
                    </Link>
                </div>
                <div className="w-3/5 p-5">
                    <Link
                        to="/notes/$noteId"
                        params={{ noteId: String(props.id) }}
                        search={{ title: props.title, description: props.description }}
                    >
                        <p className="inline-block mb-2 px-2 py-1 bg-orange-200 text-sm rounded-full">{props.category}</p>
                        <h5 className="mb-2 text-lg font-medium tracking-tight text-gray-900">{props.title}</h5>
                        <p className="mb-3 text-sm tracking-tight text-gray-700 line-clamp-3">{props.description}</p>
                        <div className="inline-flex items-center py-2">Read more...</div>
                    </Link>
                </div>
            </div>

        </div>
    );
};

export default NoteItem;

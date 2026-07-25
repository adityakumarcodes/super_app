import { useMemo, useState } from 'react';
import NoteItem from './NoteItem';
import { BLOGS } from '../constants/blogs';

type NotesCategory = 'All' | 'Technology' | 'Startup' | 'Lifestyle';

const NoteList = () => {
    const [menu, setMenu] = useState<NotesCategory>('All');

    const filteredBlogs = useMemo(() => {
        if (menu === 'All') {
            return BLOGS;
        }

        return BLOGS.filter((item) => item.category === menu);
    }, [menu]);

    return (
        <div>
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

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-2 gap-y-10 mb-16 mx-4 justify-items-center">
                {filteredBlogs.length > 0 ? (
                    filteredBlogs.map((item) => (
                        <NoteItem
                            key={item.id}
                            id={item.id}
                            image={item.image}
                            category={item.category}
                            title={item.title}
                            description={item.description}
                            author={item.author}
                            authorImg={item.authorImg}
                        />
                    ))
                ) : (
                    <h6>No blogs found.</h6>
                )}
            </div>
        </div>
    );
};

export default NoteList;

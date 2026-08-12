import { useState } from "react";
import useFetchQuery from "../utils/useFetchQuery";

interface Word {
    id: number;
    word: string;
    meaning: string;
}

const WordOfTheDay = () => {
    const [counter, setCounter] = useState(0);

    const BASE =
        (import.meta.env.VITE_API_BASE as string) ||
        `http://localhost:${import.meta.env.VITE_BACKEND_PORT || 3000
        }/api`;

    const { data } = useFetchQuery<Word[]>({
        queryKey: ["wotd"],
        queryLink: `${BASE}/word-of-the-day`,
        queryOptions: {
            throwOnError: true,
        },
    });

    const words = data ?? [];
    const currentWord = words[counter];

    return (
        <div
            className="select-none flex items-center text-center justify-center flex-col bg-cover rounded-[50px] m-2 p-5 text-white transition-all duration-150 hover:cursor-pointer"
            onClick={() =>
                words.length > 1 &&
                setCounter((prev) => (prev + 1) % words.length)
            }
            style={{
                backgroundImage:
                    'linear-gradient(rgba(0, 0, 0, 0.527), rgba(0, 0, 0, 0.5)), url("https://images.unsplash.com/photo-1536147116438-62679a5e01f2?auto=format&fit=crop&q=60&w=600")',
            }}
        >
            <h1
                style={{ fontFamily: "Dancing Script" }}
                className="text-6xl m-2.5"
            >
                {currentWord?.word}
            </h1>

            <h6 className="text-xl text-balance">
                {currentWord?.meaning}
            </h6>

            <div className="mt-10" />
        </div>
    );
};

export default WordOfTheDay;
import { useState, useEffect } from "react";
import { useErrorBoundary } from "react-error-boundary";

interface Word {
    id: number;
    word: string;
    meaning: string;
}


const WordOfTheDay = () => {
    const [data, setData] = useState<Word[]>([]);
    const [counter, setCounter] = useState(0);
    const { showBoundary } = useErrorBoundary();

    useEffect(() => {
        const loadWords = async () => {
            const response = await fetch("http://localhost:3000/word-of-the-day");
            if (!response.ok) {
                throw new Error(`Failed to fetch words: ${response.status} ${response.statusText}`);
            }

            const words = await response.json();
            setData(words ?? []);
        };

        loadWords().catch((err) => {
            showBoundary(err instanceof Error ? err : new Error(String(err)));
        });
    }, [showBoundary]);

    const currentWord = data[counter];

    return (
        <div
            className="select-none flex items-center text-center justify-center flex-col bg-cover rounded-[50px] m-2 p-5 text-white transition-all duration-150 hover:cursor-pointer"
            onClick={() => data.length > 1 && setCounter((prev) => (prev + 1) % data.length)}
            style={{
                backgroundImage: 'linear-gradient(rgba(0, 0, 0, 0.527), rgba(0, 0, 0, 0.5)), url("https://images.unsplash.com/photo-1536147116438-62679a5e01f2?auto=format&fit=crop&q=60&w=600")'
            }}
        >
            <h1 style={{ fontFamily: "Dancing Script" }} className="text-6xl m-2.5">
                {currentWord?.word}
            </h1>
            <h6 className="text-xl text-balance">{currentWord?.meaning}</h6>
            <div className="mt-10" />
        </div>
    );
};

export default WordOfTheDay;
import { supabase } from "../supabase";
import { useState, useEffect } from "react";
import { useErrorBoundary } from "react-error-boundary";
import { WORDS_DATA } from "../constants/words";

interface Word {
    id: number;
    word: string;
    meaning: string;
}


const WordOfTheDay = () => {
    // Initialize with local array so `data[counter]` is safe from line 1
    const [data, setData] = useState<Word[]>(WORDS_DATA);
    const [counter, setCounter] = useState(0);
    const { showBoundary } = useErrorBoundary();

    useEffect(() => {
        const fetchWords = async () => {
            try {
                const { data: words, error } = await supabase
                    .from('words')
                    .select('*');

                if (error) throw error;
                if (words && words.length > 0) setData(words);
            } catch (err) {
                // Catch async Supabase errors and hand them off to your ErrorBoundary
                showBoundary(err instanceof Error ? err : new Error(String(err)));
            }
        };

        fetchWords();
    }, [showBoundary]);

    // Fast reference pointer safely bounds checks the current active array length
    const currentWord = data[counter];

    return (
        <div
            className="select-none flex items-center text-center justify-center flex-col bg-cover rounded-[50px] m-2 p-5 text-white transition-all duration-150 hover:cursor-pointer"
            onClick={() => setCounter((prev) => (prev + 1) % data.length)}
            style={{
                backgroundImage: 'linear-gradient(rgba(0, 0, 0, 0.527), rgba(0, 0, 0, 0.5)), url("https://images.unsplash.com/photo-1536147116438-62679a5e01f2?auto=format&fit=crop&q=60&w=600")'
            }}
        >
            <h1 style={{ fontFamily: "Dancing Script" }} className="text-6xl m-2.5">
                {currentWord?.word}
            </h1>
            <h6 className="text-xl">{currentWord?.meaning}</h6>
            <div className="mt-10" />
        </div>
    );
};

export default WordOfTheDay;
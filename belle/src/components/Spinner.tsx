const Spinner = ({ msg = 'Loading' }) => {
    return (
        <div className="w-full flex flex-col items-center justify-center m-4 p-4">
            <div className="relative w-10 aspect-square animate-[spin_1s_infinite]">
                <div className="absolute top-0 left-1/2 -translate-x-1/2 w-2.5 h-2.5 rounded-full bg-orange-400" />
                <div className="absolute left-0 top-1/2 -translate-y-1/2 w-2.5 h-2.5 rounded-full bg-orange-400" />
                <div className="absolute right-0 top-1/2 -translate-y-1/2 w-2.5 h-2.5 rounded-full bg-orange-400" />
                <div className="absolute bottom-0 left-1/2 -translate-x-1/2 w-2.5 h-2.5 rounded-full bg-orange-400" />
            </div>

            <p className="text-lg">{msg}</p>
        </div>
    );
};

export default Spinner;
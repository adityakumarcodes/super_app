const Skeleton = ({ count }: { count: number }) => {
    return (
        <ul>
            {Array.from({ length: count }).map((_, index) => (
                <li key={index} className="ml-2 animate-pulse">
                    <div className="flex items-center space-x-2 p-2 rounded-md">
                        <div className="w-6 h-6 bg-gray-300 rounded-full mr-2"></div>
                        <div className="h-4 bg-gray-300 rounded-sm w-32"></div>
                    </div>
                </li>
            ))}
        </ul>
    );
};

export default Skeleton;
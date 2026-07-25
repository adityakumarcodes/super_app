import { ChevronRight, Plus, FileText, Pin } from "lucide-react";
import { useEffect, useState } from "react";
import HoverText from "./HoverText";
import Skeleton from "./Skeleton";

interface FolderType {
    title: string;
    id: number;
    folders: FolderType[];
    parent_id: number | null;
}

const initialFolders: FolderType[] = [
    {
        id: 1,
        title: "Book1",
        parent_id: null,
        folders: [
            {
                id: 2,
                title: "Movie",
                parent_id: 1,
                folders: [
                    {
                        id: 3,
                        title: "Action",
                        parent_id: 2,
                        folders: [
                            {
                                id: 4,
                                title: "2000s",
                                parent_id: 3,
                                folders: [
                                    { id: 5, title: "Hera pheri", parent_id: 4, folders: [] },
                                    { id: 6, title: "Welcome", parent_id: 4, folders: [] },
                                ],
                            },
                            { id: 7, title: "2010s", parent_id: 3, folders: [] },
                        ],
                    },
                    { id: 8, title: "Comedy", parent_id: 2, folders: [] },
                ],
            },
            {
                id: 9,
                title: "Music",
                parent_id: 1,
                folders: [
                    { id: 10, title: "Rock", parent_id: 9, folders: [] },
                    { id: 11, title: "Classical", parent_id: 9, folders: [] },
                ],
            },
            { id: 12, title: "Pics", parent_id: 1, folders: [] },
        ],
    },
    {
        id: 13,
        title: "Book2",
        parent_id: null,
        folders: [
            { id: 14, title: "Chapter 1", parent_id: 13, folders: [] },
            { id: 15, title: "Chapter 2", parent_id: 13, folders: [] },
        ],
    },
    { id: 16, title: "Book3", parent_id: null, folders: [] },
];

const Tree = () => {
    const [folders] = useState<FolderType[]>(initialFolders);
    const [loading, setLoading] = useState(true);


    // // transforms a flat list of folders into a nested tree structure.
    // const buildNestedFoldersMap = (flatList: FolderType[]): FolderType[] => {
    //     const idMap = new Map<number, FolderType>(flatList.map(folder => [folder.id, { ...folder, folders: [] }]));
    //     const tree: FolderType[] = [];

    //     flatList.forEach(folder => {
    //         const currentFolder = idMap.get(folder.id);
    //         if (!currentFolder) return;
    //         if (folder.parent_id === null) {
    //             tree.push(currentFolder);//root folder, push to tree array
    //         } else {
    //             idMap.get(folder.parent_id)?.folders.push(currentFolder);// find its parent in idMap and add it to its folders[]
    //         }
    //     });
    //     return tree;
    // };

    useEffect(() => {
        const timer = window.setTimeout(() => setLoading(false), 2000);
        return () => window.clearTimeout(timer);
    }, []);

    const addFolder = async (parentId: number | null) => {
        console.log("Adding folder under parent ID:", parentId);
    };

    return (
        <ul>
            {loading ? <Skeleton count={6} /> : folders?.map((folder) => (
                <Folder key={folder.id} folder={folder} addFolder={addFolder} />
            ))}
        </ul>
    );
};

interface FolderProps {
    folder: FolderType;
    addFolder: (parentId: number | null) => void;
}

const Folder = ({ folder, addFolder }: FolderProps) => {
    const [isOpen, setIsOpen] = useState(false);

    return <li className="ml-2">
        <span className={`flex items-start justify-between group hover:bg-gray-200 rounded-md ${isOpen ? 'bg-gray-200' : ''}`}>
            <div className="flex gap-1.5 items-center">
                <ChevronRight strokeWidth={1.25} onClick={() => setIsOpen(!isOpen)} className={`ml-1 transition-transform duration-200 group-hover:inline hidden m-1 text-gray-500 hover:bg-gray-300 rounded-md ${isOpen ? 'rotate-90' : ''}`} />
                {folder.folders && folder.folders.length === 0 ? <FileText strokeWidth={1.25} className="text-gray-500 inline group-hover:hidden ml-2 w-6 h-6 " /> : <p className="ml-2 w-6 h-6 inline group-hover:hidden">🧠</p>}
                <a href={`/admin/notebook/${folder.id}`}>
                    <p className="line-clamp-1 select-none">{folder.title}</p>
                </a>
            </div>
            <div className="flex ">
                <HoverText msg="Pin" dir={"bottom"}>
                    <Pin strokeWidth={1.5} className={`group-hover:opacity-100 opacity-0 m-1 text-gray-500 hover:bg-gray-300 rounded-md`} />
                </HoverText>
                <HoverText msg="Add a page inside" dir={"bottom"}>
                    <Plus strokeWidth={1.5} className={`group-hover:opacity-100 opacity-0 m-1 text-gray-500 hover:bg-gray-300 rounded-md`} onClick={() => addFolder(folder.id)} />
                </HoverText>
            </div>
        </span>
        {isOpen && folder.folders && folder.folders.length === 0 && <p className="text-gray-400 ml-6">No pages inside</p>}
        {isOpen && <ul>{folder.folders?.map(subFolder => <Folder folder={subFolder} key={subFolder.title} addFolder={addFolder} />)}</ul>}
    </li>;
}

export default Tree;

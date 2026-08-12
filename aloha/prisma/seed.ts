import "dotenv/config";

import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "../src/generated/prisma/client";

import notes from "./data/notes.json";

const adapter = new PrismaPg({
    connectionString: process.env.DATABASE_URL!,
});

const prisma = new PrismaClient({
    adapter,
});

async function main() {
    const users = [
        {
            id: "05244198-7873-488e-a8c5-e9e7646d7df2",
            email: "noteuser1@example.com",
            name: "Note User 1",
        },
        {
            id: "82cd4598-e76f-4e29-898a-83990bbad037",
            email: "noteuser2@example.com",
            name: "Note User 2",
        },
    ];

    await prisma.user.createMany({
        data: users.map((user) => ({
            id: user.id,
            email: user.email,
            name: user.name,
        })),
        skipDuplicates: true,
    });

    for (const note of notes) {
        await prisma.notesPage.create({
            data: {
                id: note.id,
                userId: note.user_id,
                title: note.title || null,
                description: note.description || null,
                imageUrl: note.imageUrl || null,
                createdAt: new Date(note.created_at),
                updatedAt: new Date(note.created_at),
                editorVersion: note.long_desc.version,
                blocks: {
                    create: note.long_desc.blocks.map((block, index) => ({
                        blockKey: block.id,
                        type: block.type,
                        order: index,
                        data: block.data,
                        text: (block.data as any).text ?? null,
                        createdAt: new Date(note.created_at),
                        updatedAt: new Date(note.created_at),
                    })),
                },
            },
        });
    }

    console.log(`Seeded ${notes.length} notes`);
}

main()
    .catch((error) => {
        console.error(error);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
import "dotenv/config";
import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { parse } from "csv-parse/sync";
import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "../src/generated/prisma/client";

type NoteCsvRow = {
    id: string;
    createdAt: string;
    description: string;
    editorVersion: string;
    imageKey: string;
    imageUrl: string;
    title: string;
    updatedAt: string;
    userId: string;
    notes_block: string;
};

async function main() {
    const connectionString = process.env.DIRECT_URL;

    if (!connectionString) {
        throw new Error("DIRECT_URL is missing from .env");
    }

    const adapter = new PrismaPg({ connectionString });
    const prisma = new PrismaClient({ adapter });

    try {
        const csvPath = resolve(
            process.cwd(),
            "prisma/data/notes_page.csv",
        );

        const csv = await readFile(csvPath, "utf8");

        const rows = parse(csv, {
            columns: true,
            skip_empty_lines: true,
            trim: true,
            bom: true,
        }) as NoteCsvRow[];

        console.log(`Found ${rows.length} notes in CSV.`);

        let imported = 0;

        await prisma.$transaction(async (tx) => {
            for (const row of rows) {
                const id = Number(row.id);

                if (!Number.isSafeInteger(id) || id <= 0) {
                    throw new Error(`Invalid note ID: ${row.id}`);
                }

                if (!row.title || !row.userId) {
                    throw new Error(`Note ${row.id} is missing its title or userId`);
                }

                const createdAt = new Date(row.createdAt);
                const updatedAt = new Date(row.updatedAt);

                if (
                    Number.isNaN(createdAt.getTime()) ||
                    Number.isNaN(updatedAt.getTime())
                ) {
                    throw new Error(`Invalid timestamp for note ${row.id}`);
                }

                await tx.note.upsert({
                    where: { id },
                    create: {
                        id,
                        createdAt,
                        description: row.description || null,
                        editorVersion: row.editorVersion || null,
                        imageKey: row.imageKey || null,
                        imageUrl: row.imageUrl || null,
                        title: row.title,
                        updatedAt,
                        userId: row.userId,
                    },
                    update: {
                        createdAt,
                        description: row.description || null,
                        editorVersion: row.editorVersion || null,
                        imageKey: row.imageKey || null,
                        imageUrl: row.imageUrl || null,
                        title: row.title,
                        updatedAt,
                        userId: row.userId,
                    },
                });

                imported++;
            }
        });

        console.log(`Successfully imported ${imported} notes.`);
    } finally {
        await prisma.$disconnect();
    }
}

main().catch((error) => {
    console.error("Notes seeding failed:", error);
    process.exitCode = 1;
});
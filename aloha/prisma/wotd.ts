import "dotenv/config";
import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "../src/generated/prisma/client";

type WordOfTheDaySeed = {
    id: number;
    word: string;
    meaning: string;
};

async function main() {
    const connectionString = process.env.DIRECT_URL;

    if (!connectionString) {
        throw new Error("DIRECT_URL is not configured in .env");
    }

    const adapter = new PrismaPg({ connectionString });
    const prisma = new PrismaClient({ adapter });

    try {
        const filePath = resolve(
            process.cwd(),
            "prisma/data/wotd.json",
        );

        const content = await readFile(filePath, "utf8");
        const words = JSON.parse(content) as WordOfTheDaySeed[];

        if (!Array.isArray(words) || words.length === 0) {
            throw new Error("WOTD seed file is empty or invalid");
        }

        await prisma.$transaction(async (tx) => {
            for (const item of words) {
                await tx.wordOfTheDay.upsert({
                    where: { id: item.id },
                    update: {
                        word: item.word,
                        meaning: item.meaning,
                    },
                    create: {
                        id: item.id,
                        word: item.word,
                        meaning: item.meaning,
                    },
                });
            }
        });

        console.log(`Successfully seeded ${words.length} WOTD records.`);
    } finally {
        await prisma.$disconnect();
    }
}

main().catch((error) => {
    console.error("WOTD seeding failed:", error);
    process.exitCode = 1;
});
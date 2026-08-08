import "dotenv/config";

import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "../src/generated/prisma/client";

import words from "./data/word-of-the-day.json";

const adapter = new PrismaPg({
    connectionString: process.env.DATABASE_URL!,
});

const prisma = new PrismaClient({
    adapter,
});

async function main() {
    await prisma.wordOfTheDay.createMany({
        data: words,
        skipDuplicates: true,
    });

    console.log(`Seeded ${words.length} words`);
}

main()
    .catch((error) => {
        console.error(error);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
import { Injectable, NotFoundException } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import type { NoteInput } from "./notes.dto";

@Injectable()
export class NotesService {
    constructor(private readonly prisma: PrismaService) { }

    private readonly pageWithBlocks = {
        include: {
            blocks: {
                orderBy: { order: "asc" },
            },
        },
    } as const;

    async findAllPages(userId: string) {
        return this.prisma.notesPage.findMany({
            where: { userId },
            orderBy: { updatedAt: "desc" },
            select: {
                id: true,
                userId: true,
                title: true,
                imageUrl: true,
                createdAt: true,
                updatedAt: true,
            },
        });
    }

    async findPageWithBlocks(id: number, userId: string) {
        const page = await this.prisma.notesPage.findFirst({
            where: { id, userId },
            ...this.pageWithBlocks,
        });

        if (!page) {
            throw new NotFoundException("Note not found.");
        }

        return page;
    }

    async findBlocksByPage(id: number, userId: string) {
        const page = await this.findPageWithBlocks(id, userId);
        return page.blocks;
    }

    async createPage(userId: string, input: NoteInput) {
        const blocks = input.blocks?.map((block, order) => ({
            ...block,
            order,
        }));

        return this.prisma.notesPage.create({
            data: {
                userId,
                title: input.title,
                imageUrl: input.imageUrl,
                blocks: blocks ? { create: blocks } : undefined,
            },
            ...this.pageWithBlocks,
        });
    }

    async updatePage(id: number, userId: string, input: NoteInput) {
        const blocks = input.blocks?.map((block, order) => ({
            ...block,
            order,
        }));

        return this.prisma.$transaction(async (tx) => {
            const page = await tx.notesPage.findFirst({
                where: { id, userId },
                select: { id: true },
            });

            if (!page) {
                throw new NotFoundException("Note not found.");
            }

            return tx.notesPage.update({
                where: { id: page.id },
                data: {
                    title: input.title,
                    imageUrl: input.imageUrl,
                    blocks: blocks === undefined
                        ? undefined
                        : {
                            deleteMany: {},
                            create: blocks,
                        },
                },
                ...this.pageWithBlocks,
            });
        });
    }

    async deletePage(id: number, userId: string) {
        const { count } = await this.prisma.notesPage.deleteMany({
            where: { id, userId },
        });

        if (count === 0) {
            throw new NotFoundException("Note not found.");
        }
    }
}
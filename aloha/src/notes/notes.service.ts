import { Injectable } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class NotesService {
    constructor(private readonly prisma: PrismaService) { }

    async findAllPages(userId: string) {
        return this.prisma.notesPage.findMany({
            where: {
                userId,
            },
            orderBy: { updatedAt: "desc" },
            select: {
                id: true,
                userId: true,
                title: true,
                description: true,
                imageUrl: true,
                editorVersion: true,
                createdAt: true,
                updatedAt: true,
            },
        });
    }

    async findPageWithBlocks(id: number, userId: string,) {
        return this.prisma.notesPage.findFirst({
            where: {
                id,
                userId,
            },
            include: {
                blocks: {
                    orderBy: { order: "asc" },
                },
            },
        });
    }

    async findBlocksByPage(id: number, userId: string,) {
        return this.prisma.notesBlock.findMany({
            where: {
                noteId: id,
                note: {
                    userId,
                },
            },
            orderBy: { order: "asc" },
        });
    }
}
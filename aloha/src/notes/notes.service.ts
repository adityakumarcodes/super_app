import { Injectable } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class NotesService {
    constructor(private readonly prisma: PrismaService) { }

    async findAllPages() {
        return this.prisma.notesPage.findMany({
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

    async findPageWithBlocks(id: number) {
        return this.prisma.notesPage.findUnique({
            where: { id },
            include: {
                blocks: {
                    orderBy: { order: "asc" },
                },
            },
        });
    }

    async findBlocksByPage(id: number) {
        return this.prisma.notesBlock.findMany({
            where: { noteId: id },
            orderBy: { order: "asc" },
        });
    }
}
import { Injectable, NotFoundException } from '@nestjs/common';
import type { Prisma } from '../generated/prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import type { NoteInput, NoteBlockInput } from './notes.dto';
import { StorageService } from '../storage/storage.service';

@Injectable()
export class NotesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly storageService: StorageService,
  ) {}

  private readonly pageWithBlocks = {
    include: {
      blocks: {
        orderBy: { order: 'asc' },
      },
    },
  } as const;

  async findAllPages(userId: string) {
    return this.prisma.notesPage.findMany({
      where: { userId },
      orderBy: { updatedAt: 'desc' },
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
      throw new NotFoundException('Note not found.');
    }

    return page;
  }

  async findBlocksByPage(id: number, userId: string) {
    const page = await this.findPageWithBlocks(id, userId);
    return page.blocks;
  }

  private sanitizeBlocks(blocks?: NoteBlockInput[]) {
    return blocks?.map((block, order) => {
      const data = { ...block.data } as Record<string, unknown>;
      const file =
        data.file && typeof data.file === 'object' && !Array.isArray(data.file)
          ? (data.file as Record<string, unknown>)
          : undefined;
      if (file?.path) delete file.url;
      return { ...block, data: data as Prisma.InputJsonObject, order };
    });
  }

  async createPage(userId: string, input: NoteInput) {
    const blocks = this.sanitizeBlocks(input.blocks);

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
    const blocks = this.sanitizeBlocks(input.blocks);

    return this.prisma.$transaction(async (tx) => {
      const page = await tx.notesPage.findFirst({
        where: { id, userId },
        select: { id: true },
      });

      if (!page) {
        throw new NotFoundException('Note not found.');
      }

      return tx.notesPage.update({
        where: { id: page.id },
        data: {
          title: input.title,
          imageUrl: input.imageUrl,
          blocks:
            blocks === undefined
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
    const page = await this.prisma.notesPage.findFirst({
      where: { id, userId },
      include: { blocks: true },
    });

    if (!page) {
      throw new NotFoundException('Note not found.');
    }

    const paths: string[] = [];
    if (page.imageUrl && !page.imageUrl.startsWith('http')) {
      paths.push(page.imageUrl);
    }
    for (const block of page.blocks ?? []) {
      const data = block.data as Record<string, unknown> | null;
      const file =
        data?.file && typeof data.file === 'object' && !Array.isArray(data.file)
          ? (data.file as Record<string, unknown>)
          : undefined;
      if (typeof file?.path === 'string') paths.push(file.path);
    }

    await this.prisma.notesPage.deleteMany({ where: { id, userId } });

    await Promise.all(
      paths.map((path) =>
        this.storageService.delete(path, userId).catch(() => undefined),
      ),
    );
  }
}

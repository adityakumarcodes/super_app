import { Injectable, NotFoundException } from '@nestjs/common';
import type { Prisma } from '../generated/prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import type { NoteInput, NoteBlockInput } from './notes.dto';
import { blocksToContent } from './notes.format';
import { StorageService } from '../storage/storage.service';

type StoredBlock = { type: string; data: Prisma.JsonValue };

const isHttpUrl = (value: string) => /^https?:\/\//i.test(value);

/** Returns the `file` object of a block's data (image blocks), if any. */
function imageFile(data: unknown): Record<string, unknown> | undefined {
  const file =
    data && typeof data === 'object' && !Array.isArray(data)
      ? (data as Record<string, unknown>).file
      : undefined;
  return file && typeof file === 'object' && !Array.isArray(file)
    ? (file as Record<string, unknown>)
    : undefined;
}

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

  /** Signs a stored file path for display. http URLs pass through; anything else, or a signing failure, gives null. */
  private async displayUrl(
    value: unknown,
    userId: string,
  ): Promise<string | null> {
    if (typeof value !== 'string' || !value) return null;
    if (isHttpUrl(value)) return value;
    try {
      return (await this.storageService.getSignedUrl(value, userId)).url;
    } catch {
      return null;
    }
  }

  /** Adds `coverUrl` (signed) next to `imageUrl` (the storage path used for writes). */
  private async present<P extends { imageUrl: string | null }>(
    page: P,
    userId: string,
  ) {
    return { ...page, coverUrl: await this.displayUrl(page.imageUrl, userId) };
  }

  /**
   * Shapes a full page the same way for every client: `coverUrl`, a signed
   * `file.url` on image blocks (`file.path` is kept for saving) and `content`,
   * the note as text (null when it cannot be written as text).
   */
  private async presentWithBlocks<
    P extends { imageUrl: string | null; blocks: StoredBlock[] },
  >(page: P, userId: string) {
    const blocks = await Promise.all(
      page.blocks.map(async (block) => {
        const file = imageFile(block.data);
        const url = file
          ? await this.displayUrl(file.path ?? file.url, userId)
          : null;
        if (!url) return block;
        return {
          ...block,
          data: {
            ...(block.data as Prisma.JsonObject),
            file: { ...file, url },
          },
        };
      }),
    );

    return {
      ...(await this.present(page, userId)),
      blocks,
      content: blocksToContent(page.blocks),
    };
  }

  async findAllPages(userId: string) {
    const pages = await this.prisma.notesPage.findMany({
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

    return Promise.all(pages.map((page) => this.present(page, userId)));
  }

  async findPageWithBlocks(id: number, userId: string) {
    const page = await this.prisma.notesPage.findFirst({
      where: { id, userId },
      ...this.pageWithBlocks,
    });

    if (!page) {
      throw new NotFoundException('Note not found.');
    }

    return this.presentWithBlocks(page, userId);
  }

  async findBlocksByPage(id: number, userId: string) {
    const page = await this.findPageWithBlocks(id, userId);
    return page.blocks;
  }

  /** Sets each block's order and drops expiring signed URLs: only `file.path` is stored. */
  private sanitizeBlocks(blocks?: NoteBlockInput[]) {
    return blocks?.map((block, order) => {
      const data = { ...block.data } as Record<string, unknown>;
      const file = imageFile(data);
      if (file?.path) {
        const stored = { ...file };
        delete stored.url;
        data.file = stored;
      }
      return { ...block, data: data as Prisma.InputJsonObject, order };
    });
  }

  async createPage(userId: string, input: NoteInput) {
    const blocks = this.sanitizeBlocks(input.blocks);

    const page = await this.prisma.notesPage.create({
      data: {
        userId,
        title: input.title,
        imageUrl: input.imageUrl,
        blocks: blocks ? { create: blocks } : undefined,
      },
      ...this.pageWithBlocks,
    });

    return this.presentWithBlocks(page, userId);
  }

  /** Checks ownership and, when blocks are given, replaces all of them, in one transaction. */
  async updatePage(id: number, userId: string, input: NoteInput) {
    const blocks = this.sanitizeBlocks(input.blocks);

    const page = await this.prisma.$transaction(async (tx) => {
      const existing = await tx.notesPage.findFirst({
        where: { id, userId },
        select: { id: true },
      });

      if (!existing) {
        throw new NotFoundException('Note not found.');
      }

      return tx.notesPage.update({
        where: { id: existing.id },
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

    return this.presentWithBlocks(page, userId);
  }

  /** Deletes the page, then best-effort removes its cover and block images from storage. */
  async deletePage(id: number, userId: string) {
    const page = await this.prisma.notesPage.findFirst({
      where: { id, userId },
      include: { blocks: true },
    });

    if (!page) {
      throw new NotFoundException('Note not found.');
    }

    const paths = [
      page.imageUrl,
      ...page.blocks.map((block) => imageFile(block.data)?.path),
    ].filter(
      (path): path is string =>
        typeof path === 'string' && !!path && !isHttpUrl(path),
    );

    await this.prisma.notesPage.deleteMany({ where: { id, userId } });

    await Promise.all(
      paths.map((path) =>
        this.storageService.delete(path, userId).catch(() => undefined),
      ),
    );
  }
}

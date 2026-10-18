import { BadRequestException } from "@nestjs/common";
import type { Prisma } from "../generated/prisma/client";

const noteFields = ["title", "description", "imageUrl", "editorVersion", "blocks"] as const;

export type NoteBlockInput = {
    blockKey?: string | null;
    type: string;
    data: Prisma.InputJsonObject;
};

export type NoteInput = {
    title?: string | null;
    description?: string | null;
    imageUrl?: string | null;
    editorVersion?: string | null;
    blocks?: NoteBlockInput[];
};

function asObject(value: unknown): Record<string, unknown> | undefined {
    return value && typeof value === "object" && !Array.isArray(value)
        ? value as Record<string, unknown>
        : undefined;
}

function nullableString(value: unknown, field: string) {
    if (value === undefined || value === null || typeof value === "string") {
        return value;
    }

    throw new BadRequestException(`${field} must be a string or null.`);
}

function parseBlocks(value: unknown): NoteBlockInput[] {
    if (!Array.isArray(value)) {
        throw new BadRequestException("blocks must be an array.");
    }

    const keys = new Set<string>();
    return value.map((rawBlock, index) => {
        const block = asObject(rawBlock);
        const data = block && asObject(block.data);
        if (!block || !data || typeof block.type !== "string" || !block.type.trim()) {
            throw new BadRequestException(`blocks[${index}] must include a type and data object.`);
        }

        const blockKey = nullableString(block.blockKey, `blocks[${index}].blockKey`);
        if (typeof blockKey === "string") {
            if (!blockKey.trim() || keys.has(blockKey)) {
                throw new BadRequestException(`blocks[${index}].blockKey must be unique and non-empty.`);
            }
            keys.add(blockKey);
        }

        return { blockKey, type: block.type.trim(), data: data as Prisma.InputJsonObject };
    });
}

function parseNoteInput(body: unknown, requireChange: boolean): NoteInput {
    const input = asObject(body);
    if (!input) {
        throw new BadRequestException("Note body must be a JSON object.");
    }

    if (requireChange && !noteFields.some((field) => field in input)) {
        throw new BadRequestException("Provide at least one note field to update.");
    }

    return {
        title: nullableString(input.title, "title"),
        description: nullableString(input.description, "description"),
        imageUrl: nullableString(input.imageUrl, "imageUrl"),
        editorVersion: nullableString(input.editorVersion, "editorVersion"),
        blocks: "blocks" in input ? parseBlocks(input.blocks) : undefined,
    };
}

export function parseCreateNoteInput(body: unknown): NoteInput {
    return parseNoteInput(body, false);
}

export function parseUpdateNoteInput(body: unknown): NoteInput {
    return parseNoteInput(body, true);
}

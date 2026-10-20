import {
    Body,
    Controller,
    Delete,
    Get,
    HttpCode,
    HttpStatus,
    Param,
    ParseIntPipe,
    Patch,
    Post,
    UploadedFile,
    UseInterceptors,
} from "@nestjs/common";
import { FileInterceptor } from "@nestjs/platform-express";
import { NotesService } from "./notes.service";
import { StorageService } from "../storage/storage.service";
import {
    Session,
    type UserSession,
} from '@thallesp/nestjs-better-auth';
import { parseCreateNoteInput, parseUpdateNoteInput } from "./notes.dto";

@Controller("notes")
export class NotesController {
    constructor(private readonly notesService: NotesService, private readonly storageService: StorageService) { }

    @Get()
    getPages(@Session() session: UserSession) {
        return this.notesService.findAllPages(session.user.id);
    }

    @Post()
    @UseInterceptors(FileInterceptor('cover'))
    async createPage(
        @UploadedFile() file: Express.Multer.File,
        @Body() body: Record<string, unknown>,
        @Session() session: UserSession,
    ) {
        let imageUrl = body?.imageUrl;
        if (file) {
            const uploaded = await this.storageService.upload(file, session.user.id);
            imageUrl = uploaded.path;
        }

        const payload: Record<string, unknown> = { ...body, imageUrl };
        if (typeof payload.blocks === "string") {
            try {
                payload.blocks = JSON.parse(payload.blocks as string);
            } catch {
                // keep as-is; dto parser will reject invalid
            }
        }

        return this.notesService.createPage(session.user.id, parseCreateNoteInput(payload));
    }

    @Get(":id")
    getPage(@Param("id", ParseIntPipe) id: number, @Session() session: UserSession,) {
        return this.notesService.findPageWithBlocks(id, session.user.id);
    }

    @Get(":id/blocks")
    getPageBlocks(@Param("id", ParseIntPipe) id: number, @Session() session: UserSession,) {
        return this.notesService.findBlocksByPage(id, session.user.id);
    }

    @Patch(":id")
    @UseInterceptors(FileInterceptor('cover'))
    async updatePage(
        @Param("id", ParseIntPipe) id: number,
        @UploadedFile() file: Express.Multer.File,
        @Body() body: Record<string, unknown>,
        @Session() session: UserSession,
    ) {
        let imageUrl = body?.imageUrl;
        if (file) {
            const uploaded = await this.storageService.upload(file, session.user.id);
            imageUrl = uploaded.path;
        }

        const payload: Record<string, unknown> = { ...body };
        if (file || body?.imageUrl !== undefined) payload.imageUrl = imageUrl;
        if (typeof payload.blocks === "string") {
            try {
                payload.blocks = JSON.parse(payload.blocks as string);
            } catch {
                // keep as-is
            }
        }

        return this.notesService.updatePage(id, session.user.id, parseUpdateNoteInput(payload));
    }

    @Delete(":id")
    @HttpCode(HttpStatus.NO_CONTENT)
    async deletePage(@Param("id", ParseIntPipe) id: number, @Session() session: UserSession) {
        await this.notesService.deletePage(id, session.user.id);
    }
}

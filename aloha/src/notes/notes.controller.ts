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
} from "@nestjs/common";
import { NotesService } from "./notes.service";
import {
    Session,
    type UserSession,
} from '@thallesp/nestjs-better-auth';
import { parseCreateNoteInput, parseUpdateNoteInput } from "./notes.dto";


@Controller("notes")
export class NotesController {
    constructor(private readonly notesService: NotesService) { }

    @Get()
    getPages(@Session() session: UserSession) {
        return this.notesService.findAllPages(session.user.id);
    }

    @Post()
    createPage(@Body() body: unknown, @Session() session: UserSession) {
        return this.notesService.createPage(session.user.id, parseCreateNoteInput(body));
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
    updatePage(
        @Param("id", ParseIntPipe) id: number,
        @Body() body: unknown,
        @Session() session: UserSession,
    ) {
        return this.notesService.updatePage(id, session.user.id, parseUpdateNoteInput(body));
    }

    @Delete(":id")
    @HttpCode(HttpStatus.NO_CONTENT)
    async deletePage(@Param("id", ParseIntPipe) id: number, @Session() session: UserSession) {
        await this.notesService.deletePage(id, session.user.id);
    }
}

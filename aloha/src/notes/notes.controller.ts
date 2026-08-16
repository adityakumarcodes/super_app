import { Controller, Get, Param, ParseIntPipe } from "@nestjs/common";
import { NotesService } from "./notes.service";
import {
    Session,
    type UserSession,
} from '@thallesp/nestjs-better-auth';


@Controller("notes")
export class NotesController {
    constructor(private readonly notesService: NotesService) { }

    @Get()
    getPages(@Session() session: UserSession) {
        return this.notesService.findAllPages(session.user.id);
    }

    @Get(":id")
    getPage(@Param("id", ParseIntPipe) id: number, @Session() session: UserSession,) {
        return this.notesService.findPageWithBlocks(id, session.user.id);
    }

    @Get(":id/blocks")
    getPageBlocks(@Param("id", ParseIntPipe) id: number, @Session() session: UserSession,) {
        return this.notesService.findBlocksByPage(id, session.user.id);
    }
}
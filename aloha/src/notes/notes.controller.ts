import { Controller, Get, Param, ParseIntPipe } from "@nestjs/common";
import { NotesService } from "./notes.service";
import { AllowAnonymous } from "@thallesp/nestjs-better-auth";

@AllowAnonymous()
@Controller("notes")
export class NotesController {
    constructor(private readonly notesService: NotesService) { }

    @Get()
    getPages() {
        return this.notesService.findAllPages();
    }

    @Get(":id")
    getPage(@Param("id", ParseIntPipe) id: number) {
        return this.notesService.findPageWithBlocks(id);
    }

    @Get(":id/blocks")
    getPageBlocks(@Param("id", ParseIntPipe) id: number) {
        return this.notesService.findBlocksByPage(id);
    }
}
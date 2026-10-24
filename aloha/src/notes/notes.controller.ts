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
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { NotesService } from './notes.service';
import { StorageService } from '../storage/storage.service';
import { Session, type UserSession } from '@thallesp/nestjs-better-auth';
import { parseCreateNoteInput, parseUpdateNoteInput } from './notes.dto';

/**
 * Notes API shared by web and mobile. Bodies may be JSON or multipart (with an
 * optional `cover` image); content is sent as Editor.js `blocks` or `content`
 * text. Responses are display-ready (see NotesService.presentWithBlocks).
 */
@Controller('notes')
export class NotesController {
  constructor(
    private readonly notesService: NotesService,
    private readonly storageService: StorageService,
  ) {}

  @Get()
  getPages(@Session() session: UserSession) {
    return this.notesService.findAllPages(session.user.id);
  }

  @Post()
  @UseInterceptors(FileInterceptor('cover'))
  async createPage(
    @UploadedFile() file: Express.Multer.File | undefined,
    @Body() body: Record<string, unknown>,
    @Session() session: UserSession,
  ) {
    const payload = await this.toPayload(body, file, session.user.id);
    return this.notesService.createPage(
      session.user.id,
      parseCreateNoteInput(payload),
    );
  }

  @Get(':id')
  getPage(
    @Param('id', ParseIntPipe) id: number,
    @Session() session: UserSession,
  ) {
    return this.notesService.findPageWithBlocks(id, session.user.id);
  }

  @Get(':id/blocks')
  getPageBlocks(
    @Param('id', ParseIntPipe) id: number,
    @Session() session: UserSession,
  ) {
    return this.notesService.findBlocksByPage(id, session.user.id);
  }

  @Patch(':id')
  @UseInterceptors(FileInterceptor('cover'))
  async updatePage(
    @Param('id', ParseIntPipe) id: number,
    @UploadedFile() file: Express.Multer.File | undefined,
    @Body() body: Record<string, unknown>,
    @Session() session: UserSession,
  ) {
    const payload = await this.toPayload(body, file, session.user.id);
    return this.notesService.updatePage(
      id,
      session.user.id,
      parseUpdateNoteInput(payload),
    );
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deletePage(
    @Param('id', ParseIntPipe) id: number,
    @Session() session: UserSession,
  ) {
    await this.notesService.deletePage(id, session.user.id);
  }

  /**
   * Normalises create/update bodies: uploads an optional `cover` file (its
   * storage path becomes `imageUrl`) and parses `blocks` sent as a JSON
   * string in multipart forms. Validation happens in notes.dto.
   */
  private async toPayload(
    body: Record<string, unknown> | undefined,
    file: Express.Multer.File | undefined,
    userId: string,
  ) {
    const payload: Record<string, unknown> = { ...body };
    if (file) {
      payload.imageUrl = (await this.storageService.upload(file, userId)).path;
    }

    if (typeof payload.blocks === 'string') {
      try {
        payload.blocks = JSON.parse(payload.blocks);
      } catch {
        // Leave as-is; the DTO parser rejects invalid blocks.
      }
    }

    return payload;
  }
}

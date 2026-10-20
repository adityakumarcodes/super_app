import {
    Controller,
    Post,
    Get,
    UploadedFile,
    UseInterceptors,
    Query,
    BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { StorageService } from './storage.service';
import { Session, type UserSession } from '@thallesp/nestjs-better-auth';


@Controller('storage')
export class StorageController {
    constructor(private readonly storageService: StorageService) { }

    @Post('upload')
    @UseInterceptors(FileInterceptor('file'))
    async upload(@UploadedFile() file: Express.Multer.File, @Session() session: UserSession,) {
        const userId = session.user.id;
        return this.storageService.upload(file, userId);
    }

    @Get('url')
    async getUrl(@Query('path') path: string) {
        if (!path) {
            throw new BadRequestException('Storage path is required');
        }

        return this.storageService.getUrl(path);
    }
}
import {
    Injectable,
    InternalServerErrorException,
    BadRequestException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, type SupabaseClient } from '@supabase/supabase-js';
import { randomUUID } from 'node:crypto';
import { basename, extname, parse } from 'node:path';

@Injectable()
export class StorageService {
    private readonly supabase: SupabaseClient;
    private readonly bucket = 'superapp';

    constructor(private readonly config: ConfigService) {
        this.supabase = createClient(
            this.config.getOrThrow<string>('SUPABASE_URL'),
            this.config.getOrThrow<string>('SUPABASE_SECRET_KEY'),
            {
                auth: {
                    persistSession: false,
                    autoRefreshToken: false,
                    detectSessionInUrl: false,
                },
            },
        );
    }

    // Upload a file and return its signed url path.
    async upload(file: Express.Multer.File, userId: string) {
        if (!userId) {
            throw new BadRequestException("Authenticated user is required");
        }

        if (!file.mimetype.startsWith("image/")) {
            throw new BadRequestException("Only image files are allowed");
        }

        const originalName = file.originalname;
        const filenameWithoutExtension = parse(originalName).name;
        const extension = extname(originalName);
        const filename = `${filenameWithoutExtension}${extension}`;
        // const filename = `${filenameWithoutExtension}_${randomUUID()}${extension}`;
        const path = `notes/${userId}/${filename}`;
        const { data, error } = await this.supabase.storage
            .from("superapp")
            .upload(path, file.buffer, {
                contentType: file.mimetype,
                upsert: false,
            });

        if (error) {
            throw new InternalServerErrorException(
                `Image upload failed: ${error.message}`,
            );
        }

        const { data: signedData, error: signedError } =
            await this.supabase.storage
                .from(this.bucket)
                .createSignedUrl(data.path, 3600);

        if (signedError) {
            throw new InternalServerErrorException(
                `Could not generate image URL: ${signedError.message}`,
            );
        }

        return {
            path: data.path,
            url: signedData.signedUrl,
        };
    }

    async delete(path: string) {
        const { error } = await this.supabase.storage.from(this.bucket).remove([path]);
        if (error) {
            throw new InternalServerErrorException(`Image delete failed: ${error.message}`);
        }
    }

    // Generate a signed URL valid for one hour.
    async getSignedUrl(path: string) {
        const { data, error } = await this.supabase.storage
            .from(this.bucket)
            .createSignedUrl(path, 3600);

        if (error) {
            throw new InternalServerErrorException(
                `Failed to generate signed URL: ${error.message}`,
            );
        }

        return {
            url: data.signedUrl,
            expiresIn: 3600,
        };
    }
}
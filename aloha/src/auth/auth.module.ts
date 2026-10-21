import { Module } from "@nestjs/common";
import { AuthModule as BetterAuthModule } from "@thallesp/nestjs-better-auth";
import { PrismaModule } from "../prisma/prisma.module";
import { PrismaService } from "../prisma/prisma.service";

import { createAuth } from "./auth";
import { EmailService } from "../email/email.service";
import { EmailModule } from "../email/email.module";

@Module({
    imports: [
        PrismaModule,
        EmailModule,
        BetterAuthModule.forRootAsync({
            imports: [PrismaModule, EmailModule],
            inject: [PrismaService, EmailService],

            useFactory: (prisma: PrismaService, emailService: EmailService) => ({
                auth: createAuth(prisma, emailService),
                bodyParser: {
                    json: {
                        limit: "5mb",
                    },
                },
            }),
        }),
    ],
})
export class AuthModule { }
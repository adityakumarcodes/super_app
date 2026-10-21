import { betterAuth, type BetterAuthOptions } from "better-auth";
import { prismaAdapter } from "better-auth/adapters/prisma";
import type { PrismaClient } from "../generated/prisma/client";
import { emailOTP } from "better-auth/plugins";
import { EmailService } from "../email/email.service";

export function createAuth(prisma: PrismaClient, emailService: EmailService,) {
    const options: BetterAuthOptions = {
        database: prismaAdapter(prisma, {
            provider: "postgresql",
        }),

        emailAndPassword: {
            enabled: true,
        },

        plugins: [
            emailOTP({
                async sendVerificationOTP({ email, otp, type }) {
                    await emailService.sendOtp(email, otp);
                },
            }),
        ],

        trustedOrigins: [
            process.env.FRONTEND_URL!,
            // `http://localhost:${process.env.FRONTEND_PORT}`,
        ],

    };

    return betterAuth(options);
}

export type AppAuth = ReturnType<typeof createAuth>;
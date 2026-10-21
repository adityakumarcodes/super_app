import { Injectable } from '@nestjs/common';
import { Resend } from 'resend';

@Injectable()
export class EmailService {
  private readonly resend: Resend;

  constructor() {
    const apiKey = process.env.RESEND_API_KEY;

    if (!apiKey) {
      throw new Error('RESEND_API_KEY is not configured');
    }


    this.resend = new Resend(apiKey);
  }

  async sendOtp(email: string, otp: string): Promise<void> {
    console.log(`[OTP] → ${email}: ${otp}`);
    const { error } = await this.resend.emails.send({
      from: "Aloha <onboarding@resend.dev>",
      to: email,
      subject: 'Your Aloha verification code',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 480px; margin: auto;">
          <h2>Welcome to Aloha</h2>
          <p>Use the verification code below to continue.</p>
          <div style="
            font-size: 32px;
            font-weight: bold;
            letter-spacing: 8px;
            padding: 20px;
            background: #f8f6f2;
            text-align: center;
            border-radius: 12px;
          ">
            ${otp}
          </div>
          <p>This code is valid for a limited time. Do not share it with anyone.</p>
          <p>If you didn't request this code, you can ignore this email.</p>
        </div>
      `,
    });

    if (error) {
      throw new Error(`Failed to send OTP email: ${error.message}`);
    }
  }
}
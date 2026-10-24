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
    const { error } = await this.resend.emails.send({
      from: 'Milo <onboarding@resend.dev>',
      to: email,
      subject: otp + 'is your Milo verification code.',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 480px; margin: auto;">
          <p>Welcome to Milo</p>
        </div>
      `,
    });

    if (error) {
      throw new Error(`Failed to send OTP email: ${error.message}`);
    }
  }
}

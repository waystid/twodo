import { config } from '../config';
import { logger } from '../logger';

export interface SendEmailOptions {
  to: string;
  subject: string;
  html: string;
  text?: string;
}

export class EmailService {
  static async sendEmail(options: SendEmailOptions): Promise<void> {
    // In development, just log the email
    if (config.env === 'development') {
      logger.info('📧 Email (Development Mode):');
      logger.info(`To: ${options.to}`);
      logger.info(`Subject: ${options.subject}`);
      logger.info(`Body: ${options.text || 'See HTML'}`);
      logger.info(`HTML: ${options.html}`);
      return;
    }

    // TODO: Integrate with real email service (Resend, SendGrid, etc.)
    // For now, just log in production too
    logger.info('Email would be sent:', {
      to: options.to,
      subject: options.subject,
    });
  }

  static async sendVerificationEmail(email: string, displayName: string, token: string): Promise<void> {
    const verificationUrl = `${config.web.url}/verify-email?token=${token}`;

    await this.sendEmail({
      to: email,
      subject: 'Verify your TwoDo account',
      text: `Hi ${displayName},\n\nPlease verify your email by clicking this link: ${verificationUrl}\n\nThis link will expire in 24 hours.`,
      html: `
        <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto;">
          <h1 style="color: #0ea5e9;">Welcome to TwoDo! 👫</h1>
          <p>Hi ${displayName},</p>
          <p>Thanks for signing up! Please verify your email address by clicking the button below:</p>
          <div style="margin: 30px 0;">
            <a href="${verificationUrl}"
               style="background: #0ea5e9; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">
              Verify Email Address
            </a>
          </div>
          <p style="color: #666; font-size: 14px;">
            Or copy and paste this link: <br/>
            <a href="${verificationUrl}">${verificationUrl}</a>
          </p>
          <p style="color: #666; font-size: 14px;">
            This link will expire in 24 hours.
          </p>
          <hr style="border: 0; border-top: 1px solid #eee; margin: 30px 0;" />
          <p style="color: #999; font-size: 12px;">
            If you didn't create a TwoDo account, you can safely ignore this email.
          </p>
        </div>
      `,
    });
  }

  static async sendPasswordResetEmail(email: string, displayName: string, token: string): Promise<void> {
    const resetUrl = `${config.web.url}/reset-password?token=${token}`;

    await this.sendEmail({
      to: email,
      subject: 'Reset your TwoDo password',
      text: `Hi ${displayName},\n\nYou requested to reset your password. Click this link: ${resetUrl}\n\nThis link will expire in 1 hour.\n\nIf you didn't request this, please ignore this email.`,
      html: `
        <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto;">
          <h1 style="color: #0ea5e9;">Reset your password</h1>
          <p>Hi ${displayName},</p>
          <p>You requested to reset your TwoDo password. Click the button below to create a new password:</p>
          <div style="margin: 30px 0;">
            <a href="${resetUrl}"
               style="background: #0ea5e9; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">
              Reset Password
            </a>
          </div>
          <p style="color: #666; font-size: 14px;">
            Or copy and paste this link: <br/>
            <a href="${resetUrl}">${resetUrl}</a>
          </p>
          <p style="color: #666; font-size: 14px;">
            This link will expire in 1 hour.
          </p>
          <hr style="border: 0; border-top: 1px solid #eee; margin: 30px 0;" />
          <p style="color: #999; font-size: 12px;">
            If you didn't request a password reset, you can safely ignore this email. Your password will not be changed.
          </p>
        </div>
      `,
    });
  }
}

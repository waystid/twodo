import { db, users } from '@twodo/database';
import { eq, and } from 'drizzle-orm';
import type { RegisterInput, LoginInput } from '@twodo/shared';
import { PasswordService } from './auth.service';
import { UnauthorizedError, ConflictError, BadRequestError, NotFoundError } from '../utils/errors';

export class UserService {
  static async createUser(input: RegisterInput) {
    // Check if user already exists
    const existingUser = await db.query.users.findFirst({
      where: eq(users.email, input.email.toLowerCase()),
    });

    if (existingUser) {
      throw new ConflictError('User with this email already exists');
    }

    // Hash password
    const passwordHash = await PasswordService.hash(input.password);

    // Generate email verification token
    const emailVerificationToken = PasswordService.generateToken();
    const emailVerificationExpires = PasswordService.getTokenExpiry(24);

    // Create user
    const [user] = await db
      .insert(users)
      .values({
        email: input.email.toLowerCase(),
        passwordHash,
        displayName: input.displayName,
        timezone: input.timezone || 'UTC',
        emailVerificationToken,
        emailVerificationExpires,
        emailVerified: false,
      })
      .returning();

    return {
      user,
      emailVerificationToken,
    };
  }

  static async verifyEmail(token: string) {
    const user = await db.query.users.findFirst({
      where: and(
        eq(users.emailVerificationToken, token),
      ),
    });

    if (!user) {
      throw new BadRequestError('Invalid or expired verification token');
    }

    if (user.emailVerificationExpires && user.emailVerificationExpires < new Date()) {
      throw new BadRequestError('Verification token has expired');
    }

    // Update user
    const [updatedUser] = await db
      .update(users)
      .set({
        emailVerified: true,
        emailVerificationToken: null,
        emailVerificationExpires: null,
        updatedAt: new Date(),
      })
      .where(eq(users.id, user.id))
      .returning();

    return updatedUser;
  }

  static async authenticateUser(input: LoginInput) {
    const user = await db.query.users.findFirst({
      where: eq(users.email, input.email.toLowerCase()),
    });

    if (!user) {
      throw new UnauthorizedError('Invalid email or password');
    }

    const isPasswordValid = await PasswordService.compare(input.password, user.passwordHash);

    if (!isPasswordValid) {
      throw new UnauthorizedError('Invalid email or password');
    }

    if (!user.emailVerified) {
      throw new UnauthorizedError('Please verify your email before logging in');
    }

    return user;
  }

  static async getUserById(userId: string) {
    const user = await db.query.users.findFirst({
      where: eq(users.id, userId),
    });

    if (!user) {
      throw new NotFoundError('User not found');
    }

    return user;
  }

  static async getUserWithCouple(userId: string) {
    const user = await db.query.users.findFirst({
      where: eq(users.id, userId),
      with: {
        coupleUsers: {
          with: {
            couple: true,
          },
        },
      },
    });

    if (!user) {
      throw new NotFoundError('User not found');
    }

    return user;
  }

  static async requestPasswordReset(email: string) {
    const user = await db.query.users.findFirst({
      where: eq(users.email, email.toLowerCase()),
    });

    if (!user) {
      // Don't reveal if user exists or not for security
      return { success: true };
    }

    const passwordResetToken = PasswordService.generateToken();
    const passwordResetExpires = PasswordService.getTokenExpiry(1); // 1 hour

    await db
      .update(users)
      .set({
        passwordResetToken,
        passwordResetExpires,
        updatedAt: new Date(),
      })
      .where(eq(users.id, user.id));

    return {
      success: true,
      passwordResetToken,
      user,
    };
  }

  static async resetPassword(token: string, newPassword: string) {
    const user = await db.query.users.findFirst({
      where: eq(users.passwordResetToken, token),
    });

    if (!user) {
      throw new BadRequestError('Invalid or expired reset token');
    }

    if (user.passwordResetExpires && user.passwordResetExpires < new Date()) {
      throw new BadRequestError('Reset token has expired');
    }

    const passwordHash = await PasswordService.hash(newPassword);

    const [updatedUser] = await db
      .update(users)
      .set({
        passwordHash,
        passwordResetToken: null,
        passwordResetExpires: null,
        updatedAt: new Date(),
      })
      .where(eq(users.id, user.id))
      .returning();

    return updatedUser;
  }

  static async resendVerificationEmail(email: string) {
    const user = await db.query.users.findFirst({
      where: eq(users.email, email.toLowerCase()),
    });

    if (!user) {
      throw new NotFoundError('User not found');
    }

    if (user.emailVerified) {
      throw new BadRequestError('Email is already verified');
    }

    const emailVerificationToken = PasswordService.generateToken();
    const emailVerificationExpires = PasswordService.getTokenExpiry(24);

    await db
      .update(users)
      .set({
        emailVerificationToken,
        emailVerificationExpires,
        updatedAt: new Date(),
      })
      .where(eq(users.id, user.id));

    return {
      emailVerificationToken,
      user,
    };
  }
}

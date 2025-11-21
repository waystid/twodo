import { FastifyInstance } from 'fastify';
import {
  registerSchema,
  loginSchema,
  verifyEmailSchema,
  resetPasswordRequestSchema,
  resetPasswordSchema,
} from '@twodo/shared';
import { UserService } from '../services/user.service';
import { EmailService } from '../services/email.service';
import { TokenService, type JWTPayload } from '../services/auth.service';
import { validateBody } from '../middleware/validate';
import { authenticate } from '../middleware/auth';
import { BadRequestError } from '../utils/errors';

export async function authRoutes(fastify: FastifyInstance) {
  // Register
  fastify.post(
    '/register',
    {
      preHandler: validateBody(registerSchema),
    },
    async (request, reply) => {
      const { user, emailVerificationToken } = await UserService.createUser(request.body as any);

      // Send verification email
      await EmailService.sendVerificationEmail(
        user.email,
        user.displayName,
        emailVerificationToken
      );

      return reply.status(201).send({
        message: 'User registered successfully. Please check your email to verify your account.',
        user: {
          id: user.id,
          email: user.email,
          displayName: user.displayName,
          emailVerified: user.emailVerified,
        },
      });
    }
  );

  // Verify Email
  fastify.post(
    '/verify-email',
    {
      preHandler: validateBody(verifyEmailSchema),
    },
    async (request, reply) => {
      const { token } = request.body as any;
      const user = await UserService.verifyEmail(token);

      return reply.send({
        message: 'Email verified successfully. You can now log in.',
        user: {
          id: user.id,
          email: user.email,
          displayName: user.displayName,
          emailVerified: user.emailVerified,
        },
      });
    }
  );

  // Login
  fastify.post(
    '/login',
    {
      preHandler: validateBody(loginSchema),
    },
    async (request, reply) => {
      const user = await UserService.authenticateUser(request.body as any);

      // Get user's couple if they have one
      const userWithCouple = await UserService.getUserWithCouple(user.id);
      const coupleId = userWithCouple.coupleUsers?.[0]?.coupleId;

      const payload: JWTPayload = {
        userId: user.id,
        coupleId,
      };

      const accessToken = TokenService.generateAccessToken(fastify, payload);
      const refreshToken = TokenService.generateRefreshToken(fastify, payload);

      // Set refresh token as httpOnly cookie
      reply.setCookie('refreshToken', refreshToken, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'strict',
        path: '/',
        maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
      });

      return reply.send({
        accessToken,
        user: {
          id: user.id,
          email: user.email,
          displayName: user.displayName,
          avatarUrl: user.avatarUrl,
          timezone: user.timezone,
          emailVerified: user.emailVerified,
          coupleId,
        },
      });
    }
  );

  // Refresh Token
  fastify.post('/refresh', async (request, reply) => {
    const refreshToken = request.cookies.refreshToken;

    if (!refreshToken) {
      throw new BadRequestError('Refresh token not found');
    }

    try {
      const payload = await TokenService.verifyToken(fastify, refreshToken);

      // Generate new access token
      const newAccessToken = TokenService.generateAccessToken(fastify, payload);

      // Optionally rotate refresh token
      const newRefreshToken = TokenService.generateRefreshToken(fastify, payload);

      reply.setCookie('refreshToken', newRefreshToken, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'strict',
        path: '/',
        maxAge: 7 * 24 * 60 * 60 * 1000,
      });

      return reply.send({
        accessToken: newAccessToken,
      });
    } catch (error) {
      reply.clearCookie('refreshToken');
      throw new BadRequestError('Invalid or expired refresh token');
    }
  });

  // Logout
  fastify.post('/logout', { preHandler: authenticate }, async (request, reply) => {
    reply.clearCookie('refreshToken');

    return reply.send({
      message: 'Logged out successfully',
    });
  });

  // Get Current User
  fastify.get('/me', { preHandler: authenticate }, async (request, reply) => {
    const userWithCouple = await UserService.getUserWithCouple(request.user!.userId);

    const coupleId = userWithCouple.coupleUsers?.[0]?.coupleId;

    return reply.send({
      user: {
        id: userWithCouple.id,
        email: userWithCouple.email,
        displayName: userWithCouple.displayName,
        avatarUrl: userWithCouple.avatarUrl,
        timezone: userWithCouple.timezone,
        notificationPreferences: userWithCouple.notificationPreferences,
        emailVerified: userWithCouple.emailVerified,
        coupleId,
      },
    });
  });

  // Request Password Reset
  fastify.post(
    '/forgot-password',
    {
      preHandler: validateBody(resetPasswordRequestSchema),
    },
    async (request, reply) => {
      const { email } = request.body as any;
      const result = await UserService.requestPasswordReset(email);

      // Send password reset email if user exists
      if (result.passwordResetToken && result.user) {
        await EmailService.sendPasswordResetEmail(
          result.user.email,
          result.user.displayName,
          result.passwordResetToken
        );
      }

      // Always return success to avoid email enumeration
      return reply.send({
        message: 'If an account with that email exists, a password reset link has been sent.',
      });
    }
  );

  // Reset Password
  fastify.post(
    '/reset-password',
    {
      preHandler: validateBody(resetPasswordSchema),
    },
    async (request, reply) => {
      const { token, password } = request.body as any;
      await UserService.resetPassword(token, password);

      return reply.send({
        message: 'Password reset successfully. You can now log in with your new password.',
      });
    }
  );

  // Resend Verification Email
  fastify.post('/resend-verification', async (request, reply) => {
    const { email } = request.body as any;

    if (!email) {
      throw new BadRequestError('Email is required');
    }

    const { emailVerificationToken, user } = await UserService.resendVerificationEmail(email);

    await EmailService.sendVerificationEmail(user.email, user.displayName, emailVerificationToken);

    return reply.send({
      message: 'Verification email sent successfully.',
    });
  });
}

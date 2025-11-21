import { FastifyInstance } from 'fastify';
import { UserService } from '../services/user.service';
import { CoupleService } from '../services/couple.service';
import { requireAuth } from '../middlewares/auth';
import { requireCouple } from '../middlewares/couple';
import { updateProfileSchema, updatePasswordSchema } from '@twodo/shared';
import { updateCoupleSchema } from '@twodo/shared';
import { NotFoundError, UnauthorizedError } from '../utils/errors';

export async function settingsRoutes(app: FastifyInstance) {
  // Update user profile
  app.put(
    '/profile',
    {
      preHandler: [requireAuth],
    },
    async (request, reply) => {
      const userId = request.user!.id;

      const parsed = updateProfileSchema.safeParse(request.body);
      if (!parsed.success) {
        return reply.status(400).send({ error: parsed.error.errors[0].message });
      }

      try {
        const user = await UserService.updateProfile(userId, parsed.data);

        // Return user without sensitive fields
        const { passwordHash, passwordResetToken, passwordResetExpires, emailVerificationToken, emailVerificationExpires, ...userPublic } = user;

        return reply.send({ user: userPublic });
      } catch (error) {
        if (error instanceof NotFoundError) {
          return reply.status(404).send({ error: error.message });
        }
        throw error;
      }
    }
  );

  // Update password
  app.put(
    '/password',
    {
      preHandler: [requireAuth],
    },
    async (request, reply) => {
      const userId = request.user!.id;

      const parsed = updatePasswordSchema.safeParse(request.body);
      if (!parsed.success) {
        return reply.status(400).send({ error: parsed.error.errors[0].message });
      }

      try {
        await UserService.updatePassword(
          userId,
          parsed.data.currentPassword,
          parsed.data.newPassword
        );

        return reply.send({ success: true, message: 'Password updated successfully' });
      } catch (error) {
        if (error instanceof NotFoundError || error instanceof UnauthorizedError) {
          return reply.status(400).send({ error: error.message });
        }
        throw error;
      }
    }
  );

  // Update couple settings
  app.put(
    '/couple',
    {
      preHandler: [requireAuth, requireCouple],
    },
    async (request, reply) => {
      const coupleId = request.user!.coupleId!;
      const userId = request.user!.id;

      const parsed = updateCoupleSchema.safeParse(request.body);
      if (!parsed.success) {
        return reply.status(400).send({ error: parsed.error.errors[0].message });
      }

      try {
        const couple = await CoupleService.updateCouple(coupleId, userId, parsed.data);
        return reply.send({ couple });
      } catch (error) {
        if (error instanceof NotFoundError) {
          return reply.status(404).send({ error: error.message });
        }
        throw error;
      }
    }
  );

  // Get current settings (user + couple)
  app.get(
    '/',
    {
      preHandler: [requireAuth],
    },
    async (request, reply) => {
      const userId = request.user!.id;

      try {
        const user = await UserService.getUserWithCouple(userId);

        // Return user without sensitive fields
        const { passwordHash, passwordResetToken, passwordResetExpires, emailVerificationToken, emailVerificationExpires, ...userPublic } = user;

        const couple = user.coupleUsers[0]?.couple || null;

        return reply.send({
          user: userPublic,
          couple
        });
      } catch (error) {
        if (error instanceof NotFoundError) {
          return reply.status(404).send({ error: error.message });
        }
        throw error;
      }
    }
  );
}

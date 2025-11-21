import { FastifyInstance } from 'fastify';
import { createCoupleSchema, joinCoupleSchema, updateCoupleSchema } from '@twodo/shared';
import { CoupleService } from '../services/couple.service';
import { authenticate, requireCouple } from '../middleware/auth';
import { validateBody } from '../middleware/validate';

export async function coupleRoutes(fastify: FastifyInstance) {
  // Create Couple
  fastify.post(
    '/',
    {
      preHandler: [authenticate, validateBody(createCoupleSchema)],
    },
    async (request, reply) => {
      const couple = await CoupleService.createCouple(
        request.user!.userId,
        request.body as any
      );

      return reply.status(201).send({
        message: 'Couple created successfully',
        couple,
      });
    }
  );

  // Get Current User's Couple
  fastify.get(
    '/me',
    {
      preHandler: [authenticate, requireCouple],
    },
    async (request, reply) => {
      const couple = await CoupleService.getCouple(
        request.user!.coupleId!,
        request.user!.userId
      );

      return reply.send({ couple });
    }
  );

  // Get Couple by ID
  fastify.get(
    '/:coupleId',
    {
      preHandler: [authenticate],
    },
    async (request, reply) => {
      const { coupleId } = request.params as { coupleId: string };
      const couple = await CoupleService.getCouple(coupleId, request.user!.userId);

      return reply.send({ couple });
    }
  );

  // Update Couple
  fastify.put(
    '/:coupleId',
    {
      preHandler: [authenticate, requireCouple, validateBody(updateCoupleSchema)],
    },
    async (request, reply) => {
      const { coupleId } = request.params as { coupleId: string };
      const couple = await CoupleService.updateCouple(
        coupleId,
        request.user!.userId,
        request.body as any
      );

      return reply.send({
        message: 'Couple updated successfully',
        couple,
      });
    }
  );

  // Generate Invite Code
  fastify.post(
    '/:coupleId/invite',
    {
      preHandler: [authenticate, requireCouple],
    },
    async (request, reply) => {
      const { coupleId } = request.params as { coupleId: string };
      const result = await CoupleService.generateInviteCode(coupleId, request.user!.userId);

      return reply.send({
        message: 'Invite code generated successfully',
        ...result,
      });
    }
  );

  // Join Couple
  fastify.post(
    '/join',
    {
      preHandler: [authenticate, validateBody(joinCoupleSchema)],
    },
    async (request, reply) => {
      const couple = await CoupleService.joinCouple(request.user!.userId, request.body as any);

      return reply.send({
        message: 'Successfully joined couple',
        couple,
      });
    }
  );

  // Leave Couple
  fastify.post(
    '/:coupleId/leave',
    {
      preHandler: [authenticate, requireCouple],
    },
    async (request, reply) => {
      const { coupleId } = request.params as { coupleId: string };
      await CoupleService.leaveCouple(coupleId, request.user!.userId);

      return reply.send({
        message: 'Successfully left couple',
      });
    }
  );
}

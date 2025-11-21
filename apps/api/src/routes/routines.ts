import { FastifyInstance } from 'fastify';
import { createRoutineSchema, updateRoutineSchema } from '@twodo/shared';
import { RoutineService } from '../services/routine.service';
import { authenticate, requireCouple } from '../middleware/auth';
import { validateBody } from '../middleware/validate';

export async function routineRoutes(fastify: FastifyInstance) {
  // All routes require authentication and couple membership
  fastify.addHook('preHandler', [authenticate, requireCouple]);

  // Get all routines for couple
  fastify.get('/', async (request, reply) => {
    const routines = await RoutineService.getRoutines(request.user!.coupleId!);
    return reply.send({ routines });
  });

  // Create routine
  fastify.post(
    '/',
    {
      preHandler: validateBody(createRoutineSchema),
    },
    async (request, reply) => {
      const routine = await RoutineService.createRoutine(
        request.user!.coupleId!,
        request.user!.userId,
        request.body as any
      );

      return reply.status(201).send({
        message: 'Routine created successfully',
        routine,
      });
    }
  );

  // Get routine by ID
  fastify.get('/:routineId', async (request, reply) => {
    const { routineId } = request.params as { routineId: string };
    const routine = await RoutineService.getRoutine(routineId, request.user!.coupleId!);

    return reply.send({ routine });
  });

  // Update routine
  fastify.put(
    '/:routineId',
    {
      preHandler: validateBody(updateRoutineSchema),
    },
    async (request, reply) => {
      const { routineId } = request.params as { routineId: string };
      const routine = await RoutineService.updateRoutine(
        routineId,
        request.user!.coupleId!,
        request.body as any
      );

      return reply.send({
        message: 'Routine updated successfully',
        routine,
      });
    }
  );

  // Delete routine
  fastify.delete('/:routineId', async (request, reply) => {
    const { routineId } = request.params as { routineId: string };
    await RoutineService.deleteRoutine(routineId, request.user!.coupleId!);

    return reply.send({
      message: 'Routine deleted successfully',
    });
  });

  // Get routine occurrences
  fastify.get('/:routineId/occurrences', async (request, reply) => {
    const { routineId } = request.params as { routineId: string };
    const { start, end } = request.query as { start?: string; end?: string };

    const startDate = start ? new Date(start) : undefined;
    const endDate = end ? new Date(end) : undefined;

    const occurrences = await RoutineService.getOccurrences(
      routineId,
      request.user!.coupleId!,
      startDate,
      endDate
    );

    return reply.send({ occurrences });
  });

  // Complete occurrence
  fastify.post('/:routineId/occurrences/:occurrenceId/complete', async (request, reply) => {
    const { occurrenceId } = request.params as { occurrenceId: string };

    const occurrence = await RoutineService.completeOccurrence(
      occurrenceId,
      request.user!.coupleId!,
      request.user!.userId
    );

    return reply.send({
      message: 'Routine occurrence completed',
      occurrence,
    });
  });

  // Uncomplete occurrence
  fastify.post('/:routineId/occurrences/:occurrenceId/uncomplete', async (request, reply) => {
    const { occurrenceId } = request.params as { occurrenceId: string };

    const occurrence = await RoutineService.uncompleteOccurrence(
      occurrenceId,
      request.user!.coupleId!
    );

    return reply.send({
      message: 'Routine occurrence marked as incomplete',
      occurrence,
    });
  });

  // Skip occurrence
  fastify.post('/:routineId/occurrences/:occurrenceId/skip', async (request, reply) => {
    const { occurrenceId } = request.params as { occurrenceId: string };

    const occurrence = await RoutineService.skipOccurrence(
      occurrenceId,
      request.user!.coupleId!
    );

    return reply.send({
      message: 'Routine occurrence skipped',
      occurrence,
    });
  });

  // Get routine statistics
  fastify.get('/:routineId/stats', async (request, reply) => {
    const { routineId } = request.params as { routineId: string };

    const stats = await RoutineService.getRoutineStats(routineId, request.user!.coupleId!);

    return reply.send({ stats });
  });
}

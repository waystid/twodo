import { FastifyInstance } from 'fastify';
import { EventService } from '../services/event.service';
import { requireAuth } from '../middlewares/auth';
import { requireCouple } from '../middlewares/couple';
import { createEventSchema, updateEventSchema, getEventsQuerySchema } from '@twodo/shared';
import { NotFoundError } from '../utils/errors';

export async function eventRoutes(app: FastifyInstance) {
  // Create event
  app.post(
    '/',
    {
      preHandler: [requireAuth, requireCouple],
    },
    async (request, reply) => {
      const coupleId = request.user!.coupleId!;
      const userId = request.user!.id;

      const parsed = createEventSchema.safeParse(request.body);
      if (!parsed.success) {
        return reply.status(400).send({ error: parsed.error.errors[0].message });
      }

      const event = await EventService.createEvent(coupleId, userId, parsed.data);

      return reply.status(201).send({ event });
    }
  );

  // Get events
  app.get(
    '/',
    {
      preHandler: [requireAuth, requireCouple],
    },
    async (request, reply) => {
      const coupleId = request.user!.coupleId!;

      const parsed = getEventsQuerySchema.safeParse(request.query);
      if (!parsed.success) {
        return reply.status(400).send({ error: parsed.error.errors[0].message });
      }

      const events = await EventService.getEvents(coupleId, parsed.data);

      return reply.send({ events });
    }
  );

  // Get upcoming events
  app.get(
    '/upcoming',
    {
      preHandler: [requireAuth, requireCouple],
    },
    async (request, reply) => {
      const coupleId = request.user!.coupleId!;
      const days = request.query?.days ? parseInt(request.query.days as string) : 7;

      const events = await EventService.getUpcomingEvents(coupleId, days);

      return reply.send({ events });
    }
  );

  // Get single event
  app.get(
    '/:id',
    {
      preHandler: [requireAuth, requireCouple],
    },
    async (request, reply) => {
      const coupleId = request.user!.coupleId!;
      const { id } = request.params as { id: string };

      try {
        const event = await EventService.getEvent(id, coupleId);
        return reply.send({ event });
      } catch (error) {
        if (error instanceof NotFoundError) {
          return reply.status(404).send({ error: error.message });
        }
        throw error;
      }
    }
  );

  // Update event
  app.put(
    '/:id',
    {
      preHandler: [requireAuth, requireCouple],
    },
    async (request, reply) => {
      const coupleId = request.user!.coupleId!;
      const userId = request.user!.id;
      const { id } = request.params as { id: string };

      const parsed = updateEventSchema.safeParse(request.body);
      if (!parsed.success) {
        return reply.status(400).send({ error: parsed.error.errors[0].message });
      }

      try {
        const event = await EventService.updateEvent(id, coupleId, userId, parsed.data);
        return reply.send({ event });
      } catch (error) {
        if (error instanceof NotFoundError) {
          return reply.status(404).send({ error: error.message });
        }
        throw error;
      }
    }
  );

  // Delete event
  app.delete(
    '/:id',
    {
      preHandler: [requireAuth, requireCouple],
    },
    async (request, reply) => {
      const coupleId = request.user!.coupleId!;
      const userId = request.user!.id;
      const { id } = request.params as { id: string };

      try {
        await EventService.deleteEvent(id, coupleId, userId);
        return reply.send({ success: true });
      } catch (error) {
        if (error instanceof NotFoundError) {
          return reply.status(404).send({ error: error.message });
        }
        throw error;
      }
    }
  );
}

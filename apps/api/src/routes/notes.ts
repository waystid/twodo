import { FastifyInstance } from 'fastify';
import { NoteService } from '../services/note.service';
import { requireAuth } from '../middlewares/auth';
import { requireCouple } from '../middlewares/couple';
import { createNoteSchema, updateNoteSchema } from '@twodo/shared';
import { NotFoundError } from '../utils/errors';

export async function noteRoutes(app: FastifyInstance) {
  // Create note
  app.post(
    '/',
    {
      preHandler: [requireAuth, requireCouple],
    },
    async (request, reply) => {
      const coupleId = request.user!.coupleId!;
      const userId = request.user!.id;

      const parsed = createNoteSchema.safeParse(request.body);
      if (!parsed.success) {
        return reply.status(400).send({ error: parsed.error.errors[0].message });
      }

      const note = await NoteService.createNote(coupleId, userId, parsed.data);

      return reply.status(201).send({ note });
    }
  );

  // Get notes for an entity
  app.get(
    '/:type/:id',
    {
      preHandler: [requireAuth, requireCouple],
    },
    async (request, reply) => {
      const coupleId = request.user!.coupleId!;
      const { type, id } = request.params as { type: string; id: string };

      if (!['task', 'event', 'routine'].includes(type)) {
        return reply.status(400).send({ error: 'Invalid attachment type' });
      }

      const notes = await NoteService.getNotes(coupleId, type, id);

      return reply.send({ notes });
    }
  );

  // Get single note
  app.get(
    '/:id',
    {
      preHandler: [requireAuth, requireCouple],
    },
    async (request, reply) => {
      const coupleId = request.user!.coupleId!;
      const { id } = request.params as { id: string };

      try {
        const note = await NoteService.getNote(id, coupleId);
        return reply.send({ note });
      } catch (error) {
        if (error instanceof NotFoundError) {
          return reply.status(404).send({ error: error.message });
        }
        throw error;
      }
    }
  );

  // Update note
  app.put(
    '/:id',
    {
      preHandler: [requireAuth, requireCouple],
    },
    async (request, reply) => {
      const coupleId = request.user!.coupleId!;
      const userId = request.user!.id;
      const { id } = request.params as { id: string };

      const parsed = updateNoteSchema.safeParse(request.body);
      if (!parsed.success) {
        return reply.status(400).send({ error: parsed.error.errors[0].message });
      }

      try {
        const note = await NoteService.updateNote(id, coupleId, userId, parsed.data);
        return reply.send({ note });
      } catch (error) {
        if (error instanceof NotFoundError) {
          return reply.status(404).send({ error: error.message });
        }
        throw error;
      }
    }
  );

  // Delete note
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
        await NoteService.deleteNote(id, coupleId, userId);
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

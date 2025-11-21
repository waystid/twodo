import { FastifyInstance } from 'fastify';
import { NotificationService } from '../services/notification.service';
import { requireAuth } from '../middlewares/auth';
import { requireCouple } from '../middlewares/couple';
import { NotFoundError } from '../utils/errors';

export async function notificationRoutes(app: FastifyInstance) {
  // Get all notifications for user
  app.get(
    '/',
    {
      preHandler: [requireAuth, requireCouple],
    },
    async (request, reply) => {
      const userId = request.user!.id;
      const limit = request.query?.limit ? parseInt(request.query.limit as string) : 50;

      const notifications = await NotificationService.getNotifications(userId, limit);

      return reply.send({ notifications });
    }
  );

  // Get unread count
  app.get(
    '/unread-count',
    {
      preHandler: [requireAuth, requireCouple],
    },
    async (request, reply) => {
      const userId = request.user!.id;
      const count = await NotificationService.getUnreadCount(userId);

      return reply.send({ count });
    }
  );

  // Mark notification as read
  app.put(
    '/:id/read',
    {
      preHandler: [requireAuth, requireCouple],
    },
    async (request, reply) => {
      const userId = request.user!.id;
      const { id } = request.params as { id: string };

      try {
        const notification = await NotificationService.markAsRead(id, userId);
        return reply.send({ notification });
      } catch (error) {
        if (error instanceof NotFoundError) {
          return reply.status(404).send({ error: error.message });
        }
        throw error;
      }
    }
  );

  // Mark all notifications as read
  app.put(
    '/read-all',
    {
      preHandler: [requireAuth, requireCouple],
    },
    async (request, reply) => {
      const userId = request.user!.id;
      await NotificationService.markAllAsRead(userId);

      return reply.send({ success: true });
    }
  );

  // Delete notification
  app.delete(
    '/:id',
    {
      preHandler: [requireAuth, requireCouple],
    },
    async (request, reply) => {
      const userId = request.user!.id;
      const { id } = request.params as { id: string };

      try {
        await NotificationService.deleteNotification(id, userId);
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

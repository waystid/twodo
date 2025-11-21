import { db, notifications } from '@twodo/database';
import { eq, and, desc } from 'drizzle-orm';
import type { NotificationType } from '@twodo/shared';
import { NotFoundError } from '../utils/errors';

export class NotificationService {
  // Create notification
  static async createNotification(
    userId: string,
    coupleId: string,
    type: NotificationType,
    title: string,
    body: string,
    relatedEntityType?: string,
    relatedEntityId?: string
  ) {
    const [notification] = await db
      .insert(notifications)
      .values({
        userId,
        coupleId,
        type,
        title,
        body,
        relatedEntityType,
        relatedEntityId,
        isRead: false,
      })
      .returning();

    return notification;
  }

  // Get notifications for user
  static async getNotifications(userId: string, limit: number = 50) {
    const notificationList = await db.query.notifications.findMany({
      where: eq(notifications.userId, userId),
      orderBy: [desc(notifications.createdAt)],
      limit,
    });

    return notificationList;
  }

  // Get unread count
  static async getUnreadCount(userId: string): Promise<number> {
    const unreadNotifications = await db.query.notifications.findMany({
      where: and(eq(notifications.userId, userId), eq(notifications.isRead, false)),
    });

    return unreadNotifications.length;
  }

  // Mark as read
  static async markAsRead(notificationId: string, userId: string) {
    const notification = await db.query.notifications.findFirst({
      where: and(eq(notifications.id, notificationId), eq(notifications.userId, userId)),
    });

    if (!notification) {
      throw new NotFoundError('Notification not found');
    }

    const [updated] = await db
      .update(notifications)
      .set({ isRead: true })
      .where(eq(notifications.id, notificationId))
      .returning();

    return updated;
  }

  // Mark all as read
  static async markAllAsRead(userId: string) {
    await db
      .update(notifications)
      .set({ isRead: true })
      .where(and(eq(notifications.userId, userId), eq(notifications.isRead, false)));

    return { success: true };
  }

  // Delete notification
  static async deleteNotification(notificationId: string, userId: string) {
    const notification = await db.query.notifications.findFirst({
      where: and(eq(notifications.id, notificationId), eq(notifications.userId, userId)),
    });

    if (!notification) {
      throw new NotFoundError('Notification not found');
    }

    await db.delete(notifications).where(eq(notifications.id, notificationId));

    return { success: true };
  }

  // Notification generators for different events
  static async notifyTaskDue(taskId: string, taskTitle: string, coupleId: string, assignedToUserId?: string) {
    // If assigned to specific user, notify them; otherwise notify both
    const coupleUsers = await db.query.coupleUsers.findMany({
      where: eq(db.query.coupleUsers.coupleId, coupleId),
    });

    const usersToNotify = assignedToUserId
      ? coupleUsers.filter((cu) => cu.userId === assignedToUserId)
      : coupleUsers;

    for (const cu of usersToNotify) {
      await this.createNotification(
        cu.userId,
        coupleId,
        'task_due',
        'Task Due Soon',
        `"${taskTitle}" is due soon`,
        'task',
        taskId
      );
    }
  }

  static async notifyTaskAssigned(taskId: string, taskTitle: string, coupleId: string, assignedToUserId: string) {
    await this.createNotification(
      assignedToUserId,
      coupleId,
      'task_assigned',
      'Task Assigned',
      `You were assigned "${taskTitle}"`,
      'task',
      taskId
    );
  }

  static async notifyRoutineDue(routineId: string, routineName: string, coupleId: string, assignedToUserId?: string) {
    const coupleUsers = await db.query.coupleUsers.findMany({
      where: eq(db.query.coupleUsers.coupleId, coupleId),
    });

    const usersToNotify = assignedToUserId
      ? coupleUsers.filter((cu) => cu.userId === assignedToUserId)
      : coupleUsers;

    for (const cu of usersToNotify) {
      await this.createNotification(
        cu.userId,
        coupleId,
        'routine_due',
        'Routine Due Today',
        `"${routineName}" is due today`,
        'routine',
        routineId
      );
    }
  }

  static async notifyEventReminder(eventId: string, eventTitle: string, coupleId: string, assignedToUserId?: string) {
    const coupleUsers = await db.query.coupleUsers.findMany({
      where: eq(db.query.coupleUsers.coupleId, coupleId),
    });

    const usersToNotify = assignedToUserId
      ? coupleUsers.filter((cu) => cu.userId === assignedToUserId)
      : coupleUsers;

    for (const cu of usersToNotify) {
      await this.createNotification(
        cu.userId,
        coupleId,
        'event_reminder',
        'Event Reminder',
        `"${eventTitle}" is coming up`,
        'event',
        eventId
      );
    }
  }
}

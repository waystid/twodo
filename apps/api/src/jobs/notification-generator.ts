import { db, tasks, routines, routineOccurrences, notifications, events } from '@twodo/database';
import { and, eq, lte, gte, isNull, isNotNull } from 'drizzle-orm';
import { NotificationService } from '../services/notification.service';
import { logger } from '../logger';

export class NotificationGeneratorJob {
  private intervalId: NodeJS.Timeout | null = null;
  private readonly CHECK_INTERVAL_MS = 60 * 60 * 1000; // Run every hour

  async run() {
    try {
      logger.info('Notification generator job started');

      await this.checkTasksDueSoon();
      await this.checkRoutinesDueToday();
      await this.checkEventReminders();

      logger.info('Notification generator job completed');
    } catch (error) {
      logger.error('Notification generator job failed:', error);
    }
  }

  private async checkTasksDueSoon() {
    const now = new Date();
    const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000);

    // Find tasks due within 24 hours that are not completed
    const dueTasks = await db.query.tasks.findMany({
      where: and(
        lte(tasks.dueDate, tomorrow),
        gte(tasks.dueDate, now),
        eq(tasks.status, 'pending')
      ),
      with: {
        list: true,
      },
    });

    for (const task of dueTasks) {
      // Check if notification already sent for this task
      const existingNotification = await db.query.notifications.findFirst({
        where: and(
          eq(notifications.relatedEntityType, 'task'),
          eq(notifications.relatedEntityId, task.id),
          eq(notifications.type, 'task_due')
        ),
      });

      if (!existingNotification) {
        await NotificationService.notifyTaskDue(
          task.id,
          task.title,
          task.coupleId,
          task.assignedToUserId || undefined
        );
      }
    }

    logger.info(`Checked ${dueTasks.length} tasks due soon`);
  }

  private async checkRoutinesDueToday() {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    // Find routine occurrences due today that are not completed or skipped
    const dueOccurrences = await db.query.routineOccurrences.findMany({
      where: and(
        gte(routineOccurrences.scheduledDate, today),
        lte(routineOccurrences.scheduledDate, tomorrow),
        isNull(routineOccurrences.completedAt),
        eq(routineOccurrences.skipped, false)
      ),
      with: {
        routine: true,
      },
    });

    for (const occurrence of dueOccurrences) {
      // Check if notification already sent for this occurrence
      const existingNotification = await db.query.notifications.findFirst({
        where: and(
          eq(notifications.relatedEntityType, 'routine'),
          eq(notifications.relatedEntityId, occurrence.routineId),
          eq(notifications.type, 'routine_due')
        ),
      });

      if (!existingNotification) {
        await NotificationService.notifyRoutineDue(
          occurrence.routineId,
          occurrence.routine.name,
          occurrence.routine.coupleId,
          occurrence.routine.assignedToUserId || undefined
        );
      }
    }

    logger.info(`Checked ${dueOccurrences.length} routines due today`);
  }

  private async checkEventReminders() {
    const now = new Date();

    // Find events with reminders that should trigger soon
    const upcomingEvents = await db.query.events.findMany({
      where: and(
        gte(events.startDate, now),
        isNotNull(events.reminderMinutes)
      ),
    });

    for (const event of upcomingEvents) {
      if (!event.reminderMinutes) continue;

      const reminderTime = new Date(event.startDate.getTime() - event.reminderMinutes * 60 * 1000);
      const timeDiff = reminderTime.getTime() - now.getTime();

      // Send reminder if within the next hour and haven't sent yet
      if (timeDiff > 0 && timeDiff <= 60 * 60 * 1000) {
        // Check if notification already sent for this event
        const existingNotification = await db.query.notifications.findFirst({
          where: and(
            eq(notifications.relatedEntityType, 'event'),
            eq(notifications.relatedEntityId, event.id),
            eq(notifications.type, 'event_reminder')
          ),
        });

        if (!existingNotification) {
          await NotificationService.notifyEventReminder(
            event.id,
            event.title,
            event.coupleId,
            event.assignedToUserId || undefined
          );
        }
      }
    }

    logger.info(`Checked ${upcomingEvents.length} events for reminders`);
  }

  start() {
    logger.info('Starting notification generator job');

    // Run immediately on startup
    this.run();

    // Then run every hour
    this.intervalId = setInterval(() => this.run(), this.CHECK_INTERVAL_MS);
  }

  stop() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
      logger.info('Notification generator job stopped');
    }
  }
}

export const notificationGeneratorJob = new NotificationGeneratorJob();

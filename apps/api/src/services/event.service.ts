import { db, events } from '@twodo/database';
import { eq, and, gte, lte, desc } from 'drizzle-orm';
import type { CreateEventInput, UpdateEventInput, GetEventsQuery } from '@twodo/shared';
import { NotFoundError, ForbiddenError } from '../utils/errors';

export class EventService {
  // Create event
  static async createEvent(coupleId: string, userId: string, input: CreateEventInput) {
    const [event] = await db
      .insert(events)
      .values({
        ...input,
        coupleId,
        createdById: userId,
        startDate: new Date(input.startDate),
        endDate: input.endDate ? new Date(input.endDate) : null,
        recurrence: input.recurrence || null,
      })
      .returning();

    return event;
  }

  // Get events (with optional date range)
  static async getEvents(coupleId: string, query?: GetEventsQuery) {
    const conditions = [eq(events.coupleId, coupleId)];

    if (query?.start) {
      conditions.push(gte(events.startDate, new Date(query.start)));
    }

    if (query?.end) {
      conditions.push(lte(events.startDate, new Date(query.end)));
    }

    const eventList = await db.query.events.findMany({
      where: and(...conditions),
      orderBy: [desc(events.startDate)],
      with: {
        createdBy: {
          columns: {
            id: true,
            displayName: true,
            avatarUrl: true,
          },
        },
        assignedTo: {
          columns: {
            id: true,
            displayName: true,
            avatarUrl: true,
          },
        },
      },
    });

    return eventList;
  }

  // Get single event
  static async getEvent(eventId: string, coupleId: string) {
    const event = await db.query.events.findFirst({
      where: and(eq(events.id, eventId), eq(events.coupleId, coupleId)),
      with: {
        createdBy: {
          columns: {
            id: true,
            displayName: true,
            avatarUrl: true,
          },
        },
        assignedTo: {
          columns: {
            id: true,
            displayName: true,
            avatarUrl: true,
          },
        },
      },
    });

    if (!event) {
      throw new NotFoundError('Event not found');
    }

    return event;
  }

  // Update event
  static async updateEvent(eventId: string, coupleId: string, userId: string, input: UpdateEventInput) {
    const event = await db.query.events.findFirst({
      where: and(eq(events.id, eventId), eq(events.coupleId, coupleId)),
    });

    if (!event) {
      throw new NotFoundError('Event not found');
    }

    // Prepare update data
    const updateData: any = { ...input };

    if (input.startDate) {
      updateData.startDate = new Date(input.startDate);
    }

    if (input.endDate !== undefined) {
      updateData.endDate = input.endDate ? new Date(input.endDate) : null;
    }

    if (input.recurrence !== undefined) {
      updateData.recurrence = input.recurrence || null;
    }

    const [updated] = await db
      .update(events)
      .set(updateData)
      .where(eq(events.id, eventId))
      .returning();

    return updated;
  }

  // Delete event
  static async deleteEvent(eventId: string, coupleId: string, userId: string) {
    const event = await db.query.events.findFirst({
      where: and(eq(events.id, eventId), eq(events.coupleId, coupleId)),
    });

    if (!event) {
      throw new NotFoundError('Event not found');
    }

    await db.delete(events).where(eq(events.id, eventId));

    return { success: true };
  }

  // Get upcoming events (next 7 days)
  static async getUpcomingEvents(coupleId: string, days: number = 7) {
    const now = new Date();
    const futureDate = new Date();
    futureDate.setDate(futureDate.getDate() + days);

    const upcomingEvents = await db.query.events.findMany({
      where: and(
        eq(events.coupleId, coupleId),
        gte(events.startDate, now),
        lte(events.startDate, futureDate)
      ),
      orderBy: [desc(events.startDate)],
      with: {
        createdBy: {
          columns: {
            id: true,
            displayName: true,
          },
        },
        assignedTo: {
          columns: {
            id: true,
            displayName: true,
          },
        },
      },
    });

    return upcomingEvents;
  }
}

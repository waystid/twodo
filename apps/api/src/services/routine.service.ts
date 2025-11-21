import { db, routines, routineOccurrences } from '@twodo/database';
import { eq, and, gte, lte, desc } from 'drizzle-orm';
import type { CreateRoutineInput, UpdateRoutineInput } from '@twodo/shared';
import { ForbiddenError, NotFoundError } from '../utils/errors';

export class RoutineService {
  // CRUD for Routines
  static async createRoutine(coupleId: string, userId: string, input: CreateRoutineInput) {
    const [routine] = await db
      .insert(routines)
      .values({
        coupleId,
        name: input.name,
        description: input.description,
        schedule: input.schedule,
        assignedToUserId: input.assignedToUserId,
        isActive: input.isActive ?? true,
        createdById: userId,
      })
      .returning();

    // Generate initial occurrences for the next 30 days
    await this.generateOccurrences(routine.id, new Date(), 30);

    return routine;
  }

  static async getRoutines(coupleId: string) {
    const routineList = await db.query.routines.findMany({
      where: eq(routines.coupleId, coupleId),
      orderBy: [desc(routines.createdAt)],
    });

    return routineList;
  }

  static async getRoutine(routineId: string, coupleId: string) {
    const routine = await db.query.routines.findFirst({
      where: and(eq(routines.id, routineId), eq(routines.coupleId, coupleId)),
    });

    if (!routine) {
      throw new NotFoundError('Routine not found');
    }

    return routine;
  }

  static async updateRoutine(routineId: string, coupleId: string, input: UpdateRoutineInput) {
    await this.getRoutine(routineId, coupleId);

    const [updatedRoutine] = await db
      .update(routines)
      .set({
        ...input,
        updatedAt: new Date(),
      })
      .where(eq(routines.id, routineId))
      .returning();

    // If schedule changed, regenerate future occurrences
    if (input.schedule) {
      // Delete future occurrences that haven't been completed
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      await db
        .delete(routineOccurrences)
        .where(
          and(
            eq(routineOccurrences.routineId, routineId),
            gte(routineOccurrences.scheduledDate, today),
            eq(routineOccurrences.skipped, false)
          )
        );

      // Generate new occurrences
      await this.generateOccurrences(routineId, today, 30);
    }

    return updatedRoutine;
  }

  static async deleteRoutine(routineId: string, coupleId: string) {
    await this.getRoutine(routineId, coupleId);

    await db.delete(routines).where(eq(routines.id, routineId));

    return { success: true };
  }

  // Routine Occurrences
  static async getOccurrences(
    routineId: string,
    coupleId: string,
    startDate?: Date,
    endDate?: Date
  ) {
    await this.getRoutine(routineId, coupleId);

    let query = db.query.routineOccurrences.findMany({
      where: eq(routineOccurrences.routineId, routineId),
      orderBy: [desc(routineOccurrences.scheduledDate)],
    });

    // Apply date filters if provided
    const occurrences = await query;

    return occurrences.filter((occ) => {
      if (startDate && occ.scheduledDate < startDate) return false;
      if (endDate && occ.scheduledDate > endDate) return false;
      return true;
    });
  }

  static async completeOccurrence(occurrenceId: string, coupleId: string, userId: string) {
    const occurrence = await db.query.routineOccurrences.findFirst({
      where: and(
        eq(routineOccurrences.id, occurrenceId),
        eq(routineOccurrences.coupleId, coupleId)
      ),
    });

    if (!occurrence) {
      throw new NotFoundError('Routine occurrence not found');
    }

    const [updated] = await db
      .update(routineOccurrences)
      .set({
        completedAt: new Date(),
        completedById: userId,
        skipped: false,
      })
      .where(eq(routineOccurrences.id, occurrenceId))
      .returning();

    return updated;
  }

  static async uncompleteOccurrence(occurrenceId: string, coupleId: string) {
    const occurrence = await db.query.routineOccurrences.findFirst({
      where: and(
        eq(routineOccurrences.id, occurrenceId),
        eq(routineOccurrences.coupleId, coupleId)
      ),
    });

    if (!occurrence) {
      throw new NotFoundError('Routine occurrence not found');
    }

    const [updated] = await db
      .update(routineOccurrences)
      .set({
        completedAt: null,
        completedById: null,
      })
      .where(eq(routineOccurrences.id, occurrenceId))
      .returning();

    return updated;
  }

  static async skipOccurrence(occurrenceId: string, coupleId: string) {
    const occurrence = await db.query.routineOccurrences.findFirst({
      where: and(
        eq(routineOccurrences.id, occurrenceId),
        eq(routineOccurrences.coupleId, coupleId)
      ),
    });

    if (!occurrence) {
      throw new NotFoundError('Routine occurrence not found');
    }

    const [updated] = await db
      .update(routineOccurrences)
      .set({
        skipped: true,
        completedAt: null,
        completedById: null,
      })
      .where(eq(routineOccurrences.id, occurrenceId))
      .returning();

    return updated;
  }

  // Occurrence Generation
  static async generateOccurrences(routineId: string, startDate: Date, days: number = 30) {
    const routine = await db.query.routines.findFirst({
      where: eq(routines.id, routineId),
    });

    if (!routine || !routine.isActive) {
      return;
    }

    const schedule = routine.schedule as any;
    const endDate = new Date(startDate);
    endDate.setDate(endDate.getDate() + days);

    const occurrenceDates = this.calculateOccurrenceDates(schedule, startDate, endDate);

    // Check which dates already have occurrences
    const existingOccurrences = await db.query.routineOccurrences.findMany({
      where: and(
        eq(routineOccurrences.routineId, routineId),
        gte(routineOccurrences.scheduledDate, startDate),
        lte(routineOccurrences.scheduledDate, endDate)
      ),
    });

    const existingDates = new Set(
      existingOccurrences.map((occ) => occ.scheduledDate.toISOString().split('T')[0])
    );

    // Insert new occurrences
    const newOccurrences = occurrenceDates
      .filter((date) => !existingDates.has(date.toISOString().split('T')[0]))
      .map((date) => ({
        routineId: routine.id,
        coupleId: routine.coupleId,
        scheduledDate: date,
      }));

    if (newOccurrences.length > 0) {
      await db.insert(routineOccurrences).values(newOccurrences);
    }

    return newOccurrences.length;
  }

  // Calculate dates based on schedule
  private static calculateOccurrenceDates(
    schedule: any,
    startDate: Date,
    endDate: Date
  ): Date[] {
    const dates: Date[] = [];
    const current = new Date(startDate);
    current.setHours(0, 0, 0, 0);

    while (current <= endDate) {
      if (this.shouldOccurOnDate(schedule, current)) {
        dates.push(new Date(current));
      }
      current.setDate(current.getDate() + 1);
    }

    return dates;
  }

  private static shouldOccurOnDate(schedule: any, date: Date): boolean {
    const { frequency, daysOfWeek, dayOfMonth } = schedule;

    if (frequency === 'daily') {
      return true;
    }

    if (frequency === 'weekly') {
      const dayOfWeek = date.getDay();
      return daysOfWeek && daysOfWeek.includes(dayOfWeek);
    }

    if (frequency === 'monthly') {
      const day = date.getDate();
      return dayOfMonth === day;
    }

    return false;
  }

  // Calculate streak
  static async calculateStreak(routineId: string, coupleId: string): Promise<number> {
    const occurrences = await db.query.routineOccurrences.findMany({
      where: and(
        eq(routineOccurrences.routineId, routineId),
        eq(routineOccurrences.coupleId, coupleId),
        lte(routineOccurrences.scheduledDate, new Date())
      ),
      orderBy: [desc(routineOccurrences.scheduledDate)],
    });

    let streak = 0;
    for (const occ of occurrences) {
      if (occ.completedAt) {
        streak++;
      } else if (!occ.skipped) {
        // If not completed and not skipped, streak breaks
        break;
      }
      // If skipped, continue checking previous occurrences
    }

    return streak;
  }

  // Get routine statistics
  static async getRoutineStats(routineId: string, coupleId: string) {
    await this.getRoutine(routineId, coupleId);

    const occurrences = await db.query.routineOccurrences.findMany({
      where: and(
        eq(routineOccurrences.routineId, routineId),
        eq(routineOccurrences.coupleId, coupleId)
      ),
    });

    const total = occurrences.length;
    const completed = occurrences.filter((occ) => occ.completedAt).length;
    const skipped = occurrences.filter((occ) => occ.skipped).length;
    const completionRate = total > 0 ? (completed / total) * 100 : 0;
    const currentStreak = await this.calculateStreak(routineId, coupleId);

    return {
      total,
      completed,
      skipped,
      completionRate: Math.round(completionRate),
      currentStreak,
    };
  }

  // Background job: Generate occurrences for all active routines
  static async generateAllOccurrences() {
    const activeRoutines = await db.query.routines.findMany({
      where: eq(routines.isActive, true),
    });

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    let totalGenerated = 0;

    for (const routine of activeRoutines) {
      const generated = await this.generateOccurrences(routine.id, today, 30);
      totalGenerated += generated;
    }

    return { routinesProcessed: activeRoutines.length, occurrencesGenerated: totalGenerated };
  }
}

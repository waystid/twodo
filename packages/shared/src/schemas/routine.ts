import { z } from 'zod';

export const routineFrequencySchema = z.enum(['daily', 'weekly', 'monthly']);

export const routineScheduleSchema = z.object({
  frequency: routineFrequencySchema,
  daysOfWeek: z.array(z.number().int().min(0).max(6)).optional(),
  dayOfMonth: z.number().int().min(1).max(31).optional(),
  time: z.string().regex(/^([0-1][0-9]|2[0-3]):[0-5][0-9]$/, 'Invalid time format').optional(),
});

export const createRoutineSchema = z.object({
  name: z.string().min(1, 'Routine name is required').max(100),
  description: z.string().max(2000).optional(),
  schedule: routineScheduleSchema,
  assignedToUserId: z.string().uuid('Invalid user ID').optional(),
  isActive: z.boolean().default(true),
});

export const updateRoutineSchema = z.object({
  name: z.string().min(1, 'Routine name is required').max(100).optional(),
  description: z.string().max(2000).optional(),
  schedule: routineScheduleSchema.optional(),
  assignedToUserId: z.string().uuid('Invalid user ID').nullable().optional(),
  isActive: z.boolean().optional(),
});

export const completeOccurrenceSchema = z.object({
  completed: z.boolean(),
});

export const skipOccurrenceSchema = z.object({
  skipped: z.boolean(),
});

export type CreateRoutineInput = z.infer<typeof createRoutineSchema>;
export type UpdateRoutineInput = z.infer<typeof updateRoutineSchema>;
export type CompleteOccurrenceInput = z.infer<typeof completeOccurrenceSchema>;
export type SkipOccurrenceInput = z.infer<typeof skipOccurrenceSchema>;

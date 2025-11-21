import { z } from 'zod';

export const recurrenceFrequencySchema = z.enum(['daily', 'weekly', 'monthly', 'yearly']);

export const eventRecurrenceSchema = z.object({
  frequency: recurrenceFrequencySchema,
  interval: z.number().int().min(1).max(365),
  until: z.string().datetime().optional(),
});

export const createEventSchema = z.object({
  title: z.string().min(1, 'Event title is required').max(200),
  description: z.string().max(2000).optional(),
  startDate: z.string().datetime(),
  endDate: z.string().datetime().optional(),
  isAllDay: z.boolean().default(false),
  location: z.string().max(200).optional(),
  assignedToUserId: z.string().uuid('Invalid user ID').optional(),
  reminderMinutes: z.number().int().min(0).max(10080).optional(), // Max 1 week
  recurrence: eventRecurrenceSchema.optional(),
});

export const updateEventSchema = z.object({
  title: z.string().min(1, 'Event title is required').max(200).optional(),
  description: z.string().max(2000).optional(),
  startDate: z.string().datetime().optional(),
  endDate: z.string().datetime().nullable().optional(),
  isAllDay: z.boolean().optional(),
  location: z.string().max(200).optional(),
  assignedToUserId: z.string().uuid('Invalid user ID').nullable().optional(),
  reminderMinutes: z.number().int().min(0).max(10080).nullable().optional(),
  recurrence: eventRecurrenceSchema.nullable().optional(),
});

export const getEventsQuerySchema = z.object({
  start: z.string().datetime().optional(),
  end: z.string().datetime().optional(),
});

export type CreateEventInput = z.infer<typeof createEventSchema>;
export type UpdateEventInput = z.infer<typeof updateEventSchema>;
export type GetEventsQuery = z.infer<typeof getEventsQuerySchema>;

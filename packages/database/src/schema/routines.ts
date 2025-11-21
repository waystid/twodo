import { pgTable, text, timestamp, uuid, boolean, jsonb } from 'drizzle-orm/pg-core';
import { users } from './users';
import { couples } from './couples';

export const routines = pgTable('routines', {
  id: uuid('id').primaryKey().defaultRandom(),
  coupleId: uuid('couple_id')
    .notNull()
    .references(() => couples.id, { onDelete: 'cascade' }),
  name: text('name').notNull(),
  description: text('description'),
  schedule: jsonb('schedule').notNull(),
  assignedToUserId: uuid('assigned_to_user_id').references(() => users.id),
  isActive: boolean('is_active').notNull().default(true),
  createdById: uuid('created_by_id')
    .notNull()
    .references(() => users.id),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
});

export const routineOccurrences = pgTable('routine_occurrences', {
  id: uuid('id').primaryKey().defaultRandom(),
  routineId: uuid('routine_id')
    .notNull()
    .references(() => routines.id, { onDelete: 'cascade' }),
  coupleId: uuid('couple_id')
    .notNull()
    .references(() => couples.id, { onDelete: 'cascade' }),
  scheduledDate: timestamp('scheduled_date').notNull(),
  completedAt: timestamp('completed_at'),
  completedById: uuid('completed_by_id').references(() => users.id),
  skipped: boolean('skipped').notNull().default(false),
  createdAt: timestamp('created_at').notNull().defaultNow(),
});

export type Routine = typeof routines.$inferSelect;
export type NewRoutine = typeof routines.$inferInsert;
export type RoutineOccurrence = typeof routineOccurrences.$inferSelect;
export type NewRoutineOccurrence = typeof routineOccurrences.$inferInsert;

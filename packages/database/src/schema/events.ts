import { pgTable, text, timestamp, uuid, boolean, integer, jsonb } from 'drizzle-orm/pg-core';
import { users } from './users';
import { couples } from './couples';

export const events = pgTable('events', {
  id: uuid('id').primaryKey().defaultRandom(),
  coupleId: uuid('couple_id')
    .notNull()
    .references(() => couples.id, { onDelete: 'cascade' }),
  title: text('title').notNull(),
  description: text('description'),
  startDate: timestamp('start_date').notNull(),
  endDate: timestamp('end_date'),
  isAllDay: boolean('is_all_day').notNull().default(false),
  location: text('location'),
  assignedToUserId: uuid('assigned_to_user_id').references(() => users.id),
  reminderMinutes: integer('reminder_minutes'),
  recurrence: jsonb('recurrence'),
  createdById: uuid('created_by_id')
    .notNull()
    .references(() => users.id),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
});

export type Event = typeof events.$inferSelect;
export type NewEvent = typeof events.$inferInsert;

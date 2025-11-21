import { pgTable, text, timestamp, uuid, pgEnum } from 'drizzle-orm/pg-core';
import { users } from './users';
import { couples } from './couples';

export const noteAttachmentTypeEnum = pgEnum('note_attachment_type', ['task', 'event', 'routine']);

export const notes = pgTable('notes', {
  id: uuid('id').primaryKey().defaultRandom(),
  coupleId: uuid('couple_id')
    .notNull()
    .references(() => couples.id, { onDelete: 'cascade' }),
  content: text('content').notNull(),
  attachedToType: noteAttachmentTypeEnum('attached_to_type').notNull(),
  attachedToId: uuid('attached_to_id').notNull(),
  createdById: uuid('created_by_id')
    .notNull()
    .references(() => users.id),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
});

export type Note = typeof notes.$inferSelect;
export type NewNote = typeof notes.$inferInsert;

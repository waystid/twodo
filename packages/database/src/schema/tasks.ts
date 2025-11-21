import { pgTable, text, timestamp, uuid, integer, pgEnum } from 'drizzle-orm/pg-core';
import { users } from './users';
import { couples } from './couples';

export const taskStatusEnum = pgEnum('task_status', ['todo', 'in_progress', 'completed']);
export const taskPriorityEnum = pgEnum('task_priority', ['low', 'medium', 'high']);

export const taskLists = pgTable('task_lists', {
  id: uuid('id').primaryKey().defaultRandom(),
  coupleId: uuid('couple_id')
    .notNull()
    .references(() => couples.id, { onDelete: 'cascade' }),
  name: text('name').notNull(),
  color: text('color'),
  icon: text('icon'),
  sortOrder: integer('sort_order').notNull().default(0),
  createdById: uuid('created_by_id')
    .notNull()
    .references(() => users.id),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
});

export const tasks = pgTable('tasks', {
  id: uuid('id').primaryKey().defaultRandom(),
  coupleId: uuid('couple_id')
    .notNull()
    .references(() => couples.id, { onDelete: 'cascade' }),
  listId: uuid('list_id')
    .notNull()
    .references(() => taskLists.id, { onDelete: 'cascade' }),
  title: text('title').notNull(),
  description: text('description'),
  assignedToUserId: uuid('assigned_to_user_id').references(() => users.id),
  status: taskStatusEnum('status').notNull().default('todo'),
  priority: taskPriorityEnum('priority'),
  dueDate: timestamp('due_date'),
  completedAt: timestamp('completed_at'),
  completedById: uuid('completed_by_id').references(() => users.id),
  sortOrder: integer('sort_order').notNull().default(0),
  createdById: uuid('created_by_id')
    .notNull()
    .references(() => users.id),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
});

export type TaskList = typeof taskLists.$inferSelect;
export type NewTaskList = typeof taskLists.$inferInsert;
export type Task = typeof tasks.$inferSelect;
export type NewTask = typeof tasks.$inferInsert;

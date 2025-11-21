import { pgTable, text, timestamp, uuid, pgEnum, primaryKey } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';
import { users } from './users';

export const couples = pgTable('couples', {
  id: uuid('id').primaryKey().defaultRandom(),
  name: text('name').notNull(),
  inviteCode: text('invite_code').unique(),
  inviteCodeExpiresAt: timestamp('invite_code_expires_at'),
  createdById: uuid('created_by_id')
    .notNull()
    .references(() => users.id),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
});

export const coupleRoleEnum = pgEnum('couple_role', ['owner', 'member']);

export const coupleUsers = pgTable('couple_users', {
  coupleId: uuid('couple_id')
    .notNull()
    .references(() => couples.id, { onDelete: 'cascade' }),
  userId: uuid('user_id')
    .notNull()
    .references(() => users.id, { onDelete: 'cascade' }),
  role: coupleRoleEnum('role').notNull().default('member'),
  joinedAt: timestamp('joined_at').notNull().defaultNow(),
}, (table) => ({
  pk: primaryKey({ columns: [table.coupleId, table.userId] }),
}));

// Relations
export const usersRelations = relations(users, ({ many }) => ({
  coupleUsers: many(coupleUsers),
}));

export const couplesRelations = relations(couples, ({ one, many }) => ({
  createdBy: one(users, {
    fields: [couples.createdById],
    references: [users.id],
  }),
  coupleUsers: many(coupleUsers),
}));

export const coupleUsersRelations = relations(coupleUsers, ({ one }) => ({
  couple: one(couples, {
    fields: [coupleUsers.coupleId],
    references: [couples.id],
  }),
  user: one(users, {
    fields: [coupleUsers.userId],
    references: [users.id],
  }),
}));

export type Couple = typeof couples.$inferSelect;
export type NewCouple = typeof couples.$inferInsert;
export type CoupleUser = typeof coupleUsers.$inferSelect;
export type NewCoupleUser = typeof coupleUsers.$inferInsert;

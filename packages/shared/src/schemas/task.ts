import { z } from 'zod';

export const taskStatusSchema = z.enum(['todo', 'in_progress', 'completed']);
export const taskPrioritySchema = z.enum(['low', 'medium', 'high']).nullable();

export const createTaskListSchema = z.object({
  name: z.string().min(1, 'List name is required').max(100),
  color: z.string().regex(/^#[0-9A-Fa-f]{6}$/, 'Invalid color format').optional(),
  icon: z.string().max(50).optional(),
  sortOrder: z.number().int().min(0).optional(),
});

export const updateTaskListSchema = z.object({
  name: z.string().min(1, 'List name is required').max(100).optional(),
  color: z.string().regex(/^#[0-9A-Fa-f]{6}$/, 'Invalid color format').optional(),
  icon: z.string().max(50).optional(),
  sortOrder: z.number().int().min(0).optional(),
});

export const createTaskSchema = z.object({
  listId: z.string().uuid('Invalid list ID'),
  title: z.string().min(1, 'Task title is required').max(200),
  description: z.string().max(2000).optional(),
  assignedToUserId: z.string().uuid('Invalid user ID').optional(),
  status: taskStatusSchema.optional(),
  priority: taskPrioritySchema.optional(),
  dueDate: z.string().datetime().optional(),
  sortOrder: z.number().int().min(0).optional(),
});

export const updateTaskSchema = z.object({
  listId: z.string().uuid('Invalid list ID').optional(),
  title: z.string().min(1, 'Task title is required').max(200).optional(),
  description: z.string().max(2000).optional(),
  assignedToUserId: z.string().uuid('Invalid user ID').nullable().optional(),
  status: taskStatusSchema.optional(),
  priority: taskPrioritySchema.optional(),
  dueDate: z.string().datetime().nullable().optional(),
  sortOrder: z.number().int().min(0).optional(),
});

export const assignTaskSchema = z.object({
  assignedToUserId: z.string().uuid('Invalid user ID').nullable(),
});

export const completeTaskSchema = z.object({
  completed: z.boolean(),
});

export type CreateTaskListInput = z.infer<typeof createTaskListSchema>;
export type UpdateTaskListInput = z.infer<typeof updateTaskListSchema>;
export type CreateTaskInput = z.infer<typeof createTaskSchema>;
export type UpdateTaskInput = z.infer<typeof updateTaskSchema>;
export type AssignTaskInput = z.infer<typeof assignTaskSchema>;
export type CompleteTaskInput = z.infer<typeof completeTaskSchema>;

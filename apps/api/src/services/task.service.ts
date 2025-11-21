import { db, taskLists, tasks } from '@twodo/database';
import { eq, and, desc } from 'drizzle-orm';
import type {
  CreateTaskListInput,
  UpdateTaskListInput,
  CreateTaskInput,
  UpdateTaskInput,
} from '@twodo/shared';
import { ForbiddenError, NotFoundError } from '../utils/errors';

export class TaskService {
  // Task Lists
  static async createTaskList(coupleId: string, userId: string, input: CreateTaskListInput) {
    const [taskList] = await db
      .insert(taskLists)
      .values({
        coupleId,
        name: input.name,
        color: input.color,
        icon: input.icon,
        sortOrder: input.sortOrder ?? 0,
        createdById: userId,
      })
      .returning();

    return taskList;
  }

  static async getTaskLists(coupleId: string) {
    const lists = await db.query.taskLists.findMany({
      where: eq(taskLists.coupleId, coupleId),
      orderBy: [taskLists.sortOrder, taskLists.createdAt],
    });

    return lists;
  }

  static async getTaskList(listId: string, coupleId: string) {
    const list = await db.query.taskLists.findFirst({
      where: and(eq(taskLists.id, listId), eq(taskLists.coupleId, coupleId)),
    });

    if (!list) {
      throw new NotFoundError('Task list not found');
    }

    return list;
  }

  static async updateTaskList(
    listId: string,
    coupleId: string,
    input: UpdateTaskListInput
  ) {
    // Verify list belongs to couple
    await this.getTaskList(listId, coupleId);

    const [updatedList] = await db
      .update(taskLists)
      .set({
        ...input,
        updatedAt: new Date(),
      })
      .where(eq(taskLists.id, listId))
      .returning();

    return updatedList;
  }

  static async deleteTaskList(listId: string, coupleId: string) {
    // Verify list belongs to couple
    await this.getTaskList(listId, coupleId);

    await db.delete(taskLists).where(eq(taskLists.id, listId));

    return { success: true };
  }

  // Tasks
  static async createTask(coupleId: string, userId: string, input: CreateTaskInput) {
    // Verify list belongs to couple
    await this.getTaskList(input.listId, coupleId);

    const [task] = await db
      .insert(tasks)
      .values({
        coupleId,
        listId: input.listId,
        title: input.title,
        description: input.description,
        assignedToUserId: input.assignedToUserId,
        status: input.status ?? 'todo',
        priority: input.priority,
        dueDate: input.dueDate ? new Date(input.dueDate) : undefined,
        sortOrder: input.sortOrder ?? 0,
        createdById: userId,
      })
      .returning();

    return task;
  }

  static async getTasks(coupleId: string, listId?: string) {
    const where = listId
      ? and(eq(tasks.coupleId, coupleId), eq(tasks.listId, listId))
      : eq(tasks.coupleId, coupleId);

    const taskList = await db.query.tasks.findMany({
      where,
      orderBy: [tasks.sortOrder, desc(tasks.createdAt)],
    });

    return taskList;
  }

  static async getTask(taskId: string, coupleId: string) {
    const task = await db.query.tasks.findFirst({
      where: and(eq(tasks.id, taskId), eq(tasks.coupleId, coupleId)),
    });

    if (!task) {
      throw new NotFoundError('Task not found');
    }

    return task;
  }

  static async updateTask(taskId: string, coupleId: string, input: UpdateTaskInput) {
    // Verify task belongs to couple
    await this.getTask(taskId, coupleId);

    // If listId is being changed, verify new list belongs to couple
    if (input.listId) {
      await this.getTaskList(input.listId, coupleId);
    }

    const updateData: any = {
      ...input,
      updatedAt: new Date(),
    };

    // Handle date conversion
    if (input.dueDate) {
      updateData.dueDate = new Date(input.dueDate);
    } else if (input.dueDate === null) {
      updateData.dueDate = null;
    }

    const [updatedTask] = await db
      .update(tasks)
      .set(updateData)
      .where(eq(tasks.id, taskId))
      .returning();

    return updatedTask;
  }

  static async completeTask(taskId: string, coupleId: string, userId: string, completed: boolean) {
    // Verify task belongs to couple
    await this.getTask(taskId, coupleId);

    const [updatedTask] = await db
      .update(tasks)
      .set({
        status: completed ? 'completed' : 'todo',
        completedAt: completed ? new Date() : null,
        completedById: completed ? userId : null,
        updatedAt: new Date(),
      })
      .where(eq(tasks.id, taskId))
      .returning();

    return updatedTask;
  }

  static async assignTask(
    taskId: string,
    coupleId: string,
    assignedToUserId: string | null
  ) {
    // Verify task belongs to couple
    await this.getTask(taskId, coupleId);

    const [updatedTask] = await db
      .update(tasks)
      .set({
        assignedToUserId,
        updatedAt: new Date(),
      })
      .where(eq(tasks.id, taskId))
      .returning();

    return updatedTask;
  }

  static async deleteTask(taskId: string, coupleId: string) {
    // Verify task belongs to couple
    await this.getTask(taskId, coupleId);

    await db.delete(tasks).where(eq(tasks.id, taskId));

    return { success: true };
  }
}

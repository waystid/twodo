import { FastifyInstance } from 'fastify';
import {
  createTaskListSchema,
  updateTaskListSchema,
  createTaskSchema,
  updateTaskSchema,
  assignTaskSchema,
  completeTaskSchema,
} from '@twodo/shared';
import { TaskService } from '../services/task.service';
import { authenticate, requireCouple } from '../middleware/auth';
import { validateBody } from '../middleware/validate';

export async function taskRoutes(fastify: FastifyInstance) {
  // All routes require authentication and couple membership
  fastify.addHook('preHandler', [authenticate, requireCouple]);

  // ===== Task Lists =====

  // Get all task lists for couple
  fastify.get('/lists', async (request, reply) => {
    const lists = await TaskService.getTaskLists(request.user!.coupleId!);
    return reply.send({ lists });
  });

  // Create task list
  fastify.post(
    '/lists',
    {
      preHandler: validateBody(createTaskListSchema),
    },
    async (request, reply) => {
      const list = await TaskService.createTaskList(
        request.user!.coupleId!,
        request.user!.userId,
        request.body as any
      );

      return reply.status(201).send({
        message: 'Task list created successfully',
        list,
      });
    }
  );

  // Get task list by ID
  fastify.get('/lists/:listId', async (request, reply) => {
    const { listId } = request.params as { listId: string };
    const list = await TaskService.getTaskList(listId, request.user!.coupleId!);

    return reply.send({ list });
  });

  // Update task list
  fastify.put(
    '/lists/:listId',
    {
      preHandler: validateBody(updateTaskListSchema),
    },
    async (request, reply) => {
      const { listId } = request.params as { listId: string };
      const list = await TaskService.updateTaskList(
        listId,
        request.user!.coupleId!,
        request.body as any
      );

      return reply.send({
        message: 'Task list updated successfully',
        list,
      });
    }
  );

  // Delete task list
  fastify.delete('/lists/:listId', async (request, reply) => {
    const { listId } = request.params as { listId: string };
    await TaskService.deleteTaskList(listId, request.user!.coupleId!);

    return reply.send({
      message: 'Task list deleted successfully',
    });
  });

  // ===== Tasks =====

  // Get all tasks (optionally filtered by list)
  fastify.get('/tasks', async (request, reply) => {
    const { listId } = request.query as { listId?: string };
    const tasks = await TaskService.getTasks(request.user!.coupleId!, listId);

    return reply.send({ tasks });
  });

  // Create task
  fastify.post(
    '/tasks',
    {
      preHandler: validateBody(createTaskSchema),
    },
    async (request, reply) => {
      const task = await TaskService.createTask(
        request.user!.coupleId!,
        request.user!.userId,
        request.body as any
      );

      return reply.status(201).send({
        message: 'Task created successfully',
        task,
      });
    }
  );

  // Get task by ID
  fastify.get('/tasks/:taskId', async (request, reply) => {
    const { taskId } = request.params as { taskId: string };
    const task = await TaskService.getTask(taskId, request.user!.coupleId!);

    return reply.send({ task });
  });

  // Update task
  fastify.put(
    '/tasks/:taskId',
    {
      preHandler: validateBody(updateTaskSchema),
    },
    async (request, reply) => {
      const { taskId } = request.params as { taskId: string };
      const task = await TaskService.updateTask(
        taskId,
        request.user!.coupleId!,
        request.body as any
      );

      return reply.send({
        message: 'Task updated successfully',
        task,
      });
    }
  );

  // Complete/uncomplete task
  fastify.post(
    '/tasks/:taskId/complete',
    {
      preHandler: validateBody(completeTaskSchema),
    },
    async (request, reply) => {
      const { taskId } = request.params as { taskId: string };
      const { completed } = request.body as { completed: boolean };

      const task = await TaskService.completeTask(
        taskId,
        request.user!.coupleId!,
        request.user!.userId,
        completed
      );

      return reply.send({
        message: completed ? 'Task completed' : 'Task marked as incomplete',
        task,
      });
    }
  );

  // Assign task
  fastify.post(
    '/tasks/:taskId/assign',
    {
      preHandler: validateBody(assignTaskSchema),
    },
    async (request, reply) => {
      const { taskId } = request.params as { taskId: string };
      const { assignedToUserId } = request.body as { assignedToUserId: string | null };

      const task = await TaskService.assignTask(
        taskId,
        request.user!.coupleId!,
        assignedToUserId
      );

      return reply.send({
        message: 'Task assigned successfully',
        task,
      });
    }
  );

  // Delete task
  fastify.delete('/tasks/:taskId', async (request, reply) => {
    const { taskId } = request.params as { taskId: string };
    await TaskService.deleteTask(taskId, request.user!.coupleId!);

    return reply.send({
      message: 'Task deleted successfully',
    });
  });
}

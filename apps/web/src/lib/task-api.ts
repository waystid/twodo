import { apiClient } from './api';
import type {
  CreateTaskListInput,
  UpdateTaskListInput,
  CreateTaskInput,
  UpdateTaskInput,
  TaskList,
  Task,
} from '@twodo/shared';

export const taskApi = {
  // Task Lists
  async getTaskLists(): Promise<{ lists: TaskList[] }> {
    return apiClient.get('/lists');
  },

  async createTaskList(data: CreateTaskListInput): Promise<{ list: TaskList }> {
    return apiClient.post('/lists', data);
  },

  async getTaskList(listId: string): Promise<{ list: TaskList }> {
    return apiClient.get(`/lists/${listId}`);
  },

  async updateTaskList(listId: string, data: UpdateTaskListInput): Promise<{ list: TaskList }> {
    return apiClient.put(`/lists/${listId}`, data);
  },

  async deleteTaskList(listId: string): Promise<{ message: string }> {
    return apiClient.delete(`/lists/${listId}`);
  },

  // Tasks
  async getTasks(listId?: string): Promise<{ tasks: Task[] }> {
    const url = listId ? `/tasks?listId=${listId}` : '/tasks';
    return apiClient.get(url);
  },

  async createTask(data: CreateTaskInput): Promise<{ task: Task }> {
    return apiClient.post('/tasks', data);
  },

  async getTask(taskId: string): Promise<{ task: Task }> {
    return apiClient.get(`/tasks/${taskId}`);
  },

  async updateTask(taskId: string, data: UpdateTaskInput): Promise<{ task: Task }> {
    return apiClient.put(`/tasks/${taskId}`, data);
  },

  async completeTask(taskId: string, completed: boolean): Promise<{ task: Task }> {
    return apiClient.post(`/tasks/${taskId}/complete`, { completed });
  },

  async assignTask(taskId: string, assignedToUserId: string | null): Promise<{ task: Task }> {
    return apiClient.post(`/tasks/${taskId}/assign`, { assignedToUserId });
  },

  async deleteTask(taskId: string): Promise<{ message: string }> {
    return apiClient.delete(`/tasks/${taskId}`);
  },
};

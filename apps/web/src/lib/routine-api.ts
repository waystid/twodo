import { apiClient } from './api';
import type {
  CreateRoutineInput,
  UpdateRoutineInput,
  Routine,
  RoutineOccurrence,
} from '@twodo/shared';

export const routineApi = {
  // Routines
  async getRoutines(): Promise<{ routines: Routine[] }> {
    return apiClient.get('/routines');
  },

  async createRoutine(data: CreateRoutineInput): Promise<{ routine: Routine }> {
    return apiClient.post('/routines', data);
  },

  async getRoutine(routineId: string): Promise<{ routine: Routine }> {
    return apiClient.get(`/routines/${routineId}`);
  },

  async updateRoutine(routineId: string, data: UpdateRoutineInput): Promise<{ routine: Routine }> {
    return apiClient.put(`/routines/${routineId}`, data);
  },

  async deleteRoutine(routineId: string): Promise<{ message: string }> {
    return apiClient.delete(`/routines/${routineId}`);
  },

  // Occurrences
  async getOccurrences(
    routineId: string,
    start?: string,
    end?: string
  ): Promise<{ occurrences: RoutineOccurrence[] }> {
    let url = `/routines/${routineId}/occurrences`;
    const params = new URLSearchParams();
    if (start) params.append('start', start);
    if (end) params.append('end', end);
    if (params.toString()) url += `?${params.toString()}`;

    return apiClient.get(url);
  },

  async completeOccurrence(
    routineId: string,
    occurrenceId: string
  ): Promise<{ occurrence: RoutineOccurrence }> {
    return apiClient.post(`/routines/${routineId}/occurrences/${occurrenceId}/complete`);
  },

  async uncompleteOccurrence(
    routineId: string,
    occurrenceId: string
  ): Promise<{ occurrence: RoutineOccurrence }> {
    return apiClient.post(`/routines/${routineId}/occurrences/${occurrenceId}/uncomplete`);
  },

  async skipOccurrence(
    routineId: string,
    occurrenceId: string
  ): Promise<{ occurrence: RoutineOccurrence }> {
    return apiClient.post(`/routines/${routineId}/occurrences/${occurrenceId}/skip`);
  },

  async getRoutineStats(
    routineId: string
  ): Promise<{
    stats: {
      total: number;
      completed: number;
      skipped: number;
      completionRate: number;
      currentStreak: number;
    };
  }> {
    return apiClient.get(`/routines/${routineId}/stats`);
  },
};

import { apiClient } from './api';
import type { UpdateProfileInput, UpdatePasswordInput, UpdateCoupleInput } from '@twodo/shared';

export const settingsApi = {
  async getSettings(): Promise<{ user: any; couple: any }> {
    return apiClient.get('/settings');
  },

  async updateProfile(data: UpdateProfileInput): Promise<{ user: any }> {
    return apiClient.put('/settings/profile', data);
  },

  async updatePassword(data: UpdatePasswordInput): Promise<{ success: boolean; message: string }> {
    return apiClient.put('/settings/password', data);
  },

  async updateCouple(data: UpdateCoupleInput): Promise<{ couple: any }> {
    return apiClient.put('/settings/couple', data);
  },
};

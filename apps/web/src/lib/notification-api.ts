import { apiClient } from './api';
import type { Notification } from '@twodo/shared';

export const notificationApi = {
  async getNotifications(limit?: number): Promise<{ notifications: Notification[] }> {
    const url = limit ? `/notifications?limit=${limit}` : '/notifications';
    return apiClient.get(url);
  },

  async getUnreadCount(): Promise<{ count: number }> {
    return apiClient.get('/notifications/unread-count');
  },

  async markAsRead(notificationId: string): Promise<{ notification: Notification }> {
    return apiClient.put(`/notifications/${notificationId}/read`);
  },

  async markAllAsRead(): Promise<{ success: boolean }> {
    return apiClient.put('/notifications/read-all');
  },

  async deleteNotification(notificationId: string): Promise<{ success: boolean }> {
    return apiClient.delete(`/notifications/${notificationId}`);
  },
};

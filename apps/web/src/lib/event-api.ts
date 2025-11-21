import { apiClient } from './api';
import type { Event, CreateEventInput, UpdateEventInput, GetEventsQuery } from '@twodo/shared';

export const eventApi = {
  async getEvents(query?: GetEventsQuery): Promise<{ events: Event[] }> {
    let url = '/events';
    if (query) {
      const params = new URLSearchParams();
      if (query.start) params.append('start', query.start);
      if (query.end) params.append('end', query.end);
      if (params.toString()) url += `?${params.toString()}`;
    }
    return apiClient.get(url);
  },

  async getUpcomingEvents(days?: number): Promise<{ events: Event[] }> {
    const url = days ? `/events/upcoming?days=${days}` : '/events/upcoming';
    return apiClient.get(url);
  },

  async getEvent(eventId: string): Promise<{ event: Event }> {
    return apiClient.get(`/events/${eventId}`);
  },

  async createEvent(data: CreateEventInput): Promise<{ event: Event }> {
    return apiClient.post('/events', data);
  },

  async updateEvent(eventId: string, data: UpdateEventInput): Promise<{ event: Event }> {
    return apiClient.put(`/events/${eventId}`, data);
  },

  async deleteEvent(eventId: string): Promise<{ success: boolean }> {
    return apiClient.delete(`/events/${eventId}`);
  },
};

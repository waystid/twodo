export type RecurrenceFrequency = 'daily' | 'weekly' | 'monthly' | 'yearly';

export interface EventRecurrence {
  frequency: RecurrenceFrequency;
  interval: number;
  until?: Date;
}

export interface Event {
  id: string;
  coupleId: string;
  title: string;
  description?: string;
  startDate: Date;
  endDate?: Date;
  isAllDay: boolean;
  location?: string;
  assignedToUserId?: string;
  reminderMinutes?: number;
  recurrence?: EventRecurrence;
  createdById: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface EventWithDetails extends Event {
  assignedTo?: {
    id: string;
    displayName: string;
    avatarUrl?: string;
  };
  createdBy: {
    id: string;
    displayName: string;
    avatarUrl?: string;
  };
}

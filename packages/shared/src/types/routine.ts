export type RoutineFrequency = 'daily' | 'weekly' | 'monthly';

export interface RoutineSchedule {
  frequency: RoutineFrequency;
  daysOfWeek?: number[]; // 0-6 for Sun-Sat
  dayOfMonth?: number; // 1-31
  time?: string; // "HH:mm" format
}

export interface Routine {
  id: string;
  coupleId: string;
  name: string;
  description?: string;
  schedule: RoutineSchedule;
  assignedToUserId?: string;
  isActive: boolean;
  createdById: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface RoutineOccurrence {
  id: string;
  routineId: string;
  coupleId: string;
  scheduledDate: Date;
  completedAt?: Date;
  completedById?: string;
  skipped: boolean;
  createdAt: Date;
}

export interface RoutineWithOccurrences extends Routine {
  upcomingOccurrences: RoutineOccurrence[];
  completionRate?: number;
  currentStreak?: number;
}

export interface RoutineOccurrenceWithDetails extends RoutineOccurrence {
  routine: Routine;
  completedBy?: {
    id: string;
    displayName: string;
    avatarUrl?: string;
  };
}

export type TaskStatus = 'todo' | 'in_progress' | 'completed';
export type TaskPriority = 'low' | 'medium' | 'high' | null;

export interface TaskList {
  id: string;
  coupleId: string;
  name: string;
  color?: string;
  icon?: string;
  sortOrder: number;
  createdById: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface Task {
  id: string;
  coupleId: string;
  listId: string;
  title: string;
  description?: string;
  assignedToUserId?: string;
  status: TaskStatus;
  priority: TaskPriority;
  dueDate?: Date;
  completedAt?: Date;
  completedById?: string;
  sortOrder: number;
  createdById: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface TaskWithList extends Task {
  list: TaskList;
}

export interface TaskWithDetails extends Task {
  list: TaskList;
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
  completedBy?: {
    id: string;
    displayName: string;
    avatarUrl?: string;
  };
}

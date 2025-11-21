export interface User {
  id: string;
  email: string;
  passwordHash: string;
  displayName: string;
  avatarUrl?: string;
  timezone: string;
  notificationPreferences: {
    push: boolean;
    email: boolean;
    quietHoursStart?: string;
    quietHoursEnd?: string;
  };
  emailVerified: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface UserPublic {
  id: string;
  email: string;
  displayName: string;
  avatarUrl?: string;
  timezone: string;
}

export interface UserProfile extends UserPublic {
  notificationPreferences: User['notificationPreferences'];
  emailVerified: boolean;
  createdAt: Date;
  updatedAt: Date;
}

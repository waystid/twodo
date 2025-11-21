export interface Couple {
  id: string;
  name: string;
  inviteCode?: string;
  inviteCodeExpiresAt?: Date;
  createdById: string;
  createdAt: Date;
  updatedAt: Date;
}

export type CoupleRole = 'owner' | 'member';

export interface CoupleUser {
  coupleId: string;
  userId: string;
  role: CoupleRole;
  joinedAt: Date;
}

export interface CoupleWithMembers extends Couple {
  members: Array<{
    userId: string;
    displayName: string;
    avatarUrl?: string;
    role: CoupleRole;
  }>;
}

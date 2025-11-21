import { z } from 'zod';

export const updateProfileSchema = z.object({
  displayName: z.string().min(1, 'Display name is required').max(100).optional(),
  timezone: z.string().max(50).optional(),
  avatarUrl: z.string().url('Invalid avatar URL').max(500).optional(),
});

export const updatePasswordSchema = z.object({
  currentPassword: z.string().min(8, 'Current password is required'),
  newPassword: z.string().min(8, 'Password must be at least 8 characters long'),
});

export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;
export type UpdatePasswordInput = z.infer<typeof updatePasswordSchema>;

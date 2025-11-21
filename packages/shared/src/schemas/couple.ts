import { z } from 'zod';

export const createCoupleSchema = z.object({
  name: z.string().min(1, 'Couple name is required').max(100),
});

export const updateCoupleSchema = z.object({
  name: z.string().min(1, 'Couple name is required').max(100).optional(),
});

export const joinCoupleSchema = z.object({
  inviteCode: z.string().length(16, 'Invalid invite code'),
});

export type CreateCoupleInput = z.infer<typeof createCoupleSchema>;
export type UpdateCoupleInput = z.infer<typeof updateCoupleSchema>;
export type JoinCoupleInput = z.infer<typeof joinCoupleSchema>;

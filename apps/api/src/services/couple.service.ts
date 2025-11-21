import { db, couples, coupleUsers } from '@twodo/database';
import { eq, and } from 'drizzle-orm';
import type { CreateCoupleInput, JoinCoupleInput } from '@twodo/shared';
import { PasswordService } from './auth.service';
import { ConflictError, NotFoundError, BadRequestError, ForbiddenError } from '../utils/errors';

export class CoupleService {
  static async createCouple(userId: string, input: CreateCoupleInput) {
    // Check if user is already in a couple
    const existingCoupleUser = await db.query.coupleUsers.findFirst({
      where: eq(coupleUsers.userId, userId),
    });

    if (existingCoupleUser) {
      throw new ConflictError('You are already part of a couple');
    }

    // Create couple
    const [couple] = await db
      .insert(couples)
      .values({
        name: input.name,
        createdById: userId,
      })
      .returning();

    // Add creator as owner
    await db.insert(coupleUsers).values({
      coupleId: couple.id,
      userId,
      role: 'owner',
    });

    return couple;
  }

  static async getCouple(coupleId: string, userId: string) {
    // Verify user is member of this couple
    const membership = await db.query.coupleUsers.findFirst({
      where: and(
        eq(coupleUsers.coupleId, coupleId),
        eq(coupleUsers.userId, userId)
      ),
    });

    if (!membership) {
      throw new ForbiddenError('You are not a member of this couple');
    }

    const couple = await db.query.couples.findFirst({
      where: eq(couples.id, coupleId),
      with: {
        coupleUsers: {
          with: {
            user: true,
          },
        },
      },
    });

    if (!couple) {
      throw new NotFoundError('Couple not found');
    }

    // Format response
    return {
      ...couple,
      members: couple.coupleUsers.map((cu) => ({
        userId: cu.user.id,
        displayName: cu.user.displayName,
        avatarUrl: cu.user.avatarUrl,
        role: cu.role,
        joinedAt: cu.joinedAt,
      })),
    };
  }

  static async generateInviteCode(coupleId: string, userId: string) {
    // Verify user is owner of this couple
    const membership = await db.query.coupleUsers.findFirst({
      where: and(
        eq(coupleUsers.coupleId, coupleId),
        eq(coupleUsers.userId, userId)
      ),
    });

    if (!membership) {
      throw new ForbiddenError('You are not a member of this couple');
    }

    if (membership.role !== 'owner') {
      throw new ForbiddenError('Only the couple owner can generate invite codes');
    }

    // Check if couple already has 2 members
    const members = await db.query.coupleUsers.findMany({
      where: eq(coupleUsers.coupleId, coupleId),
    });

    if (members.length >= 2) {
      throw new BadRequestError('This couple already has 2 members');
    }

    // Generate invite code
    const inviteCode = PasswordService.generateToken(8); // 16 char code
    const inviteCodeExpiresAt = PasswordService.getTokenExpiry(48); // 48 hours

    const [updatedCouple] = await db
      .update(couples)
      .set({
        inviteCode,
        inviteCodeExpiresAt,
        updatedAt: new Date(),
      })
      .where(eq(couples.id, coupleId))
      .returning();

    return {
      inviteCode: updatedCouple.inviteCode,
      expiresAt: updatedCouple.inviteCodeExpiresAt,
    };
  }

  static async joinCouple(userId: string, input: JoinCoupleInput) {
    // Check if user is already in a couple
    const existingCoupleUser = await db.query.coupleUsers.findFirst({
      where: eq(coupleUsers.userId, userId),
    });

    if (existingCoupleUser) {
      throw new ConflictError('You are already part of a couple');
    }

    // Find couple by invite code
    const couple = await db.query.couples.findFirst({
      where: eq(couples.inviteCode, input.inviteCode),
    });

    if (!couple) {
      throw new BadRequestError('Invalid invite code');
    }

    // Check if invite code is expired
    if (couple.inviteCodeExpiresAt && couple.inviteCodeExpiresAt < new Date()) {
      throw new BadRequestError('This invite code has expired');
    }

    // Check if couple already has 2 members
    const members = await db.query.coupleUsers.findMany({
      where: eq(coupleUsers.coupleId, couple.id),
    });

    if (members.length >= 2) {
      throw new BadRequestError('This couple already has 2 members');
    }

    // Add user to couple
    await db.insert(coupleUsers).values({
      coupleId: couple.id,
      userId,
      role: 'member',
    });

    // Clear invite code (one-time use)
    await db
      .update(couples)
      .set({
        inviteCode: null,
        inviteCodeExpiresAt: null,
        updatedAt: new Date(),
      })
      .where(eq(couples.id, couple.id));

    return couple;
  }

  static async updateCouple(coupleId: string, userId: string, input: { name: string }) {
    // Verify user is member of this couple
    const membership = await db.query.coupleUsers.findFirst({
      where: and(
        eq(coupleUsers.coupleId, coupleId),
        eq(coupleUsers.userId, userId)
      ),
    });

    if (!membership) {
      throw new ForbiddenError('You are not a member of this couple');
    }

    const [updatedCouple] = await db
      .update(couples)
      .set({
        name: input.name,
        updatedAt: new Date(),
      })
      .where(eq(couples.id, coupleId))
      .returning();

    return updatedCouple;
  }

  static async leaveCouple(coupleId: string, userId: string) {
    // Verify user is member of this couple
    const membership = await db.query.coupleUsers.findFirst({
      where: and(
        eq(coupleUsers.coupleId, coupleId),
        eq(coupleUsers.userId, userId)
      ),
    });

    if (!membership) {
      throw new ForbiddenError('You are not a member of this couple');
    }

    // Remove user from couple
    await db
      .delete(coupleUsers)
      .where(
        and(
          eq(coupleUsers.coupleId, coupleId),
          eq(coupleUsers.userId, userId)
        )
      );

    // If this was the last member, delete the couple
    const remainingMembers = await db.query.coupleUsers.findMany({
      where: eq(coupleUsers.coupleId, coupleId),
    });

    if (remainingMembers.length === 0) {
      await db.delete(couples).where(eq(couples.id, coupleId));
    }

    return { success: true };
  }
}

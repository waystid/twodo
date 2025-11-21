import { FastifyRequest, FastifyReply } from 'fastify';
import { UnauthorizedError } from '../utils/errors';

declare module 'fastify' {
  interface FastifyRequest {
    user?: {
      userId: string;
      coupleId?: string;
    };
  }
}

export async function authenticate(request: FastifyRequest, reply: FastifyReply) {
  try {
    await request.jwtVerify();

    const payload = request.user as any;
    request.user = {
      userId: payload.userId,
      coupleId: payload.coupleId,
    };
  } catch (error) {
    throw new UnauthorizedError('Invalid or expired token');
  }
}

export async function requireCouple(request: FastifyRequest, reply: FastifyReply) {
  if (!request.user?.coupleId) {
    throw new UnauthorizedError('You must be part of a couple to access this resource');
  }
}

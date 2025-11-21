import bcrypt from 'bcrypt';
import crypto from 'crypto';
import { FastifyJWT } from '@fastify/jwt';

const SALT_ROUNDS = 12;

export class PasswordService {
  static async hash(password: string): Promise<string> {
    return bcrypt.hash(password, SALT_ROUNDS);
  }

  static async compare(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }

  static generateToken(length: number = 32): string {
    return crypto.randomBytes(length).toString('hex');
  }

  static getTokenExpiry(hours: number = 24): Date {
    const expiry = new Date();
    expiry.setHours(expiry.getHours() + hours);
    return expiry;
  }
}

export interface JWTPayload {
  userId: string;
  coupleId?: string;
}

export class TokenService {
  static generateAccessToken(fastify: any, payload: JWTPayload): string {
    return fastify.jwt.sign(payload);
  }

  static generateRefreshToken(fastify: any, payload: JWTPayload): string {
    return fastify.jwt.sign(payload, {
      expiresIn: '7d',
    });
  }

  static async verifyToken(fastify: any, token: string): Promise<JWTPayload> {
    return fastify.jwt.verify(token) as JWTPayload;
  }
}

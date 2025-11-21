import Fastify from 'fastify';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import rateLimit from '@fastify/rate-limit';
import jwt from '@fastify/jwt';
import cookie from '@fastify/cookie';
import { config } from './config';
import { logger } from './logger';
import errorHandler from './plugins/error-handler';
import { authRoutes } from './routes/auth';

export async function buildApp() {
  const app = Fastify({
    logger,
    trustProxy: true,
  });

  // Security plugins
  await app.register(helmet, {
    contentSecurityPolicy: config.env === 'production',
  });

  await app.register(cors, {
    origin: config.web.url,
    credentials: true,
  });

  await app.register(rateLimit, {
    max: config.rateLimit.max,
    timeWindow: config.rateLimit.windowMs,
  });

  // Auth plugins
  await app.register(jwt, {
    secret: config.jwt.secret,
    sign: {
      expiresIn: config.jwt.expiresIn,
    },
  });

  await app.register(cookie, {
    secret: config.jwt.refreshSecret,
    parseOptions: {},
  });

  // Error handler
  await app.register(errorHandler);

  // Health check
  app.get('/health', async () => {
    return { status: 'ok', timestamp: new Date().toISOString() };
  });

  // API routes
  await app.register(authRoutes, { prefix: '/api/auth' });
  // await app.register(coupleRoutes, { prefix: '/api/couples' });
  // etc.

  return app;
}

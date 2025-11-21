import { FastifyRequest, FastifyReply } from 'fastify';
import { ZodSchema } from 'zod';

export function validateBody(schema: ZodSchema) {
  return async (request: FastifyRequest, reply: FastifyReply) => {
    const result = schema.safeParse(request.body);
    if (!result.success) {
      return reply.status(422).send({
        error: 'Validation Error',
        message: 'Request body validation failed',
        errors: result.error.errors,
      });
    }
    request.body = result.data;
  };
}

export function validateQuery(schema: ZodSchema) {
  return async (request: FastifyRequest, reply: FastifyReply) => {
    const result = schema.safeParse(request.query);
    if (!result.success) {
      return reply.status(422).send({
        error: 'Validation Error',
        message: 'Query parameters validation failed',
        errors: result.error.errors,
      });
    }
    request.query = result.data;
  };
}

export function validateParams(schema: ZodSchema) {
  return async (request: FastifyRequest, reply: FastifyReply) => {
    const result = schema.safeParse(request.params);
    if (!result.success) {
      return reply.status(422).send({
        error: 'Validation Error',
        message: 'URL parameters validation failed',
        errors: result.error.errors,
      });
    }
    request.params = result.data;
  };
}

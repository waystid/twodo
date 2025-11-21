import { FastifyInstance, FastifyError, FastifyReply, FastifyRequest } from 'fastify';
import fp from 'fastify-plugin';
import { ZodError } from 'zod';
import { AppError, ValidationError } from '../utils/errors';

async function errorHandlerPlugin(fastify: FastifyInstance) {
  fastify.setErrorHandler((error: FastifyError | Error, request: FastifyRequest, reply: FastifyReply) => {
    request.log.error(error);

    // Handle Zod validation errors
    if (error instanceof ZodError) {
      const validationError = new ValidationError('Validation failed', error.errors);
      return reply.status(422).send({
        error: 'Validation Error',
        message: validationError.message,
        errors: validationError.errors,
      });
    }

    // Handle custom AppError
    if (error instanceof AppError) {
      return reply.status(error.statusCode).send({
        error: error.name,
        message: error.message,
        code: error.code,
      });
    }

    // Handle Fastify errors
    if ('statusCode' in error && typeof error.statusCode === 'number') {
      return reply.status(error.statusCode).send({
        error: error.name,
        message: error.message,
      });
    }

    // Default 500 error
    return reply.status(500).send({
      error: 'Internal Server Error',
      message: 'An unexpected error occurred',
    });
  });
}

export default fp(errorHandlerPlugin);

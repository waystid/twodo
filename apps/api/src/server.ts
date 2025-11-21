import { buildApp } from './app';
import { config } from './config';
import { logger } from './logger';
import { routineGeneratorJob } from './jobs/routine-generator';

async function start() {
  try {
    const app = await buildApp();

    await app.listen({
      port: config.port,
      host: config.host,
    });

    logger.info(`Server listening on http://${config.host}:${config.port}`);

    // Start background jobs
    routineGeneratorJob.start();
  } catch (error) {
    logger.error(error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  routineGeneratorJob.stop();
  process.exit(0);
});

start();

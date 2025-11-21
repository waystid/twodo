import { buildApp } from './app';
import { config } from './config';
import { logger } from './logger';
import { routineGeneratorJob } from './jobs/routine-generator';
import { notificationGeneratorJob } from './jobs/notification-generator';

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
    notificationGeneratorJob.start();
  } catch (error) {
    logger.error(error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  routineGeneratorJob.stop();
  notificationGeneratorJob.stop();
  process.exit(0);
});

start();

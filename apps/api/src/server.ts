import { buildApp } from './app';
import { config } from './config';
import { logger } from './logger';

async function start() {
  try {
    const app = await buildApp();

    await app.listen({
      port: config.port,
      host: config.host,
    });

    logger.info(`Server listening on http://${config.host}:${config.port}`);
  } catch (error) {
    logger.error(error);
    process.exit(1);
  }
}

start();

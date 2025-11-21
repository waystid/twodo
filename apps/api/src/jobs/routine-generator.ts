import { RoutineService } from '../services/routine.service';
import { logger } from '../logger';

export class RoutineGeneratorJob {
  private intervalId: NodeJS.Timeout | null = null;

  // Run every 24 hours (daily at midnight)
  start() {
    logger.info('Starting routine occurrence generator job');

    // Run immediately on startup
    this.run();

    // Calculate time until next midnight
    const now = new Date();
    const tomorrow = new Date(now);
    tomorrow.setDate(tomorrow.getDate() + 1);
    tomorrow.setHours(0, 0, 0, 0);

    const msUntilMidnight = tomorrow.getTime() - now.getTime();

    // Run at midnight, then every 24 hours
    setTimeout(() => {
      this.run();
      this.intervalId = setInterval(() => this.run(), 24 * 60 * 60 * 1000);
    }, msUntilMidnight);

    logger.info(`Next routine generation scheduled for ${tomorrow.toISOString()}`);
  }

  async run() {
    try {
      logger.info('Generating routine occurrences...');
      const result = await RoutineService.generateAllOccurrences();
      logger.info(
        `Generated ${result.occurrencesGenerated} occurrences for ${result.routinesProcessed} routines`
      );
    } catch (error) {
      logger.error('Error generating routine occurrences:', error);
    }
  }

  stop() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
      logger.info('Routine occurrence generator job stopped');
    }
  }
}

export const routineGeneratorJob = new RoutineGeneratorJob();

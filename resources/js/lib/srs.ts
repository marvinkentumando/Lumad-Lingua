import { Timestamp } from 'firebase/firestore';

/**
 * SuperMemo-2 Algorithm
 * @param quality 0-5 (0: total blackout, 5: perfect response)
 * @param interval current interval in days
 * @param easeFactor current ease factor
 * @returns { interval: number, easeFactor: number }
 */
export function calculateSRS(quality: number, interval: number, easeFactor: number) {
  let nextInterval: number;
  let nextEaseFactor: number;

  if (quality >= 3) {
    if (interval === 0) {
      nextInterval = 1;
    } else if (interval === 1) {
      nextInterval = 6;
    } else {
      nextInterval = Math.round(interval * easeFactor);
    }
    nextEaseFactor = easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
  } else {
    nextInterval = 1;
    nextEaseFactor = easeFactor;
  }

  if (nextEaseFactor < 1.3) nextEaseFactor = 1.3;
  
  // Safety cap: max interval of 10 years (3650 days) to prevent Firestore range errors
  if (nextInterval > 3650) nextInterval = 3650;
  if (isNaN(nextInterval) || nextInterval < 0) nextInterval = 1;

  const nextReview = new Date();
  nextReview.setDate(nextReview.getDate() + nextInterval);

  return {
    nextReview: Timestamp.fromDate(nextReview),
    interval: nextInterval,
    easeFactor: nextEaseFactor
  };
}

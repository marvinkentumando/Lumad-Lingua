/**
 * Dynamic Time Warping (DTW) for audio waveform comparison.
 * This is a simplified version for demonstration.
 */
export const calculateDTW = (s: number[], t: number[]): number => {
  const n = s.length;
  const m = t.length;
  const dtw = Array.from({ length: n + 1 }, () => Array(m + 1).fill(Infinity));

  dtw[0][0] = 0;

  for (let i = 1; i <= n; i++) {
    for (let j = 1; j <= m; j++) {
      const cost = Math.abs(s[i - 1] - t[j - 1]);
      dtw[i][j] = cost + Math.min(dtw[i - 1][j], dtw[i][j - 1], dtw[i - 1][j - 1]);
    }
  }

  // Normalize by path length
  return dtw[n][m] / (n + m);
};

export const getSimilarityScore = (s: number[], t: number[]): number => {
  const distance = calculateDTW(s, t);
  // Convert distance to a 0-100 score
  const score = Math.max(0, 100 - distance);
  return Math.round(score);
};

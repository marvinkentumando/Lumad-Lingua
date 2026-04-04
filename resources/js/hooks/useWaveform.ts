import { useState, useEffect } from 'react';

export const useWaveform = (audioUrl: string | null) => {
  const [waveform, setWaveform] = useState<number[]>([]);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    if (!audioUrl) {
      setWaveform([]);
      return;
    }

    setIsLoading(true);
    // Mock waveform generation
    setTimeout(() => {
      const mockWaveform = Array.from({ length: 100 }, () => Math.random() * 100);
      setWaveform(mockWaveform);
      setIsLoading(false);
    }, 500);
  }, [audioUrl]);

  return { waveform, isLoading };
};

import React from 'react';
import { motion } from 'framer-motion';

interface MatchActivityProps {
  content: any[];
  matchedPairs: number;
  selectedLeft: any;
  selectedRight: any;
  handleMatch: (side: 'left' | 'right', idx: number, word: string) => void;
}

export const MatchActivity: React.FC<MatchActivityProps> = ({ content, matchedPairs, selectedLeft, selectedRight, handleMatch }) => {
  return (
    <motion.div 
      key="match"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      className="w-full max-w-4xl space-y-12"
    >
      <div className="text-center space-y-2">
        <span className="px-4 py-1 bg-orange-500/20 text-orange-400 rounded-full text-[10px] font-black uppercase tracking-widest border border-orange-500/30">🔗 Word Matching</span>
        <div className="text-cream/40 font-mono text-xs">{matchedPairs} / {content.length} pairs matched</div>
      </div>

      <div className="grid grid-cols-2 gap-12">
        <div className="space-y-4">
          {content.map((pair: any, i: number) => (
            <button 
              key={i}
              onClick={() => handleMatch('left', i, pair.left)}
              className={`w-full p-6 rounded-3xl border-2 transition-all text-left text-xl font-headline font-bold ${
                selectedLeft?.idx === i 
                  ? 'bg-primary/10 border-primary text-primary' 
                  : 'bg-white/5 border-white/10 text-cream/80 hover:bg-white/10'
              }`}
            >
              {pair.left}
            </button>
          ))}
        </div>
        <div className="space-y-4">
          {[...content].sort((a, b) => a.right.localeCompare(b.right)).map((pair: any, i: number) => (
            <button 
              key={i}
              onClick={() => handleMatch('right', i, pair.left)}
              className={`w-full p-6 rounded-3xl border-2 transition-all text-left text-lg font-bold ${
                selectedRight?.idx === i 
                  ? 'bg-primary/10 border-primary text-primary' 
                  : 'bg-white/5 border-white/10 text-cream/80 hover:bg-white/10'
              }`}
            >
              {pair.right}
            </button>
          ))}
        </div>
      </div>
    </motion.div>
  );
};

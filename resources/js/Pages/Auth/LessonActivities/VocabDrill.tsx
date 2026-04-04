import React from 'react';
import { motion } from 'framer-motion';

interface VocabDrillProps {
  content: any[];
  vocabIndex: number;
  vocabFlipped: boolean;
  setVocabFlipped: (flipped: boolean) => void;
  nextStep: () => void;
  setVocabIndex: (index: number | ((prev: number) => number)) => void;
}

export const VocabDrill: React.FC<VocabDrillProps> = ({ content, vocabIndex, vocabFlipped, setVocabFlipped, nextStep, setVocabIndex }) => {
  return (
    <motion.div 
      key="vocab"
      initial={{ opacity: 0, scale: 0.9 }}
      animate={{ opacity: 1, scale: 1 }}
      exit={{ opacity: 0, scale: 0.9 }}
      className="w-full max-w-xl space-y-8"
    >
      <div className="text-center space-y-2">
        <span className="px-4 py-1 bg-green-500/20 text-green-400 rounded-full text-[10px] font-black uppercase tracking-widest border border-green-500/30">📝 Vocabulary Drill</span>
        <div className="text-cream/40 font-mono text-xs">Word {vocabIndex + 1} of {content.length}</div>
      </div>

      <motion.div 
        onClick={() => setVocabFlipped(!vocabFlipped)}
        className="aspect-[4/3] bg-white/5 border border-white/10 rounded-[3rem] p-12 flex flex-col items-center justify-center text-center cursor-pointer hover:bg-white/10 transition-all gold-shadow relative overflow-hidden group touch-none"
      >
        {!vocabFlipped ? (
          <>
            <img 
              src={`https://picsum.photos/seed/${content[vocabIndex].word}/400/300`} 
              alt={content[vocabIndex].word}
              className="w-32 h-32 rounded-2xl mb-6 object-cover border-2 border-primary/20"
              referrerPolicy="no-referrer"
            />
            <div className="text-6xl font-headline font-bold text-cream mb-4">{content[vocabIndex].word}</div>
            <div className="mt-12 text-[10px] font-black uppercase tracking-widest text-primary/40">Tap to reveal meaning</div>
          </>
        ) : (
          <motion.div 
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="space-y-6"
          >
            <div className="text-3xl font-bold text-primary">{content[vocabIndex].meaning}</div>
            <div className="text-lg text-cream/60 italic">{content[vocabIndex].context}</div>
          </motion.div>
        )}
      </motion.div>

      {vocabFlipped && (
        <div className="flex gap-4">
          <button 
            onClick={() => {
              if (vocabIndex < content.length - 1) {
                setVocabIndex(prev => prev + 1);
                setVocabFlipped(false);
              } else {
                nextStep();
              }
            }} 
            className="flex-1 bg-primary text-forest py-4 rounded-2xl font-black gold-shadow hover:-translate-y-1 transition-all"
          >
            {vocabIndex < content.length - 1 ? 'Next Word →' : 'Continue →'}
          </button>
        </div>
      )}
    </motion.div>
  );
};

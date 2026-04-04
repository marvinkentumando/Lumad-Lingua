import React from 'react';
import { motion } from 'framer-motion';
import { Trophy, Star, ArrowRight, RotateCcw, Share2, Zap, Target, Clock } from 'lucide-react';

interface ResultsProps {
  xpEarned: number;
  accuracy: number;
  streak: number;
  timeSpent: string;
  onContinue: () => void;
  onRetry: () => void;
}

const Results: React.FC<ResultsProps> = ({ 
  xpEarned = 120, 
  accuracy = 94, 
  streak = 12, 
  timeSpent = "04:20", 
  onContinue, 
  onRetry 
}) => {
  return (
    <motion.div 
      initial={{ opacity: 0, scale: 0.9 }}
      animate={{ opacity: 1, scale: 1 }}
      className="max-w-4xl mx-auto py-12 px-6 text-center space-y-12"
    >
      <div className="space-y-4">
        <motion.div 
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.2 }}
          className="text-8xl mb-6"
        >
          🏆
        </motion.div>
        <h2 className="text-6xl font-headline font-bold text-primary tracking-tight">Ascension Complete!</h2>
        <p className="text-cream/40 text-xl font-medium">You've reached a new peak in your ancestral journey.</p>
      </div>

      <div className="flex justify-center gap-6">
        {[1, 2, 3].map(s => (
          <motion.div
            key={s}
            initial={{ scale: 0, rotate: -20 }}
            animate={{ scale: 1, rotate: 0 }}
            transition={{ delay: 0.4 + (s * 0.1), type: "spring" }}
          >
            <Star className={`w-16 h-16 ${s <= (accuracy > 80 ? 3 : accuracy > 50 ? 2 : 1) ? 'text-primary fill-primary gold-shadow' : 'text-white/10'}`} />
          </motion.div>
        ))}
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
        {[
          { label: 'XP Earned', val: `+${xpEarned}`, icon: Zap, color: 'text-primary' },
          { label: 'Accuracy', val: `${accuracy}%`, icon: Target, color: 'text-green-500' },
          { label: 'Best Streak', val: `${streak}`, icon: Trophy, color: 'text-orange-500' },
          { label: 'Time Spent', val: timeSpent, icon: Clock, color: 'text-blue-400' },
        ].map((stat, i) => (
          <motion.div 
            key={i}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.6 + (i * 0.1) }}
            className="bg-white/5 border border-white/10 rounded-[2.5rem] p-8 space-y-3"
          >
            <stat.icon className={`w-6 h-6 ${stat.color} mx-auto`} />
            <div className="text-3xl font-black text-cream">{stat.val}</div>
            <div className="text-[10px] font-black uppercase tracking-widest text-cream/20">{stat.label}</div>
          </motion.div>
        ))}
      </div>

      <div className="bg-primary/5 border border-primary/20 rounded-[3rem] p-10 max-w-2xl mx-auto relative overflow-hidden group">
        <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-primary to-orange-500"></div>
        <div className="relative z-10 flex flex-col md:flex-row items-center gap-8 text-left">
          <div className="w-20 h-20 bg-primary/10 rounded-3xl flex items-center justify-center text-4xl">🌱</div>
          <div className="flex-1">
            <h4 className="text-xl font-bold text-cream mb-2">Wisdom Gained</h4>
            <p className="text-cream/60 text-sm leading-relaxed">Your understanding of the <em className="text-primary not-italic font-bold">Mansaka</em> kinship terms has significantly improved. You are now 15% closer to Level 13.</p>
          </div>
        </div>
      </div>

      <div className="flex flex-col sm:flex-row gap-4 justify-center pt-8">
        <button 
          onClick={onRetry}
          className="px-10 py-5 rounded-2xl font-black text-cream/60 border border-white/10 hover:bg-white/5 transition-all flex items-center justify-center gap-3"
        >
          <RotateCcw className="w-5 h-5" />
          Retry Lesson
        </button>
        <button 
          onClick={onContinue}
          className="px-12 py-5 rounded-2xl font-black text-forest bg-primary gold-shadow hover:-translate-y-1 transition-all flex items-center justify-center gap-3"
        >
          Continue Journey
          <ArrowRight className="w-5 h-5" />
        </button>
        <button className="p-5 rounded-2xl border border-white/10 text-cream/40 hover:text-primary transition-all">
          <Share2 className="w-6 h-6" />
        </button>
      </div>
    </motion.div>
  );
};

export default Results;

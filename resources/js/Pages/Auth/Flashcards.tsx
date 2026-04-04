import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Sparkles, RotateCcw, Check, X, Volume2, Info, ChevronLeft, ChevronRight, Bookmark } from 'lucide-react';

const Flashcards: React.FC = () => {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isFlipped, setIsFlipped] = useState(false);
  const [direction, setDirection] = useState(0);
  const [knownCount, setKnownCount] = useState(0);
  const [unknownCount, setUnknownCount] = useState(0);
  const [bookmarked, setBookmarked] = useState<Set<number>>(new Set());

  const cards = [
    { term: 'Kalumanan', phonetic: '/ ka·lu·ma·nan /', meaning: 'Heritage / Ancestry', example: 'Ang kalumanan ay dapat ingatan.', origin: 'Mansaka' },
    { term: 'Balay', phonetic: '/ ba·lay /', meaning: 'House / Home', example: 'Magbalik ta sa balay.', origin: 'Mandaya' },
    { term: 'Datu', phonetic: '/ da·tu /', meaning: 'Chief / Leader', example: 'Ang datu ay matalino.', origin: 'Mansaka' },
    { term: 'Diwata', phonetic: '/ di·wa·ta /', meaning: 'Nature Spirit', example: 'Ang diwata ay nakatira sa bundok.', origin: 'Mandaya' },
    { term: 'Dagmay', phonetic: '/ dag·may /', meaning: 'Traditional Cloth', example: 'Maganda ang dagmay.', origin: 'Mansaka' },
  ];

  const handleNext = (isKnown: boolean) => {
    if (isKnown) setKnownCount(prev => prev + 1);
    else setUnknownCount(prev => prev + 1);

    setDirection(1);
    setIsFlipped(false);
    setTimeout(() => {
      setCurrentIndex((prev) => (prev + 1) % cards.length);
    }, 200);
  };

  const handlePrev = () => {
    setDirection(-1);
    setIsFlipped(false);
    setTimeout(() => {
      setCurrentIndex((prev) => (prev - 1 + cards.length) % cards.length);
    }, 200);
  };

  const toggleBookmark = (idx: number) => {
    const newBookmarks = new Set(bookmarked);
    if (newBookmarks.has(idx)) newBookmarks.delete(idx);
    else newBookmarks.add(idx);
    setBookmarked(newBookmarks);
  };

  const currentCard = cards[currentIndex];

  return (
    <motion.div 
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="max-w-4xl mx-auto py-12 px-6 space-y-12"
    >
      <div className="flex items-center justify-between">
        <div className="space-y-1">
          <h2 className="text-4xl font-headline font-bold text-primary tracking-tight">Ancestral Echoes</h2>
          <p className="text-cream/40 text-sm font-medium uppercase tracking-widest">Flashcard Mastery · {currentIndex + 1} / {cards.length}</p>
        </div>
        <div className="flex gap-4">
          <div className="bg-green-500/10 border border-green-500/20 px-4 py-2 rounded-xl flex items-center gap-2">
            <Check className="w-4 h-4 text-green-500" />
            <span className="text-green-500 font-bold">{knownCount}</span>
          </div>
          <div className="bg-red-500/10 border border-red-500/20 px-4 py-2 rounded-xl flex items-center gap-2">
            <X className="w-4 h-4 text-red-500" />
            <span className="text-red-500 font-bold">{unknownCount}</span>
          </div>
        </div>
      </div>

      <div className="relative h-[500px] perspective-1000">
        <AnimatePresence mode="wait" custom={direction}>
          <motion.div
            key={currentIndex}
            custom={direction}
            initial={{ x: direction * 300, opacity: 0, rotateY: 0 }}
            animate={{ x: 0, opacity: 1, rotateY: isFlipped ? 180 : 0 }}
            exit={{ x: -direction * 300, opacity: 0 }}
            transition={{ type: "spring", stiffness: 300, damping: 30 }}
            onClick={() => setIsFlipped(!isFlipped)}
            className="w-full h-full relative cursor-pointer preserve-3d transition-transform duration-700"
            style={{ transformStyle: 'preserve-3d' }}
          >
            {/* Front */}
            <div className={`absolute inset-0 bg-white/5 border border-white/10 rounded-[4rem] p-16 flex flex-col items-center justify-center text-center backface-hidden gold-shadow ${isFlipped ? 'opacity-0' : 'opacity-100'}`} style={{ backfaceVisibility: 'hidden' }}>
              <div className="absolute top-10 left-10 flex items-center gap-2 text-[10px] font-black uppercase tracking-widest text-primary/40">
                <Sparkles className="w-3 h-3" />
                <span>{currentCard.origin}</span>
              </div>
              <button 
                onClick={(e) => { e.stopPropagation(); toggleBookmark(currentIndex); }}
                className="absolute top-10 right-10 p-3 hover:bg-white/5 rounded-full transition-colors"
              >
                <Bookmark className={`w-6 h-6 ${bookmarked.has(currentIndex) ? 'text-primary fill-primary' : 'text-cream/20'}`} />
              </button>
              
              <div className="text-7xl font-headline font-bold text-cream mb-6 tracking-tight">{currentCard.term}</div>
              <div className="text-2xl font-body italic text-cream/30">{currentCard.phonetic}</div>
              
              <div className="mt-20 flex items-center gap-4 text-cream/20 font-black uppercase tracking-widest text-xs">
                <RotateCcw className="w-4 h-4" />
                Tap to Flip
              </div>
            </div>

            {/* Back */}
            <div className={`absolute inset-0 bg-primary/5 border border-primary/20 rounded-[4rem] p-16 flex flex-col items-center justify-center text-center backface-hidden gold-shadow ${isFlipped ? 'opacity-100' : 'opacity-0'}`} style={{ backfaceVisibility: 'hidden', transform: 'rotateY(180deg)' }}>
              <div className="text-4xl font-bold text-primary mb-8">{currentCard.meaning}</div>
              <div className="max-w-md space-y-6">
                <div className="bg-white/5 border-l-2 border-primary/40 p-6 rounded-r-2xl text-left italic text-cream/70 text-lg leading-relaxed">
                  "{currentCard.example}"
                </div>
                <div className="flex justify-center gap-4">
                  <button className="w-12 h-12 bg-primary/10 text-primary rounded-xl flex items-center justify-center hover:bg-primary hover:text-forest transition-all">
                    <Volume2 className="w-6 h-6" />
                  </button>
                  <button className="w-12 h-12 bg-white/5 text-cream/40 rounded-xl flex items-center justify-center hover:bg-white/10 transition-all">
                    <Info className="w-6 h-6" />
                  </button>
                </div>
              </div>
              
              <div className="mt-12 text-cream/20 font-black uppercase tracking-widest text-xs">
                Tap to Flip Back
              </div>
            </div>
          </motion.div>
        </AnimatePresence>
      </div>

      <div className="flex items-center justify-center gap-8">
        <button 
          onClick={handlePrev}
          className="w-16 h-16 bg-white/5 border border-white/10 rounded-full flex items-center justify-center text-cream/40 hover:text-primary transition-all hover:scale-110"
        >
          <ChevronLeft className="w-8 h-8" />
        </button>

        <div className="flex gap-6">
          <button 
            onClick={() => handleNext(false)}
            className="group flex flex-col items-center gap-3"
          >
            <div className="w-20 h-20 bg-red-500/10 border border-red-500/20 rounded-3xl flex items-center justify-center text-red-500 group-hover:bg-red-500 group-hover:text-white transition-all shadow-xl">
              <X className="w-10 h-10" />
            </div>
            <span className="text-[10px] font-black uppercase tracking-widest text-cream/20 group-hover:text-red-500 transition-colors">Still Learning</span>
          </button>

          <button 
            onClick={() => handleNext(true)}
            className="group flex flex-col items-center gap-3"
          >
            <div className="w-20 h-20 bg-green-500/10 border border-green-500/20 rounded-3xl flex items-center justify-center text-green-500 group-hover:bg-green-500 group-hover:text-white transition-all shadow-xl">
              <Check className="w-10 h-10" />
            </div>
            <span className="text-[10px] font-black uppercase tracking-widest text-cream/20 group-hover:text-green-500 transition-colors">Mastered</span>
          </button>
        </div>

        <button 
          onClick={() => handleNext(true)}
          className="w-16 h-16 bg-white/5 border border-white/10 rounded-full flex items-center justify-center text-cream/40 hover:text-primary transition-all hover:scale-110"
        >
          <ChevronRight className="w-8 h-8" />
        </button>
      </div>
    </motion.div>
  );
};

export default Flashcards;

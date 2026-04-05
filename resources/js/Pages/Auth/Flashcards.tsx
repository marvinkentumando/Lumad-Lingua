import React, { useState, useEffect, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Sparkles, RotateCcw, Check, X, Volume2, Info, ChevronLeft, ChevronRight, Bookmark, Loader2 } from 'lucide-react';
import { useFirebase } from '../../Contexts/FirebaseContext';
import { DICTIONARY_WORDS } from '../../constants/dictionaryData';
import { GoogleGenAI, Modality } from "@google/genai";
import { toast } from 'sonner';

const Flashcards: React.FC = () => {
  const { profile, updateProfile } = useFirebase();
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isFlipped, setIsFlipped] = useState(false);
  const [direction, setDirection] = useState(0);
  const [isSpeaking, setIsSpeaking] = useState(false);

  // Dynamic Deck: Prioritize mistakes, then bookmarks, then dictionary words
  const cards = useMemo(() => {
    const dictionaryCards = DICTIONARY_WORDS.map(word => ({
      id: word.term,
      term: word.term,
      phonetic: `[ ${word.pos} ]`,
      meaning: word.english,
      example: word.example.replace(/"/g, ''),
      origin: word.tag || 'Lumad'
    }));

    if (!profile) return dictionaryCards;

    const mistakes = profile.mistakes || [];
    const bookmarks = profile.bookmarks || [];

    // Create a set of IDs for easy lookup
    const mistakeCards = dictionaryCards.filter(c => mistakes.includes(c.term));
    const bookmarkCards = dictionaryCards.filter(c => bookmarks.includes(c.term) && !mistakes.includes(c.term));
    const otherCards = dictionaryCards.filter(c => !mistakes.includes(c.term) && !bookmarks.includes(c.term));

    // Combine: Mistakes first, then bookmarks, then others
    return [...mistakeCards, ...bookmarkCards, ...otherCards];
  }, [profile?.mistakes, profile?.bookmarks]);

  const handleNext = async (isKnown: boolean) => {
    if (!profile) return;

    const currentTerm = cards[currentIndex].term;
    const updates: any = {};
    
    if (isKnown) {
      updates.masteredCount = (profile.masteredCount || 0) + 1;
      updates.xp = (profile.xp || 0) + 10;
      // Remove from mistakes if mastered
      if (profile.mistakes?.includes(currentTerm)) {
        updates.mistakes = profile.mistakes.filter(m => m !== currentTerm);
      }
    } else {
      updates.learningCount = (profile.learningCount || 0) + 1;
      // Add to mistakes if not already there
      if (!profile.mistakes?.includes(currentTerm)) {
        updates.mistakes = [...(profile.mistakes || []), currentTerm];
      }
    }
    
    await updateProfile(updates);

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

  const toggleBookmark = async (term: string) => {
    if (!profile) return;
    
    const currentBookmarks = profile.bookmarks || [];
    let newBookmarks: string[];
    
    if (currentBookmarks.includes(term)) {
      newBookmarks = currentBookmarks.filter(b => b !== term);
      toast.info('Removed from bookmarks');
    } else {
      newBookmarks = [...currentBookmarks, term];
      toast.success('Added to bookmarks');
    }
    
    await updateProfile({ bookmarks: newBookmarks });
  };

  const handleSpeak = async (text: string) => {
    if (isSpeaking) return;
    setIsSpeaking(true);
    
    try {
      const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY! });
      const response = await ai.models.generateContent({
        model: "gemini-2.5-flash-preview-tts",
        contents: [{ parts: [{ text: `Say clearly: ${text}` }] }],
        config: {
          responseModalities: [Modality.AUDIO],
          speechConfig: {
            voiceConfig: {
              prebuiltVoiceConfig: { voiceName: 'Kore' },
            },
          },
        },
      });

      const base64Audio = response.candidates?.[0]?.content?.parts?.[0]?.inlineData?.data;
      if (base64Audio) {
        const binaryString = atob(base64Audio);
        const len = binaryString.length;
        const bytes = new Uint8Array(len);
        for (let i = 0; i < len; i++) {
          bytes[i] = binaryString.charCodeAt(i);
        }
        
        // Convert PCM16 to Float32
        const float32Data = new Float32Array(bytes.length / 2);
        const dataView = new DataView(bytes.buffer);
        for (let i = 0; i < float32Data.length; i++) {
          float32Data[i] = dataView.getInt16(i * 2, true) / 32768.0;
        }

        const audioCtx = new (window.AudioContext || (window as any).webkitAudioContext)();
        const audioBuffer = audioCtx.createBuffer(1, float32Data.length, 24000);
        audioBuffer.getChannelData(0).set(float32Data);

        const source = audioCtx.createBufferSource();
        source.buffer = audioBuffer;
        source.connect(audioCtx.destination);
        source.onended = () => setIsSpeaking(false);
        source.start();
      } else {
        throw new Error('No audio data received');
      }
    } catch (error) {
      console.error('TTS Error:', error);
      toast.error('Failed to play pronunciation');
      setIsSpeaking(false);
    }
  };

  const currentCard = cards[currentIndex];
  const isBookmarked = profile?.bookmarks?.includes(currentCard.term);

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
            <span className="text-green-500 font-bold">{profile?.masteredCount || 0}</span>
          </div>
          <div className="bg-red-500/10 border border-red-500/20 px-4 py-2 rounded-xl flex items-center gap-2">
            <X className="w-4 h-4 text-red-500" />
            <span className="text-red-500 font-bold">{profile?.learningCount || 0}</span>
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
                onClick={(e) => { e.stopPropagation(); toggleBookmark(currentCard.term); }}
                className="absolute top-10 right-10 p-3 hover:bg-white/5 rounded-full transition-colors"
              >
                <Bookmark className={`w-6 h-6 ${isBookmarked ? 'text-primary fill-primary' : 'text-cream/20'}`} />
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
                  <button 
                    onClick={(e) => { e.stopPropagation(); handleSpeak(currentCard.term); }}
                    disabled={isSpeaking}
                    className="w-12 h-12 bg-primary/10 text-primary rounded-xl flex items-center justify-center hover:bg-primary hover:text-forest transition-all disabled:opacity-50"
                  >
                    {isSpeaking ? <Loader2 className="w-6 h-6 animate-spin" /> : <Volume2 className="w-6 h-6" />}
                  </button>
                  <button 
                    onClick={(e) => e.stopPropagation()}
                    className="w-12 h-12 bg-white/5 text-cream/40 rounded-xl flex items-center justify-center hover:bg-white/10 transition-all"
                  >
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
          onClick={() => {
            setDirection(1);
            setIsFlipped(false);
            setTimeout(() => {
              setCurrentIndex((prev) => (prev + 1) % cards.length);
            }, 200);
          }}
          className="w-16 h-16 bg-white/5 border border-white/10 rounded-full flex items-center justify-center text-cream/40 hover:text-primary transition-all hover:scale-110"
        >
          <ChevronRight className="w-8 h-8" />
        </button>
      </div>
    </motion.div>
  );
};

export default Flashcards;

import React, { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Search, Mic, Settings, Sparkles, ChevronDown, MapPin, Play, Share2, Bookmark, Volume2, X, Type as TypeIcon, Globe } from 'lucide-react';
import { GoogleGenAI, Modality } from "@google/genai";
import { toast } from 'sonner';
import { collection, query, where, onSnapshot } from 'firebase/firestore';
import { db, handleFirestoreError, OperationType } from '../../firebase';
import { DICTIONARY_WORDS } from '../../constants/dictionaryData';
import { useFirebase } from '../../Contexts/FirebaseContext';

const Dictionary: React.FC = () => {
  const { profile, updateProfile } = useFirebase();
  const [searchQuery, setSearchQuery] = useState('');
  const [activeCategory, setActiveCategory] = useState('All');
  const [expandedWord, setExpandedWord] = useState<string | null>(null);
  const [isListening, setIsListening] = useState(false);
  const [showSettings, setShowSettings] = useState(false);
  const [fontSize, setFontSize] = useState<'sm' | 'md' | 'lg'>('md');
  const [dialect, setDialect] = useState<'mansaka' | 'mandaya'>('mansaka');
  const [isPlaying, setIsPlaying] = useState<string | null>(null);
  const [firestoreWords, setFirestoreWords] = useState<any[]>([]);

  const recognitionRef = useRef<any>(null);

  useEffect(() => {
    const q = query(collection(db, 'words'), where('status', '==', 'validated'));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      setFirestoreWords(snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })));
    }, (err) => handleFirestoreError(err, OperationType.LIST, 'words'));
    return () => unsubscribe();
  }, []);

  useEffect(() => {
    const SpeechRecognition = (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition;
    if (SpeechRecognition) {
      recognitionRef.current = new SpeechRecognition();
      recognitionRef.current.continuous = false;
      recognitionRef.current.interimResults = false;
      recognitionRef.current.lang = 'en-US'; // Default to English for recognition, or 'fil-PH' if supported

      recognitionRef.current.onresult = (event: any) => {
        const transcript = event.results[0][0].transcript;
        setSearchQuery(transcript);
        setIsListening(false);
      };

      recognitionRef.current.onerror = () => {
        setIsListening(false);
      };

      recognitionRef.current.onend = () => {
        setIsListening(false);
      };
    }
  }, []);

  const toggleVoiceSearch = () => {
    if (isListening) {
      recognitionRef.current?.stop();
    } else {
      setIsListening(true);
      recognitionRef.current?.start();
    }
  };

  const playTTS = async (text: string, id: string) => {
    try {
      setIsPlaying(id);
      const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });
      const response = await ai.models.generateContent({
        model: "gemini-2.5-flash-preview-tts",
        contents: [{ parts: [{ text: `Say clearly in a natural voice: ${text}` }] }],
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
        source.onended = () => setIsPlaying(null);
        source.start();
      } else {
        setIsPlaying(null);
      }
    } catch (error) {
      console.error("TTS Error:", error);
      toast.error("Failed to play audio. Please try again later.");
      setIsPlaying(null);
    }
  };

  const shareWord = async (word: any) => {
    const shareData = {
      title: `Mansaka Dictionary: ${word.term}`,
      text: `${word.term} (${word.pos}) - ${word.english}. ${word.definition}`,
      url: window.location.href,
    };

    if (navigator.share) {
      try {
        await navigator.share(shareData);
        toast.success("Shared successfully!");
      } catch (err) {
        console.error("Share error:", err);
      }
    } else {
      navigator.clipboard.writeText(`${shareData.title}\n${shareData.text}\n${shareData.url}`);
      toast.success("Copied to clipboard!");
    }
  };

  const words = [...DICTIONARY_WORDS, ...firestoreWords.map(w => ({
    term: w.term || '',
    pos: w.pos || 'noun',
    tag: w.tag || 'General',
    category: w.category || 'General',
    filipino: w.filipino || '',
    english: w.english || '',
    definition: w.definition || '',
    example: w.example || '',
    exampleTranslation: w.exampleTranslation || '',
    location: w.location || 'Unknown',
    validatedBy: 'Community Validator',
    related: w.related || []
  }))];

  const filteredWords = words.filter(word => {
    const matchesSearch = word.term.toLowerCase().includes(searchQuery.toLowerCase()) || 
                         word.english.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         word.filipino.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = activeCategory === 'All' || word.tag === activeCategory;
    return matchesSearch && matchesCategory;
  });

  const toggleBookmark = async (term: string) => {
    if (!profile) return;
    const currentBookmarks = profile.bookmarks || [];
    const isBookmarked = currentBookmarks.includes(term);
    
    let newBookmarks;
    if (isBookmarked) {
      newBookmarks = currentBookmarks.filter(b => b !== term);
      toast.info(`Removed ${term} from saved words.`);
    } else {
      newBookmarks = [...currentBookmarks, term];
      toast.success(`Saved ${term} to your words.`);
    }
    
    await updateProfile({ bookmarks: newBookmarks });
  };

  const highlightText = (text: string, highlight: string) => {
    if (!highlight.trim()) {
      return <span>{text}</span>;
    }
    const regex = new RegExp(`(${highlight})`, 'gi');
    const parts = text.split(regex);
    return (
      <span>
        {parts.map((part, i) => 
          regex.test(part) ? <span key={i} className="bg-primary/30 text-primary px-1 rounded">{part}</span> : <span key={i}>{part}</span>
        )}
      </span>
    );
  };

  return (
    <motion.div 
      initial={{ opacity: 0, x: 20 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -20 }}
      className="space-y-8 pb-32"
    >
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-3xl font-bold text-primary leading-tight">The Canopy</h2>
        <div className="flex items-center gap-4 relative">
          <button 
            onClick={() => setShowSettings(!showSettings)}
            className={`p-2 rounded-full transition-colors ${showSettings ? 'bg-primary text-forest' : 'bg-white/5 text-cream/40 hover:text-primary'}`}
          >
            <Settings className="w-5 h-5" />
          </button>
          
          <AnimatePresence>
            {showSettings && (
              <motion.div 
                initial={{ opacity: 0, y: 10, scale: 0.95 }}
                animate={{ opacity: 1, y: 0, scale: 1 }}
                exit={{ opacity: 0, y: 10, scale: 0.95 }}
                className="absolute top-full right-0 mt-4 w-64 bg-surface-high border border-white/10 rounded-3xl p-6 z-50 shadow-2xl"
              >
                <div className="flex items-center justify-between mb-6">
                  <h4 className="font-bold text-cream">Settings</h4>
                  <button onClick={() => setShowSettings(false)} className="text-cream/40 hover:text-cream">
                    <X className="w-4 h-4" />
                  </button>
                </div>

                <div className="space-y-6">
                  <div className="space-y-3">
                    <div className="flex items-center gap-2 text-[10px] font-black text-primary uppercase tracking-widest">
                      <Globe className="w-3 h-3" />
                      <span>Primary Dialect</span>
                    </div>
                    <div className="grid grid-cols-2 gap-2">
                      {(['mansaka', 'mandaya'] as const).map(d => (
                        <button 
                          key={d}
                          onClick={() => setDialect(d)}
                          className={`py-2 rounded-xl text-[10px] font-bold uppercase tracking-widest border transition-all ${
                            dialect === d ? 'bg-primary border-primary text-forest' : 'bg-white/5 border-white/10 text-cream/40'
                          }`}
                        >
                          {d}
                        </button>
                      ))}
                    </div>
                  </div>

                  <div className="space-y-3">
                    <div className="flex items-center gap-2 text-[10px] font-black text-primary uppercase tracking-widest">
                      <TypeIcon className="w-3 h-3" />
                      <span>Font Size</span>
                    </div>
                    <div className="grid grid-cols-3 gap-2">
                      {(['sm', 'md', 'lg'] as const).map(s => (
                        <button 
                          key={s}
                          onClick={() => setFontSize(s)}
                          className={`py-2 rounded-xl text-[10px] font-bold uppercase tracking-widest border transition-all ${
                            fontSize === s ? 'bg-primary border-primary text-forest' : 'bg-white/5 border-white/10 text-cream/40'
                          }`}
                        >
                          {s}
                        </button>
                      ))}
                    </div>
                  </div>
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          <div className="bg-terracotta text-white px-3 py-1 rounded-full text-xs font-black uppercase tracking-widest">V1.0</div>
        </div>
      </div>

      {/* Word of the Day Card */}
      <div className="bg-gradient-to-br from-terracotta to-[#8B310A] rounded-[2.5rem] p-10 relative overflow-hidden terracotta-shadow mb-8 group">
        <div className="absolute top-0 right-0 w-64 h-64 bg-white/10 rounded-full -mr-32 -mt-32 blur-3xl group-hover:scale-110 transition-transform duration-1000"></div>
        <div className="absolute bottom-0 left-0 w-48 h-48 bg-primary/10 rounded-full -ml-24 -mb-24 blur-2xl"></div>
        
        <div className="relative z-10">
          <div className="flex items-center gap-3 mb-8">
            <div className="w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-md">
              <Sparkles className="w-5 h-5 text-white" />
            </div>
            <span className="text-[10px] font-black uppercase tracking-[0.4em] text-white/80">Word of the Day</span>
          </div>
          
          <div className="flex flex-col md:flex-row md:items-end justify-between gap-8">
            <div>
              <h3 className="text-6xl font-headline font-bold text-white mb-3 tracking-tight">Kalumanan</h3>
              <p className="text-white/60 font-mono text-sm tracking-[0.2em] mb-6">/ka.lu.ma.nan/</p>
              <div className="flex flex-wrap gap-3">
                <div className="bg-white/10 backdrop-blur-md px-5 py-2 rounded-xl border border-white/10">
                  <span className="text-[10px] font-bold text-white/90 uppercase tracking-widest">Heritage</span>
                </div>
                <div className="bg-primary/20 backdrop-blur-md px-5 py-2 rounded-xl border border-primary/20">
                  <span className="text-[10px] font-bold text-primary uppercase tracking-widest">Mansaka</span>
                </div>
              </div>
            </div>
            
            <button 
              onClick={() => setExpandedWord('Kalumanan')}
              className="bg-white text-terracotta px-10 py-4 rounded-2xl font-black text-sm uppercase tracking-widest hover:bg-primary hover:text-forest transition-all gold-shadow active:translate-y-1"
            >
              Learn More
            </button>
          </div>
        </div>
      </div>

      <div className="relative group">
        <div className="absolute inset-y-0 left-5 flex items-center pointer-events-none">
          <Search className="w-6 h-6 text-cream/40 group-focus-within:text-primary transition-colors" />
        </div>
        <input 
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="w-full bg-surface-low border-2 border-transparent rounded-[2rem] py-5 pl-14 pr-14 text-cream placeholder:text-cream/40 focus:ring-0 focus:border-primary/30 pressed-shadow transition-all font-medium text-lg" 
          placeholder="Search words or phrases..." 
          type="text"
        />
        <div className="absolute inset-y-0 right-5 flex items-center">
          <button 
            onClick={toggleVoiceSearch}
            className={`p-2 rounded-full transition-all ${isListening ? 'bg-red-500 text-white animate-pulse' : 'hover:bg-white/5 text-cream/40'}`}
          >
            <Mic className="w-6 h-6" />
          </button>
        </div>
      </div>

      <div className="flex gap-4 overflow-x-auto pb-4 no-scrollbar -mx-2 px-2">
        {['All', 'Mansaka', 'Mandaya', 'Kagan', 'Blaan', 'Tboli'].map(cat => (
          <button 
            key={cat}
            onClick={() => setActiveCategory(cat)}
            className={`flex-shrink-0 px-8 py-3 rounded-2xl font-black text-xs uppercase tracking-widest transition-all ${
              activeCategory === cat 
                ? 'bg-primary text-forest gold-shadow -translate-y-1' 
                : 'bg-surface-high text-cream/40 hover:text-cream/60'
            }`}
          >
            {cat}
          </button>
        ))}
      </div>

      <div className="space-y-6">
        {filteredWords.length > 0 ? (
          filteredWords.map((word, idx) => {
            const isExpanded = expandedWord === word.term;
            return (
              <div 
                key={idx} 
                className={`bg-surface-low border transition-all duration-500 overflow-hidden ${
                  isExpanded ? 'rounded-[2.5rem] border-primary/30 shadow-2xl' : 'rounded-[1.5rem] border-white/5 hover:bg-surface-low/80'
                }`}
              >
                {/* Header / Collapsed State */}
                <div 
                  onClick={() => setExpandedWord(isExpanded ? null : word.term)}
                  className="p-8 cursor-pointer relative group"
                >
                  <div className="flex justify-between items-center relative z-10">
                    <div className="space-y-4">
                      <div className="flex items-center gap-4">
                        <h3 className="text-4xl font-headline font-bold text-cream tracking-tight">{highlightText(word.term, searchQuery)}</h3>
                        <div className="flex gap-2">
                          <span className="bg-primary/10 border border-primary/20 text-primary text-[9px] font-black px-2.5 py-0.5 rounded uppercase tracking-widest">{word.pos}</span>
                          <span className="bg-terracotta/10 border border-terracotta/20 text-terracotta text-[9px] font-black px-2.5 py-0.5 rounded uppercase tracking-widest">{word.tag}</span>
                          <span className="bg-white/5 border border-white/10 text-cream/40 text-[9px] font-black px-2.5 py-0.5 rounded uppercase tracking-widest">{word.category}</span>
                        </div>
                      </div>
                      <div className="flex items-center gap-6 text-sm font-bold">
                        <div className="flex items-center gap-2">
                          <span className="text-[9px] font-black text-cream/20 uppercase tracking-widest">FIL</span>
                          <span className="text-cream/80">{highlightText(word.filipino, searchQuery)}</span>
                        </div>
                        <div className="w-1 h-1 bg-primary/20 rounded-full"></div>
                        <div className="flex items-center gap-2">
                          <span className="text-[9px] font-black text-cream/20 uppercase tracking-widest">ENG</span>
                          <span className="text-cream/80">{highlightText(word.english, searchQuery)}</span>
                        </div>
                      </div>
                    </div>

                    <div className="flex items-center gap-4">
                      <button 
                        onClick={(e) => {
                          e.stopPropagation();
                          playTTS(word.term, `${word.term}-main`);
                        }}
                        className={`w-12 h-12 border rounded-xl flex items-center justify-center transition-all group/play ${
                          isPlaying === `${word.term}-main` ? 'bg-primary border-primary' : 'bg-white/5 border-white/10 hover:bg-primary hover:text-forest'
                        }`}
                      >
                        {isPlaying === `${word.term}-main` ? (
                          <div className="flex gap-1 items-end h-4">
                            <div className="w-1 bg-forest animate-bounce" style={{ animationDelay: '0s' }}></div>
                            <div className="w-1 bg-forest animate-bounce" style={{ animationDelay: '0.1s' }}></div>
                            <div className="w-1 bg-forest animate-bounce" style={{ animationDelay: '0.2s' }}></div>
                          </div>
                        ) : (
                          <Volume2 className="w-5 h-5 text-primary group-hover/play:text-forest" />
                        )}
                      </button>
                      <ChevronDown className={`w-5 h-5 text-cream/20 transition-transform duration-500 ${isExpanded ? 'rotate-180 text-primary' : ''}`} />
                    </div>
                  </div>
                </div>

                {/* Expanded Content */}
                <AnimatePresence>
                  {isExpanded && (
                    <motion.div
                      initial={{ height: 0, opacity: 0 }}
                      animate={{ height: 'auto', opacity: 1 }}
                      exit={{ height: 0, opacity: 0 }}
                      transition={{ duration: 0.5, ease: [0.04, 0.62, 0.23, 0.98] }}
                    >
                      <div className="px-8 pb-10 pt-4 border-t border-white/5 space-y-10">
                        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
                          {/* Left Column: Definition */}
                          <div className="space-y-8">
                            <section>
                              <h4 className="text-[10px] font-black text-primary uppercase tracking-[0.3em] mb-4">DEFINITION</h4>
                              <p className="text-xl text-cream/70 leading-relaxed font-body">
                                {word.definition}
                              </p>
                              <div className="mt-6 space-y-3">
                                <div className="bg-green-500/5 border border-green-500/10 px-4 py-2 rounded-xl inline-flex items-center gap-3">
                                  <div className="w-1.5 h-1.5 bg-green-500 rounded-full animate-pulse"></div>
                                  <span className="text-[9px] font-black text-green-500 uppercase tracking-widest">VALIDATED · {word.validatedBy}</span>
                                </div>
                                <div className="flex items-center gap-2 text-cream/30 px-1">
                                  <MapPin className="w-3.5 h-3.5" />
                                  <span className="text-[9px] font-black uppercase tracking-widest">{word.location}</span>
                                </div>
                              </div>
                            </section>

                            <section>
                              <h4 className="text-[10px] font-black text-primary uppercase tracking-[0.3em] mb-4">RELATED WORDS</h4>
                              <div className="flex flex-wrap gap-2">
                                {word.related.map((rel: string) => (
                                  <button 
                                    key={rel} 
                                    onClick={() => {
                                      setSearchQuery(rel);
                                      setExpandedWord(null);
                                    }}
                                    className="bg-white/5 border border-white/10 px-4 py-2 rounded-lg text-xs font-bold text-cream/60 hover:border-primary/40 hover:text-primary transition-all"
                                  >
                                    {rel}
                                  </button>
                                ))}
                              </div>
                            </section>
                          </div>

                          {/* Right Column: Usage & Audio */}
                          <div className="space-y-8">
                            <section>
                              <h4 className="text-[10px] font-black text-primary uppercase tracking-[0.3em] mb-4">USAGE EXAMPLE</h4>
                              <div className="bg-white/5 border-l-2 border-primary/40 p-6 rounded-r-2xl space-y-4">
                                <div className="text-2xl font-headline font-bold text-primary leading-tight">
                                  {word.example}
                                </div>
                                <div className="text-lg text-cream/50 italic">
                                  {word.exampleTranslation}
                                </div>
                              </div>
                            </section>

                            <section>
                              <div className="bg-white/5 border border-white/10 rounded-2xl p-6 flex items-center gap-6">
                                <button 
                                  onClick={() => playTTS(word.example, `${word.term}-example`)}
                                  className={`w-10 h-10 rounded-full flex items-center justify-center transition-all ${
                                    isPlaying === `${word.term}-example` ? 'bg-primary text-forest' : 'bg-primary/10 text-primary hover:bg-primary hover:text-forest'
                                  }`}
                                >
                                  {isPlaying === `${word.term}-example` ? (
                                    <div className="flex gap-0.5 items-end h-3">
                                      <div className="w-0.5 bg-forest animate-bounce" style={{ animationDelay: '0s' }}></div>
                                      <div className="w-0.5 bg-forest animate-bounce" style={{ animationDelay: '0.1s' }}></div>
                                      <div className="w-0.5 bg-forest animate-bounce" style={{ animationDelay: '0.2s' }}></div>
                                    </div>
                                  ) : (
                                    <Volume2 className="w-5 h-5" />
                                  )}
                                </button>
                                <div className="flex-1 space-y-3">
                                  <div className="flex items-center gap-1 h-6">
                                    {[...Array(20)].map((_, i) => (
                                      <div 
                                        key={i} 
                                        className={`flex-1 rounded-full transition-all duration-300 ${isPlaying === `${word.term}-example` ? 'bg-primary animate-pulse' : 'bg-primary/20'}`}
                                        style={{ 
                                          height: `${20 + Math.random() * 80}%`,
                                          animationDelay: `${i * 0.05}s`
                                        }}
                                      ></div>
                                    ))}
                                  </div>
                                  <div className="flex justify-between text-[9px] font-mono text-cream/30 uppercase tracking-widest">
                                    <span>{isPlaying === `${word.term}-example` ? 'Playing...' : '0:00'}</span>
                                    <span>0:03</span>
                                  </div>
                                </div>
                              </div>
                            </section>

                            <div className="flex gap-3">
                              <button 
                                onClick={() => shareWord(word)}
                                className="flex-1 bg-white/5 border border-white/10 py-3.5 rounded-xl font-black text-cream/40 uppercase tracking-widest text-[10px] hover:bg-white/10 transition-all flex items-center justify-center gap-2"
                              >
                                <Share2 className="w-3.5 h-3.5" />
                                Share
                              </button>
                              <button 
                                onClick={() => toggleBookmark(word.term)}
                                className={`flex-1 border py-3.5 rounded-xl font-black uppercase tracking-widest text-[10px] transition-all flex items-center justify-center gap-2 ${
                                  profile?.bookmarks?.includes(word.term) ? 'bg-primary/10 border-primary text-primary' : 'bg-white/5 border-white/10 text-cream/40 hover:bg-white/10'
                                }`}
                              >
                                <Bookmark className={`w-3.5 h-3.5 ${profile?.bookmarks?.includes(word.term) ? 'fill-current' : ''}`} />
                                {profile?.bookmarks?.includes(word.term) ? 'Saved' : 'Save'}
                              </button>
                            </div>
                          </div>
                        </div>
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </div>
            );
          })
        ) : (
          <div className="text-center py-20 space-y-4">
            <div className="text-6xl">🔍</div>
            <div className="text-cream/40 font-bold">No words found in the canopy...</div>
          </div>
        )}
      </div>
    </motion.div>
  );
};

export default Dictionary;

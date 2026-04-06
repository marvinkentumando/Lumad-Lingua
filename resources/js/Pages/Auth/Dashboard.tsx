import React, { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useFirebase } from '../../Contexts/FirebaseContext';
import { toast } from 'sonner';
import { collection, query, orderBy, limit, onSnapshot } from 'firebase/firestore';
import { db } from '../../firebase';
import { GoogleGenAI, Modality } from "@google/genai";
import { DICTIONARY_WORDS } from '../../constants/dictionaryData';
import { 
  Trophy, 
  Map as MapIcon, 
  Flame, 
  BookOpen, 
  CheckCircle2, 
  Hash, 
  ChevronLeft, 
  ChevronRight, 
  Play, 
  Pause,
  Volume2, 
  BarChart3,
  RefreshCw,
  Sparkles
} from 'lucide-react';

interface DashboardProps {
  onContinueAscent?: () => void;
}

const Dashboard: React.FC<DashboardProps> = ({ onContinueAscent }) => {
  const { profile, user } = useFirebase();
  const [playingVoice, setPlayingVoice] = useState<number | null>(null);
  const [isSpeaking, setIsSpeaking] = useState(false);
  const [topUsers, setTopUsers] = useState<any[]>([]);
  const audioRef = useRef<HTMLAudioElement | null>(null);

  // Deterministic Word of the Day
  const today = new Date();
  const dayOfYear = Math.floor((today.getTime() - new Date(today.getFullYear(), 0, 0).getTime()) / 86400000);
  const wordOfDay = DICTIONARY_WORDS[dayOfYear % DICTIONARY_WORDS.length];

  // Cultural Insights
  const CULTURAL_INSIGHTS = [
    { title: 'Sacred Weaving', text: 'The "Dagmay" cloth is not just fabric; it is a spiritual map of the weaver\'s dreams and ancestral connections.', icon: '🌿' },
    { title: 'Silver Artistry', text: 'Mansaka silverwork often features the "Panubad-tubad" pattern, representing the flow of life and nature.', icon: '✨' },
    { title: 'Oral Traditions', text: 'The "Bayok" is a traditional chant used to pass down history, laws, and spiritual wisdom across generations.', icon: '🗣️' },
  ];
  const insight = CULTURAL_INSIGHTS[dayOfYear % CULTURAL_INSIGHTS.length];

  useEffect(() => {
    const q = query(collection(db, 'users'), orderBy('xp', 'desc'), limit(5));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const users = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      setTopUsers(users);
    });

    return () => unsubscribe();
  }, []);

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

  const voices = [
    { name: 'Lolo Kiko', role: 'Community Elder', text: 'Maayong buntag', trans: 'Good morning', audio: 'data:audio/wav;base64,UklGRigAAABXQVZFZm10IBIAAAABAAEARKwAAIhYAQACABAAAABkYXRhAgAAAAEA' },
    { name: 'Teacher Aya', role: 'Language Expert', text: 'Salamat', trans: 'Thank you', audio: 'data:audio/wav;base64,UklGRigAAABXQVZFZm10IBIAAAABAAEARKwAAIhYAQACABAAAABkYXRhAgAAAAEA' },
  ];

  const handleAction = (action: string) => {
    toast.info(`${action} feature coming soon!`);
  };

  const toggleVoice = async (index: number) => {
    try {
      if (playingVoice === index) {
        if (audioRef.current) {
          audioRef.current.pause();
        }
        setPlayingVoice(null);
      } else {
        // Stop any current playback
        if (audioRef.current) {
          audioRef.current.pause();
        }
        
        // Update source and play
        const audio = new Audio(voices[index].audio);
        audioRef.current = audio;
        
        audio.onended = () => setPlayingVoice(null);
        
        setPlayingVoice(index);
        
        const playPromise = audio.play();
        if (playPromise !== undefined) {
          await playPromise;
        }
      }
    } catch (error) {
      // Handle interruption or load errors gracefully
      if (error instanceof Error && error.name !== 'AbortError') {
        console.error("Audio playback error:", error);
      }
      // If it was an actual error (not just an interruption), reset state
      if (error instanceof Error && error.name !== 'AbortError') {
        setPlayingVoice(null);
      }
    }
  };

  return (
    <motion.div 
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      className="space-y-6 md:space-y-8 pb-32"
    >
      {/* Hero Section */}
      <section className="relative overflow-hidden bg-surface-low rounded-[2rem] md:rounded-[2.5rem] p-6 md:p-12 border border-white/5 shadow-2xl group">
        <div className="absolute top-0 right-0 w-1/2 h-full opacity-10 pointer-events-none">
          <img 
            src="https://picsum.photos/seed/mountain/800/600" 
            alt="Mountain Background" 
            className="w-full h-full object-cover rounded-r-[2.5rem]"
            referrerPolicy="no-referrer"
          />
        </div>
        <div className="relative z-10 flex flex-col lg:flex-row lg:items-center justify-between gap-8 md:gap-12">
          <div className="max-w-2xl space-y-6">
            <div className="inline-flex items-center bg-primary text-forest px-4 py-1.5 rounded-full text-[10px] font-black uppercase tracking-widest gold-shadow">
              Level {profile?.level || 1}: {profile?.displayName || 'Learner'}
            </div>
            <h2 className="text-4xl sm:text-5xl md:text-7xl font-headline font-bold text-cream leading-tight tracking-tight">
              Mountain <br /> Journey
            </h2>
            <p className="text-cream/60 text-base md:text-xl leading-relaxed">
              You are steadily climbing the ancestral peaks. Every lesson brings you closer to the wisdom of the elders.
            </p>
            
            <div className="space-y-4 pt-4">
              <div className="flex justify-between text-[10px] font-black uppercase tracking-widest text-cream/40">
                <span>{profile?.completedLessons?.length || 0} / 83 Lessons Mastered</span>
                <span>{Math.round(((profile?.completedLessons?.length || 0) / 83) * 100)}% Completion</span>
              </div>
              <div className="h-3 bg-white/5 rounded-full overflow-hidden border border-white/5">
                <motion.div 
                  initial={{ width: 0 }}
                  animate={{ width: `${Math.min(100, ((profile?.completedLessons?.length || 0) / 83) * 100)}%` }}
                  className="h-full bg-primary rounded-full gold-shadow"
                />
              </div>
            </div>

            <button 
              onClick={onContinueAscent}
              className="bg-primary text-forest px-10 py-5 rounded-2xl font-black text-sm uppercase tracking-widest gold-shadow hover:-translate-y-1 transition-all active:translate-y-0 min-h-[44px]"
            >
              Continue Ascent
            </button>
          </div>

          {/* Cultural Insight Card (Replacement for Mission Card) */}
          <div className="bg-white/5 border border-white/10 rounded-[2.5rem] p-8 md:p-10 w-full lg:max-w-[400px] relative overflow-hidden shadow-2xl group/card">
            <div className="absolute top-0 left-0 right-0 h-1.5 bg-gradient-to-r from-primary to-orange-500"></div>
            <div className="flex items-center justify-between mb-8">
              <h4 className="font-bold text-cream">Cultural Insight</h4>
              <Sparkles className="w-5 h-5 text-primary group-hover/card:rotate-12 transition-transform" />
            </div>
            <div className="space-y-6">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 bg-primary/10 rounded-2xl flex items-center justify-center text-2xl">
                  {insight.icon}
                </div>
                <div>
                  <div className="text-sm font-bold text-cream">{insight.title}</div>
                  <div className="text-[10px] text-cream/40 uppercase font-black tracking-widest mt-0.5">Wisdom of the Elders</div>
                </div>
              </div>
              <p className="text-sm text-cream/60 leading-relaxed italic">
                "{insight.text}"
              </p>
              <button 
                onClick={() => handleAction('Explore Heritage')}
                className="w-full bg-white/5 border border-white/10 text-cream py-4 rounded-xl font-black uppercase tracking-widest text-[10px] hover:bg-white/10 transition-all min-h-[44px]"
              >
                Explore Heritage
              </button>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 md:gap-6">
        {[
          { label: 'Total XP', val: (profile?.xp || 0).toLocaleString(), icon: Trophy, color: 'text-primary', bg: 'bg-primary/5' },
          { label: 'Levels Done', val: `${profile?.level || 1} / 10`, icon: MapIcon, color: 'text-green-500', bg: 'bg-green-500/5' },
          { label: 'Day Streak', val: (profile?.streak || 0).toString(), icon: Flame, color: 'text-orange-500', bg: 'bg-orange-500/5' },
          { label: 'Words Learned', val: ((profile?.completedLessons?.length || 0) * 5).toString(), icon: BookOpen, color: 'text-blue-400', bg: 'bg-blue-400/5' },
        ].map((stat, i) => (
          <div key={i} className="bg-surface-low border border-white/5 rounded-2xl md:rounded-[2rem] p-4 md:p-6 flex flex-col sm:flex-row items-center sm:items-center gap-3 md:gap-4 hover:bg-white/5 transition-all min-h-[44px] text-center sm:text-left">
            <div className={`w-10 h-10 md:w-12 md:h-12 ${stat.bg} rounded-xl md:rounded-2xl flex items-center justify-center ${stat.color} shrink-0`}>
              <stat.icon className="w-5 h-5 md:w-6 md:h-6" />
            </div>
            <div className="min-w-0 w-full">
              <div className="text-[8px] md:text-[9px] font-black uppercase tracking-widest text-cream/20 mb-0.5 md:mb-1 truncate">{stat.label}</div>
              <div className="text-base md:text-xl font-black text-cream truncate">{stat.val}</div>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        {/* Right Column (Moved to top on mobile): Word of Day & Leaderboard & Weaving */}
        <div className="lg:col-span-4 space-y-8 order-1 lg:order-2">
          <div className="bg-gradient-to-br from-terracotta to-[#8B310A] rounded-[2.5rem] p-6 md:p-8 terracotta-shadow relative overflow-hidden group">
            <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-16 -mt-16 blur-2xl"></div>
            <div className="relative z-10 space-y-6">
              <div className="flex justify-between items-center">
                <div className="text-[10px] font-black uppercase tracking-widest text-white/60">Word of the Day</div>
                <div className="bg-white/20 text-white px-2 py-0.5 rounded text-[8px] font-black uppercase tracking-widest backdrop-blur-sm">
                  {(wordOfDay as any).dialect || 'Lumad'}
                </div>
              </div>
              <h4 className="text-3xl md:text-4xl font-headline font-bold text-white tracking-tight">{wordOfDay.term}</h4>
              <p className="text-white/60 font-mono text-[10px] md:text-xs tracking-widest">[{wordOfDay.pos}]</p>
              
              <div className="flex items-center gap-4">
                <button 
                  onClick={() => handleSpeak(wordOfDay.term)} 
                  disabled={isSpeaking}
                  className="w-10 h-10 bg-white/20 rounded-full flex items-center justify-center text-white backdrop-blur-md min-h-[44px] min-w-[44px] disabled:opacity-50"
                >
                  {isSpeaking ? <RefreshCw className="w-5 h-5 animate-spin" /> : <Volume2 className="w-5 h-5" />}
                </button>
                <div>
                  <div className="text-base md:text-lg font-bold text-white">{wordOfDay.english}</div>
                  <div className="text-[9px] md:text-[10px] text-white/40 uppercase font-black tracking-widest">{wordOfDay.pos}</div>
                </div>
              </div>
              
              <p className="text-white/70 text-xs md:text-sm leading-relaxed italic">
                "{wordOfDay.example || `The ${wordOfDay.term} is part of our heritage.`}"
              </p>
            </div>
          </div>

          <div className="bg-surface-low border border-white/5 rounded-[2.5rem] p-8 space-y-6">
            <div className="flex items-center justify-between">
              <h4 className="text-xl font-bold text-cream">Top Climbers</h4>
              <BarChart3 className="w-5 h-5 text-cream/20" />
            </div>
            <div className="space-y-4">
              {topUsers.map((u, i) => (
                <div key={u.id} className={`flex items-center gap-4 p-4 rounded-2xl transition-all ${u.id === user?.uid ? 'bg-primary/10 border border-primary/20' : 'hover:bg-white/5'}`}>
                  <div className="w-6 font-mono text-xs text-cream/20">{i + 1}</div>
                  <img src={`https://api.dicebear.com/7.x/avataaars/svg?seed=${u.displayName || u.email}`} className="w-10 h-10 rounded-xl bg-forest" alt="User" referrerPolicy="no-referrer" />
                  <div className="flex-1">
                    <div className="text-sm font-bold text-cream truncate max-w-[120px]">{u.id === user?.uid ? `You (${u.displayName || 'Learner'})` : (u.displayName || 'Learner')}</div>
                    <div className="text-[9px] text-cream/40 uppercase font-black tracking-widest">Level {u.level || 1}</div>
                  </div>
                  <div className="text-sm font-black text-primary">{((u.xp || 0) / 1000).toFixed(1)}k XP</div>
                </div>
              ))}
              {topUsers.length === 0 && (
                <div className="text-center py-4 text-cream/20 text-xs italic">No climbers yet...</div>
              )}
            </div>
          </div>

          {/* Collaborative Weaving (Multiplayer) */}
          <div className="bg-white/5 border border-white/10 rounded-[2.5rem] p-8 space-y-6">
            <div className="flex items-center justify-between">
              <h4 className="text-xl font-bold text-cream">Collaborative Weaving</h4>
              <div className="flex -space-x-3">
                {[1, 2, 3, 4].map(i => (
                  <img 
                    key={i} 
                    src={`https://api.dicebear.com/7.x/avataaars/svg?seed=user${i}`} 
                    className="w-8 h-8 rounded-full border-2 border-forest bg-white/10" 
                    alt="Active User"
                    referrerPolicy="no-referrer"
                  />
                ))}
                <div className="w-8 h-8 rounded-full border-2 border-forest bg-primary/20 flex items-center justify-center text-[10px] font-bold text-primary">+12</div>
              </div>
            </div>
            <div className="space-y-4">
              <div className="p-4 bg-primary/5 rounded-2xl border border-primary/10">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-[10px] font-black uppercase tracking-widest text-primary">Active Challenge</span>
                  <span className="text-[10px] font-mono text-cream/40">Ends in 2h 45m</span>
                </div>
                <div className="text-sm font-bold text-cream mb-3">Group Weave: 5,000 XP Goal</div>
                <div className="h-2 bg-white/5 rounded-full overflow-hidden mb-2">
                  <motion.div 
                    initial={{ width: 0 }}
                    animate={{ width: '65%' }}
                    className="h-full bg-primary rounded-full gold-shadow"
                  />
                </div>
                <div className="flex justify-between text-[9px] font-black uppercase tracking-widest text-cream/20">
                  <span>3,250 / 5,000 XP</span>
                  <span className="text-primary">65%</span>
                </div>
              </div>
              <button onClick={() => handleAction('Join Community Loom')} className="w-full py-3 bg-white/5 border border-white/10 rounded-xl text-[10px] font-black uppercase tracking-widest text-cream/40 hover:text-primary hover:bg-primary/10 transition-all">
                Join Community Loom
              </button>
            </div>
          </div>
        </div>

        {/* Left Column (Moved to bottom on mobile): Levels & Voices */}
        <div className="lg:col-span-8 space-y-12 order-2 lg:order-1">
          <section className="space-y-6">
            <div className="flex items-center justify-between">
              <h3 className="text-2xl font-bold text-cream">Your Levels</h3>
              <button onClick={() => handleAction('View All Levels')} className="text-primary text-xs font-black uppercase tracking-widest hover:underline min-h-[44px]">View All Levels</button>
            </div>
            <div className="space-y-4">
              <div className="bg-surface-low border border-white/5 rounded-[2rem] p-6 flex items-center gap-6 group hover:bg-white/5 transition-all">
                <div className="w-14 h-14 bg-green-500/10 rounded-2xl flex items-center justify-center text-green-500 border border-green-500/20">
                  <CheckCircle2 className="w-7 h-7" />
                </div>
                <div className="flex-1">
                  <div className="flex items-center justify-between mb-1">
                    <h4 className="text-xl font-bold text-cream">Greetings</h4>
                    <span className="bg-green-500/20 text-green-500 text-[9px] font-black px-2 py-1 rounded uppercase tracking-widest">Completed</span>
                  </div>
                  <p className="text-sm text-cream/40">Basic phrases for meeting and welcoming others.</p>
                </div>
              </div>

              <div className="bg-surface-low border border-white/5 rounded-[2rem] p-6 flex items-center gap-6 group hover:bg-white/5 transition-all">
                <div className="w-14 h-14 bg-primary/10 rounded-2xl flex items-center justify-center text-primary border border-primary/20">
                  <Hash className="w-7 h-7" />
                </div>
                <div className="flex-1">
                  <div className="flex items-center justify-between mb-1">
                    <h4 className="text-xl font-bold text-cream">Numbers</h4>
                    <button onClick={() => handleAction('Continue Numbers Level')} className="bg-primary text-forest px-6 py-2 rounded-xl text-[10px] font-black uppercase tracking-widest gold-shadow min-h-[44px]">Continue</button>
                  </div>
                  <p className="text-sm text-cream/40 mb-3">Counting and numerical systems of the ancestors.</p>
                  <div className="h-1.5 bg-white/5 rounded-full overflow-hidden w-32">
                    <div className="h-full bg-primary w-[40%] rounded-full" />
                  </div>
                </div>
              </div>
            </div>
          </section>

          <section className="space-y-6">
            <div className="flex items-center justify-between">
              <h3 className="text-2xl font-bold text-cream">Community Voices</h3>
              <div className="flex gap-2">
                <button onClick={() => handleAction('Previous Voice')} className="p-2 bg-white/5 rounded-full text-cream/40 hover:text-primary transition-colors min-h-[44px] min-w-[44px] flex items-center justify-center">
                  <ChevronLeft className="w-5 h-5" />
                </button>
                <button onClick={() => handleAction('Next Voice')} className="p-2 bg-white/5 rounded-full text-cream/40 hover:text-primary transition-colors min-h-[44px] min-w-[44px] flex items-center justify-center">
                  <ChevronRight className="w-5 h-5" />
                </button>
              </div>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {voices.map((voice, i) => (
                <div key={i} className="bg-surface-low border border-white/5 rounded-[2.5rem] p-8 space-y-6 group hover:bg-white/10 transition-all">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-4">
                      <img src={`https://picsum.photos/seed/voice${i}/100/100`} className="w-12 h-12 rounded-full border-2 border-primary/30" alt="Voice" referrerPolicy="no-referrer" />
                      <div>
                        <div className="font-bold text-cream">{voice.name}</div>
                        <div className="text-[10px] text-cream/40 uppercase font-black tracking-widest">{voice.role}</div>
                      </div>
                    </div>
                    <button 
                      onClick={() => toggleVoice(i)}
                      className={`w-12 h-12 rounded-full flex items-center justify-center transition-all ${
                        playingVoice === i ? 'bg-terracotta text-white' : 'bg-primary text-forest'
                      } gold-shadow hover:scale-110 min-h-[44px] min-w-[44px]`}
                    >
                      {playingVoice === i ? <Pause className="w-5 h-5 fill-current" /> : <Play className="w-5 h-5 fill-current" />}
                    </button>
                  </div>
                  <div className="space-y-2">
                    <div className="text-2xl font-headline font-bold text-cream">"{voice.text}"</div>
                    <div className="text-sm text-cream/40 italic">Translation: {voice.trans}</div>
                  </div>
                  <div className="flex items-center gap-1 h-8">
                    {[...Array(15)].map((_, j) => (
                      <motion.div 
                        key={j} 
                        animate={playingVoice === i ? {
                          height: [`${30 + Math.random() * 70}%`, `${30 + Math.random() * 70}%`, `${30 + Math.random() * 70}%`]
                        } : { height: '30%' }}
                        transition={{ repeat: Infinity, duration: 0.5, delay: j * 0.05 }}
                        className={`flex-1 rounded-full ${playingVoice === i ? 'bg-primary' : 'bg-primary/20'}`}
                      ></motion.div>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </section>
        </div>
      </div>
    </motion.div>
  );
};

export default Dashboard;
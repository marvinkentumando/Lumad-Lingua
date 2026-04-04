import React, { useState, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useFirebase } from '../../Contexts/FirebaseContext';
import { toast } from 'sonner';
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
  BarChart3 
} from 'lucide-react';

interface DashboardProps {
  onContinueAscent?: () => void;
}

const Dashboard: React.FC<DashboardProps> = ({ onContinueAscent }) => {
  const { profile } = useFirebase();
  const [playingVoice, setPlayingVoice] = useState<number | null>(null);
  const audioRef = useRef<HTMLAudioElement | null>(null);

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
      className="space-y-8 pb-32 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8"
    >
      {/* Hero Section */}
      <section className="relative overflow-hidden bg-surface-low rounded-[2.5rem] p-8 md:p-12 border border-white/5 shadow-2xl group">
        <div className="absolute top-0 right-0 w-1/2 h-full opacity-10 pointer-events-none">
          <img 
            src="https://picsum.photos/seed/mountain/800/600" 
            alt="Mountain Background" 
            className="w-full h-full object-cover rounded-r-[2.5rem]"
            referrerPolicy="no-referrer"
          />
        </div>
        <div className="relative z-10 max-w-2xl space-y-6">
          <div className="inline-flex items-center bg-primary text-forest px-4 py-1.5 rounded-full text-[10px] font-black uppercase tracking-widest gold-shadow">
            Level {profile?.level || 1}: {profile?.level && profile.level > 5 ? 'The Summit' : profile?.level && profile.level > 2 ? 'The Canopy' : 'The Roots'}
          </div>
          <h2 className="text-5xl md:text-7xl font-headline font-bold text-cream leading-tight tracking-tight">
            Mountain <br /> Journey
          </h2>
          <p className="text-cream/60 text-lg md:text-xl leading-relaxed">
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
      </section>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 md:gap-6">
        {[
          { label: 'Total XP', val: (profile?.xp || 0).toLocaleString(), icon: Trophy, color: 'text-primary', bg: 'bg-primary/5' },
          { label: 'Levels Done', val: `${profile?.level || 1} / 10`, icon: MapIcon, color: 'text-green-500', bg: 'bg-green-500/5' },
          { label: 'Day Streak', val: (profile?.streak || 0).toString(), icon: Flame, color: 'text-orange-500', bg: 'bg-orange-500/5' },
          { label: 'Words Learned', val: ((profile?.completedLessons?.length || 0) * 5).toString(), icon: BookOpen, color: 'text-blue-400', bg: 'bg-blue-400/5' },
        ].map((stat, i) => (
          <div key={i} className="bg-surface-low border border-white/5 rounded-[2rem] p-6 flex items-center gap-4 hover:bg-white/5 transition-all min-h-[44px]">
            <div className={`w-12 h-12 ${stat.bg} rounded-2xl flex items-center justify-center ${stat.color}`}>
              <stat.icon className="w-6 h-6" />
            </div>
            <div>
              <div className="text-[9px] font-black uppercase tracking-widest text-cream/20 mb-1">{stat.label}</div>
              <div className="text-xl font-black text-cream">{stat.val}</div>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        {/* Left Column: Levels & Voices */}
        <div className="lg:col-span-8 space-y-12">
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

        {/* Right Column: Word of Day & Leaderboard */}
        <div className="lg:col-span-4 space-y-8">
          <div className="bg-gradient-to-br from-terracotta to-[#8B310A] rounded-[2.5rem] p-8 terracotta-shadow relative overflow-hidden group">
            <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-16 -mt-16 blur-2xl"></div>
            <div className="relative z-10 space-y-6">
              <div className="text-[10px] font-black uppercase tracking-widest text-white/60">Word of the Day</div>
              <h4 className="text-4xl font-headline font-bold text-white tracking-tight">Kalasangan</h4>
              <p className="text-white/60 font-mono text-xs tracking-widest">/ka.la.sa.ngan/</p>
              
              <div className="flex items-center gap-4">
                <button onClick={() => handleAction('Play Word of the Day')} className="w-10 h-10 bg-white/20 rounded-full flex items-center justify-center text-white backdrop-blur-md min-h-[44px] min-w-[44px]">
                  <Volume2 className="w-5 h-5" />
                </button>
                <div>
                  <div className="text-lg font-bold text-white">Forest</div>
                  <div className="text-[10px] text-white/40 uppercase font-black tracking-widest">Noun</div>
                </div>
              </div>
              
              <p className="text-white/70 text-sm leading-relaxed italic">
                "The forest is our home and our spirit. We protect the Kalasangan."
              </p>
            </div>
          </div>

          <div className="bg-surface-low border border-white/5 rounded-[2.5rem] p-8 space-y-6">
            <div className="flex items-center justify-between">
              <h4 className="text-xl font-bold text-cream">Top Climbers</h4>
              <BarChart3 className="w-5 h-5 text-cream/20" />
            </div>
            <div className="space-y-4">
              {[
                { name: 'Bai Siling', level: 24, xp: '8.2k', img: 'bai' },
                { name: 'Bagani Mar', level: 21, xp: '7.5k', img: 'bagani' },
                { name: `You (${profile?.displayName || 'Learner'})`, level: profile?.level || 1, xp: `${((profile?.xp || 0) / 1000).toFixed(1)}k`, img: profile?.uid || 'datu', isMe: true },
              ].map((user, i) => (
                <div key={i} className={`flex items-center gap-4 p-4 rounded-2xl transition-all ${user.isMe ? 'bg-primary/10 border border-primary/20' : 'hover:bg-white/5'}`}>
                  <div className="w-6 font-mono text-xs text-cream/20">{i + 1}</div>
                  <img src={`https://api.dicebear.com/7.x/avataaars/svg?seed=${user.img}`} className="w-10 h-10 rounded-xl bg-forest" alt="User" referrerPolicy="no-referrer" />
                  <div className="flex-1">
                    <div className="text-sm font-bold text-cream">{user.name}</div>
                    <div className="text-[9px] text-cream/40 uppercase font-black tracking-widest">Level {user.level}</div>
                  </div>
                  <div className="text-sm font-black text-primary">{user.xp} XP</div>
                </div>
              ))}
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
      </div>
    </motion.div>
  );
};

export default Dashboard;
import React, { useState, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Sparkles, ChevronRight, BookOpen, Trophy, Star } from 'lucide-react';
import { useFirebase } from '../../Contexts/FirebaseContext';
import { toast } from 'sonner';

interface LearnProps {
  setIsQuizActive: (active: boolean, lessonId?: string) => void;
}

const Learn: React.FC<LearnProps> = ({ setIsQuizActive }) => {
  const { profile } = useFirebase();
  const [currentLang, setCurrentLang] = useState<'mansaka' | 'mandaya'>('mansaka');
  const [expandedUnits, setExpandedUnits] = useState<Set<number>>(new Set([1, 2]));
  const [qvIndex, setQvIndex] = useState(0);
  const [qvRevealed, setQvRevealed] = useState(false);
  const [difficulty, setDifficulty] = useState<'beginner' | 'intermediate' | 'advanced'>('beginner');

  const toggleUnit = (id: number) => {
    const newExpanded = new Set(expandedUnits);
    if (newExpanded.has(id)) {
      newExpanded.delete(id);
    } else {
      newExpanded.add(id);
    }
    setExpandedUnits(newExpanded);
  };

  const PATHS = useMemo(() => ({
    mansaka: [
      {
        id: 1, unit: 'Unit 1', title: 'Greetings & Basic Phrases',
        lessons: [
          { id: 'mansaka_u1_l1', icon: '👋', name: 'Hello & Goodbye', type: 'vocab', dur: '5 min', xp: 15, stars: 3 },
          { id: 'mansaka_u1_l2', icon: '🗣️', name: 'Introducing Yourself', type: 'listen', dur: '8 min', xp: 20, stars: 2 },
          { id: 'mansaka_u1_l3', icon: '📝', name: 'Thank You & Please', type: 'quiz', dur: '6 min', xp: 18, stars: 3 },
          { id: 'mansaka_u1_l4', icon: '🤝', name: 'How Are You?', type: 'match', dur: '7 min', xp: 20, stars: 0 },
        ]
      },
      {
        id: 2, unit: 'Unit 2', title: 'Family & Kinship',
        lessons: [
          { id: 'mansaka_u2_l1', icon: '👨‍👩‍👧‍👦', name: 'Mother, Father, Child', type: 'vocab', dur: '6 min', xp: 15, stars: 3 },
          { id: 'mansaka_u2_l2', icon: '🎧', name: 'Siblings & Extended Family', type: 'listen', dur: '9 min', xp: 22, stars: 2 },
          { id: 'mansaka_u2_l3', icon: '💬', name: 'Respect & Address Terms', type: 'quiz', dur: '7 min', xp: 20, stars: 1 },
          { id: 'mansaka_u2_l4', icon: '📝', name: 'Family & Kinship Review', type: 'quiz', dur: '8 min', xp: 25, stars: 0 },
        ]
      },
      {
        id: 3, unit: 'Unit 3', title: 'Nature & The Forest',
        lessons: [
          { id: 'mansaka_u3_l1', icon: '🌲', name: 'Trees & Plants', type: 'vocab', dur: '7 min', xp: 18, stars: 0 },
          { id: 'mansaka_u3_l2', icon: '🍎', name: 'Food & Market', type: 'vocab', dur: '8 min', xp: 20, stars: 0 },
          { id: 'mansaka_u3_l3', icon: '🏔️', name: 'Nature & Spirit', type: 'vocab', dur: '9 min', xp: 22, stars: 0 },
          { id: 'mansaka_u3_l4', icon: '📝', name: 'Unit 3 Review', type: 'quiz', dur: '10 min', xp: 25, stars: 0 },
        ]
      },
    ],
    mandaya: [
      {
        id: 1, unit: 'Unit 1', title: 'Cultural Greetings',
        lessons: [
          { id: 'mandaya_u1_l1', icon: '🙏', name: 'Traditional Greetings', type: 'vocab', dur: '10 min', xp: 15, stars: 3 },
          { id: 'mandaya_u1_l2', icon: '🌿', name: 'The Inaul & Weaving', type: 'vocab', dur: '12 min', xp: 20, stars: 0 },
        ]
      },
      {
        id: 2, unit: 'Unit 2', title: 'Nature & Environment',
        lessons: [
          { id: 'mandaya_u2_l1', icon: '🏔️', name: 'Mountains & Rivers', type: 'vocab', dur: '10 min', xp: 15, stars: 0 },
        ]
      },
    ]
  }), []);

  const getLessonStatus = (lessonId: string, path: any[]) => {
    if (!profile) return 'locked';
    if (profile.completedLessons.includes(lessonId)) return 'done';
    
    let allLessons: any[] = [];
    path.forEach(u => allLessons = [...allLessons, ...u.lessons]);
    
    const idx = allLessons.findIndex(l => l.id === lessonId);
    if (idx === 0) return 'active';
    
    const prevLesson = allLessons[idx - 1];
    if (profile.completedLessons.includes(prevLesson.id)) return 'active';
    
    return 'locked';
  };

  const getUnitStatus = (unitId: number, path: any[]) => {
    const unit = path.find(u => u.id === unitId);
    if (!unit || !profile) return 'locked';
    
    const allDone = unit.lessons.every((l: any) => profile.completedLessons.includes(l.id));
    if (allDone) return 'done';
    
    const anyActive = unit.lessons.some((l: any) => getLessonStatus(l.id, path) === 'active');
    if (anyActive) return 'active';
    
    const idx = path.findIndex(u => u.id === unitId);
    if (idx === 0) return 'active';
    const prevUnit = path[idx - 1];
    if (prevUnit.lessons.every((l: any) => profile.completedLessons.includes(l.id))) return 'active';

    return 'locked';
  };

  const QUICK_VOCAB = [
    { word: 'Salamat', lang: 'Mansaka · interjection', meaning: 'Thank you — deeply embedded in Mansaka culture and used in both casual and ceremonial contexts.' },
    { word: 'Maayong buntag', lang: 'Mansaka · phrase', meaning: 'Good morning — the traditional greeting when meeting someone at dawn or early in the day.' },
    { word: 'Tubig', lang: 'Mansaka · noun', meaning: 'Water — considered sacred in Lumad cosmology and central to purification rituals.' },
    { word: 'Kabukiran', lang: 'Mandaya · noun', meaning: 'The mountain or highland — the ancestral home of the Lumad peoples.' },
    { word: 'Dagat', lang: 'Mandaya · noun', meaning: 'The sea or ocean — revered as a spiritual boundary between the living world and spirit realm.' },
    { word: 'Diwata', lang: 'Mansaka · noun', meaning: 'A benevolent nature spirit believed to inhabit trees, mountains, and bodies of water.' },
    { word: 'Lumad', lang: 'Mansaka · noun', meaning: 'Indigenous people of Mindanao — a collective identity for 18 ethnolinguistic groups.' },
  ];

  const currentPath = PATHS[currentLang];
  const currentVocab = QUICK_VOCAB[qvIndex];

  const isBeginnerCompleted = useMemo(() => {
    if (!profile) return false;
    return currentPath.every(unit => unit.lessons.every((l: any) => profile.completedLessons.includes(l.id)));
  }, [profile, currentPath]);

  const isIntermediateCompleted = false; // Placeholder for future logic

  return (
    <motion.div 
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="pb-32"
    >
      {/* Hero Band */}
      <section className="relative overflow-hidden bg-forest/50 rounded-[2.5rem] p-10 mb-12 border border-white/5">
        <div className="relative z-10 flex flex-col md:flex-row md:items-start justify-between gap-12">
          <div className="pt-4">
            <div className="flex items-center gap-2 text-[10px] font-mono uppercase tracking-widest text-primary/60 mb-4">
              <span>Dashboard</span>
              <span>→</span>
              <span className="text-primary">Language Learning</span>
            </div>
            <h2 className="text-5xl font-headline font-bold text-cream mb-6 leading-tight">Your Learning <em className="text-primary not-italic">Journey</em></h2>
            <p className="text-cream/60 max-w-md text-lg leading-relaxed">Every level is a step higher on the mountain. The ancestors are watching your progress.</p>
          </div>
          <div className="bg-white/5 border border-white/10 rounded-[2rem] p-8 min-w-[340px] relative overflow-hidden shadow-2xl">
            <div className="absolute top-0 left-0 right-0 h-1.5 bg-gradient-to-r from-primary to-orange-500"></div>
            <div className="flex items-center gap-2 text-[10px] font-black uppercase tracking-[0.2em] text-primary mb-2">
              <span>🌿 MAAYONG BUNTAG</span>
            </div>
            <div className="text-4xl font-headline font-bold text-cream mb-6">{profile?.role || 'Learner'}</div>
            <div className="grid grid-cols-2 gap-4 mb-6">
              <div className="bg-white/5 border border-white/10 p-5 rounded-2xl">
                <div className="text-3xl font-headline font-bold text-primary">{profile?.streak || 0}</div>
                <div className="text-[9px] uppercase font-black text-cream/40 tracking-widest mt-1">Day Streak</div>
              </div>
              <div className="bg-white/5 border border-white/10 p-5 rounded-2xl">
                <div className="text-3xl font-headline font-bold text-primary">{profile?.completedLessons?.length || 0}</div>
                <div className="text-[9px] uppercase font-black text-cream/40 tracking-widest mt-1">Completed</div>
              </div>
            </div>
            <div className="space-y-3">
              <div className="flex justify-between text-[10px] font-mono text-cream/40 uppercase tracking-widest">
                <span>Level {profile?.level || 1} Progress</span>
                <span className="text-primary">{profile?.xp || 0} / {(profile?.level || 1) * 500} XP</span>
              </div>
              <div className="h-2.5 bg-white/10 rounded-full overflow-hidden">
                <div className="h-full bg-gradient-to-r from-primary to-orange-500 rounded-full" style={{ width: `${Math.min(100, ((profile?.xp || 0) / ((profile?.level || 1) * 500)) * 100)}%` }}></div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        <div className="lg:col-span-8 space-y-8">
          {/* Language Selector */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <button 
              onClick={() => setCurrentLang('mansaka')}
              className={`p-6 rounded-2xl border-2 transition-all text-left relative overflow-hidden ${
                currentLang === 'mansaka' 
                  ? 'bg-primary/10 border-primary' 
                  : 'bg-white/5 border-white/10 hover:border-primary/30'
              }`}
            >
              {currentLang === 'mansaka' && <div className="absolute top-0 left-0 right-0 h-1 bg-primary"></div>}
              <div className="flex justify-between items-start mb-4">
                <span className="text-3xl">🏔️</span>
                {currentLang === 'mansaka' && <div className="w-2.5 h-2.5 bg-primary rounded-full shadow-[0_0_12px_#FFC200]"></div>}
              </div>
              <div className="text-2xl font-bold text-cream">Mansaka</div>
              <div className="text-[10px] font-mono text-cream/40 uppercase tracking-widest mt-1">Davao del Norte · Compostela Valley</div>
              <div className="mt-4 space-y-2">
                <div className="flex justify-between text-[10px] font-mono">
                  <span className="text-cream/40">Your Progress</span>
                  <span className="text-primary">{profile?.completedLessons.filter(id => id.startsWith('mansaka')).length || 0} / 45 lessons</span>
                </div>
                <div className="h-1.5 bg-white/10 rounded-full overflow-hidden">
                  <div className="h-full bg-primary rounded-full" style={{ width: `${Math.min(100, ((profile?.completedLessons.filter(id => id.startsWith('mansaka')).length || 0) / 45) * 100)}%` }}></div>
                </div>
              </div>
            </button>

            <button 
              onClick={() => setCurrentLang('mandaya')}
              className={`p-6 rounded-2xl border-2 transition-all text-left relative overflow-hidden ${
                currentLang === 'mandaya' 
                  ? 'bg-primary/10 border-primary' 
                  : 'bg-white/5 border-white/10 hover:border-primary/30'
              }`}
            >
              {currentLang === 'mandaya' && <div className="absolute top-0 left-0 right-0 h-1 bg-primary"></div>}
              <div className="flex justify-between items-start mb-4">
                <span className="text-3xl">🌿</span>
                {currentLang === 'mandaya' && <div className="w-2.5 h-2.5 bg-primary rounded-full shadow-[0_0_12px_#FFC200]"></div>}
              </div>
              <div className="text-2xl font-bold text-cream">Mandaya</div>
              <div className="text-[10px] font-mono text-cream/40 uppercase tracking-widest mt-1">Davao Oriental · Caraga</div>
              <div className="mt-4 space-y-2">
                <div className="flex justify-between text-[10px] font-mono">
                  <span className="text-cream/40">Your Progress</span>
                  <span className="text-primary">{profile?.completedLessons.filter(id => id.startsWith('mandaya')).length || 0} / 38 lessons</span>
                </div>
                <div className="h-1.5 bg-white/10 rounded-full overflow-hidden">
                  <div className="h-full bg-primary rounded-full" style={{ width: `${Math.min(100, ((profile?.completedLessons.filter(id => id.startsWith('mandaya')).length || 0) / 38) * 100)}%` }}></div>
                </div>
              </div>
            </button>
          </div>

          {/* Continue Learning */}
          <div className="bg-white/5 border-l-4 border-l-green-500 border border-white/10 rounded-2xl p-6 flex flex-col sm:flex-row items-center justify-between gap-6">
            <div className="flex-1">
              <div className="flex items-center gap-2 text-[10px] font-black uppercase tracking-widest text-green-500 mb-2">
                <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                <span>Continue where you left off</span>
              </div>
              {(() => {
                let nextLesson = null;
                let nextUnit = null;
                if (profile) {
                  for (const unit of currentPath) {
                    for (const lesson of unit.lessons) {
                      if (!profile.completedLessons.includes(lesson.id)) {
                        nextLesson = lesson;
                        nextUnit = unit;
                        break;
                      }
                    }
                    if (nextLesson) break;
                  }
                }
                
                if (nextLesson && nextUnit) {
                  return (
                    <>
                      <div className="text-xl font-bold text-cream mb-1">
                        {nextUnit.unit} · {nextLesson.name}
                      </div>
                      <div className="text-sm text-cream/50">
                        {nextLesson.type === 'vocab' ? 'Vocabulary drill' : nextLesson.type === 'quiz' ? 'Multiple-choice quiz' : nextLesson.type === 'listen' ? 'Listening exercise' : 'Interactive lesson'} · +{nextLesson.xp} XP
                      </div>
                    </>
                  );
                }
                return (
                  <div className="text-xl font-bold text-cream mb-1">
                    All caught up!
                  </div>
                );
              })()}
            </div>
            <button 
              onClick={() => {
                if (!profile) return;
                let nextLesson = null;
                for (const unit of currentPath) {
                  for (const lesson of unit.lessons) {
                    if (!profile.completedLessons.includes(lesson.id)) {
                      nextLesson = lesson;
                      break;
                    }
                  }
                  if (nextLesson) break;
                }
                if (nextLesson) {
                  setIsQuizActive(true, nextLesson.id);
                } else {
                  toast.success("You have completed all lessons in this path!");
                }
              }}
              className="bg-primary text-forest px-8 py-3 rounded-xl font-black gold-shadow hover:-translate-y-1 active:translate-y-1 transition-all whitespace-nowrap"
            >
              Resume →
            </button>
          </div>

          {/* Learning Path */}
          <div className="space-y-6">
            <div className="flex items-baseline justify-between border-b border-primary/20 pb-4">
              <div>
                <span className="text-[10px] font-black uppercase tracking-widest text-primary mb-1 block">🏔️ Climb the Mountain</span>
                <h3 className="text-2xl font-bold text-cream">{currentLang === 'mansaka' ? 'Mansaka' : 'Mandaya'} Learning <em className="text-primary not-italic">Path</em></h3>
              </div>
              <button className="text-[10px] font-mono uppercase tracking-widest text-primary hover:text-primary/80">View All →</button>
            </div>

            <div className="relative pl-10 space-y-4">
              <div className="absolute left-4.5 top-0 bottom-0 w-0.5 bg-gradient-to-b from-primary via-primary/30 to-transparent"></div>
              
              {currentPath.map((unit) => (
                <div key={unit.id} className="relative">
                  <div className={`absolute -left-7.5 top-5 w-4 h-4 rounded-full border-2 z-10 ${
                    getUnitStatus(unit.id, currentPath) === 'done' ? 'bg-green-500 border-green-500 shadow-[0_0_12px_rgba(34,197,94,0.4)]' :
                    getUnitStatus(unit.id, currentPath) === 'active' ? 'bg-primary border-primary' : 'bg-white/10 border-white/20'
                  }`}></div>
                  
                  <button 
                    onClick={() => toggleUnit(unit.id)}
                    className="w-full flex items-center gap-4 p-4 bg-white/5 border border-white/10 rounded-xl hover:bg-white/10 transition-all text-left"
                  >
                    <span className="bg-primary/10 border border-primary/20 px-2 py-1 rounded-lg text-[10px] font-bold text-primary">{unit.unit}</span>
                    <span className="flex-1 font-bold text-cream">{unit.title}</span>
                    <span className="font-mono text-[10px] text-cream/20">{unit.lessons.filter(l => profile?.completedLessons.includes(l.id)).length}/{unit.lessons.length}</span>
                    <span className={`text-[9px] font-black uppercase px-2 py-1 rounded-full ${
                      getUnitStatus(unit.id, currentPath) === 'done' ? 'bg-green-500/20 text-green-500' :
                      getUnitStatus(unit.id, currentPath) === 'active' ? 'bg-primary/20 text-primary' : 'bg-white/10 text-cream/40'
                    }`}>
                      {getUnitStatus(unit.id, currentPath) === 'done' ? '✓ Complete' : getUnitStatus(unit.id, currentPath) === 'active' ? '▶ In Progress' : '🔒 Locked'}
                    </span>
                    <ChevronRight className={`w-4 h-4 text-cream/40 transition-transform ${expandedUnits.has(unit.id) ? 'rotate-90' : ''}`} />
                  </button>

                  <AnimatePresence>
                    {expandedUnits.has(unit.id) && (
                      <motion.div 
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        className="overflow-hidden mt-2 space-y-2"
                      >
                        {unit.lessons.map((lesson, lIdx) => {
                          const status = getLessonStatus(lesson.id, currentPath);
                          return (
                            <div 
                              key={lIdx}
                              onClick={() => status !== 'locked' && setIsQuizActive(true, lesson.id, lesson.type)}
                              className={`flex items-center gap-4 p-4 rounded-xl border-2 transition-all cursor-pointer ${
                                status === 'locked' ? 'opacity-50 grayscale bg-white/5 border-transparent' :
                                status === 'active' ? 'bg-cream border-primary gold-shadow' : 'bg-cream border-cream/20 pressed-shadow'
                              }`}
                            >
                              <div className="w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center text-xl">
                                {lesson.icon}
                              </div>
                              <div className="flex-1">
                                <div className={`font-bold ${status === 'locked' ? 'text-cream/40' : 'text-forest'}`}>{lesson.name}</div>
                                <div className="flex items-center gap-3 mt-1">
                                  <span className={`text-[9px] font-black uppercase px-2 py-0.5 rounded-full ${
                                    lesson.type === 'vocab' ? 'bg-green-500/10 text-green-700' :
                                    lesson.type === 'quiz' ? 'bg-blue-500/10 text-blue-700' :
                                    lesson.type === 'listen' ? 'bg-orange-500/10 text-orange-700' : 'bg-red-500/10 text-red-700'
                                  }`}>
                                    {lesson.type}
                                  </span>
                                  <span className="text-[10px] font-mono text-forest/40">⏱ {lesson.dur}</span>
                                  <span className="text-[10px] font-mono text-forest/40">+{lesson.xp} XP</span>
                                </div>
                              </div>
                              <div className="flex items-center gap-3">
                                {status === 'done' && (
                                  <div className="flex gap-0.5">
                                    {[1, 2, 3].map(s => (
                                      <Star key={s} className={`w-3 h-3 ${s <= lesson.stars ? 'text-primary fill-primary' : 'text-forest/10'}`} />
                                    ))}
                                  </div>
                                )}
                                {status === 'done' ? (
                                  <div className="w-6 h-6 bg-green-500 text-white rounded-full flex items-center justify-center text-[10px] font-black">✓</div>
                                ) : status === 'active' ? (
                                  <button 
                                    onClick={(e) => {
                                      e.stopPropagation();
                                      setIsQuizActive(true, lesson.id, lesson.type);
                                    }}
                                    className="bg-primary text-forest px-4 py-1.5 rounded-lg text-xs font-black gold-shadow active:translate-y-1 transition-all"
                                  >
                                    Start →
                                  </button>
                                ) : (
                                  <span className="text-cream/20">🔒</span>
                                )}
                              </div>
                            </div>
                          );
                        })}
                      </motion.div>
                    )}
                  </AnimatePresence>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Sidebar */}
        <aside className="lg:col-span-4 space-y-6">
          {/* Quick Vocab */}
          <div className="bg-white/5 border border-white/10 rounded-2xl p-6 space-y-6">
            <div className="flex items-center justify-between border-b border-white/10 pb-4">
              <h4 className="font-bold text-cream">Quick Vocab</h4>
              <BookOpen className="w-4 h-4 text-primary" />
            </div>
            <div className="text-center py-4">
              <div className="text-4xl font-bold text-primary mb-2">{currentVocab.word}</div>
              <div className="text-[10px] font-mono text-cream/40 uppercase tracking-widest mb-6">{currentVocab.lang}</div>
              <div className={`text-sm text-cream/70 min-h-[80px] flex items-center justify-center italic transition-opacity duration-300 ${qvRevealed ? 'opacity-100' : 'opacity-0'}`}>
                {currentVocab.meaning}
              </div>
            </div>
            {!qvRevealed ? (
              <button 
                onClick={() => setQvRevealed(true)}
                className="w-full bg-primary text-forest py-3 rounded-xl font-black gold-shadow active:translate-y-1 transition-all"
              >
                Reveal Meaning
              </button>
            ) : (
              <div className="flex gap-2">
                <button className="flex-1 bg-white/5 border border-white/10 text-cream py-3 rounded-xl font-black hover:bg-white/10 transition-all">🔊 Listen</button>
                <button 
                  onClick={() => {
                    setQvIndex((qvIndex + 1) % QUICK_VOCAB.length);
                    setQvRevealed(false);
                  }}
                  className="flex-1 bg-primary text-forest py-3 rounded-xl font-black gold-shadow active:translate-y-1 transition-all"
                >
                  Next →
                </button>
              </div>
            )}
          </div>

          {/* Achievements */}
          <div className="bg-white/5 border border-white/10 rounded-2xl p-6 space-y-4">
            <div className="flex items-center justify-between border-b border-white/10 pb-4">
              <h4 className="font-bold text-cream">Achievements</h4>
              <Trophy className="w-4 h-4 text-primary" />
            </div>
            <div className="space-y-3">
              {(() => {
                const achievements = [];
                if (profile && profile.streak >= 7) {
                  achievements.push({ icon: '🔥', name: '7-Day Streak', desc: 'Practiced every day this week', date: 'Unlocked' });
                }
                if (profile && profile.xp >= 100) {
                  achievements.push({ icon: '⭐', name: 'First 100 XP', desc: 'Reached your first milestone', date: 'Unlocked' });
                }
                if (profile && profile.completedLessons.filter(id => id.startsWith('mansaka_u1')).length >= 4) {
                  achievements.push({ icon: '🏔️', name: 'Unit 1 Master', desc: 'Finished "Greetings"', date: 'Unlocked' });
                }
                if (achievements.length === 0) {
                  return <div className="text-sm text-cream/40 text-center py-4">Complete lessons to unlock achievements!</div>;
                }
                return achievements.map((ach, idx) => (
                  <div key={idx} className="flex items-center gap-3 p-3 bg-primary/5 border border-primary/10 rounded-xl">
                    <span className="text-2xl">{ach.icon}</span>
                    <div className="flex-1 min-w-0">
                      <div className="text-sm font-bold text-cream truncate">{ach.name}</div>
                      <div className="text-[10px] text-cream/40 truncate">{ach.desc}</div>
                    </div>
                    <div className="text-[9px] font-mono text-cream/20 whitespace-nowrap">{ach.date}</div>
                  </div>
                ));
              })()}
            </div>
          </div>

          {/* Difficulty */}
          <div className="bg-white/5 border border-white/10 rounded-2xl p-6 space-y-4">
            <div className="flex items-center justify-between border-b border-white/10 pb-4">
              <h4 className="font-bold text-cream">Difficulty</h4>
              <Sparkles className="w-4 h-4 text-primary" />
            </div>
            <div className="space-y-2">
              {(['beginner', 'intermediate', 'advanced'] as const).map((level) => {
                const isUnlocked = level === 'beginner' || (level === 'intermediate' && isBeginnerCompleted) || (level === 'advanced' && isIntermediateCompleted);
                return (
                  <button 
                    key={level}
                    onClick={() => isUnlocked && setDifficulty(level)}
                    className={`w-full flex items-center justify-between p-3 rounded-xl border transition-all ${
                      difficulty === level 
                        ? 'bg-primary/10 border-primary text-primary' 
                        : isUnlocked
                          ? 'bg-white/5 border-white/10 text-cream hover:bg-white/10'
                          : 'bg-white/5 border-white/10 text-cream/40 cursor-not-allowed'
                    }`}
                  >
                    <span className="capitalize font-bold">{level}</span>
                    <span className={`text-[9px] font-black uppercase px-2 py-0.5 rounded-full ${
                      level === 'beginner' ? 'bg-blue-500/20 text-blue-400' :
                      level === 'intermediate' ? 'bg-orange-500/20 text-orange-400' : 'bg-red-500/20 text-red-400'
                    }`}>
                      {difficulty === level ? 'Active' : isUnlocked ? 'Unlocked' : 'Locked'}
                    </span>
                  </button>
                );
              })}
            </div>
          </div>
        </aside>
      </div>
    </motion.div>
  );
};

export default Learn;

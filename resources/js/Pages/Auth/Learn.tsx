import React, { useState, useMemo } from 'react';
import { motion } from 'framer-motion';
import { CheckCircle2, Play, RotateCcw, FileText, Hash, Headphones, HelpCircle, Link as LinkIcon, Star, ChevronRight } from 'lucide-react';
import { useFirebase } from '../../Contexts/FirebaseContext';

interface LearnProps {
  setIsQuizActive: (active: boolean, lessonId?: string) => void;
}

const Learn: React.FC<LearnProps> = ({ setIsQuizActive }) => {
  const { profile } = useFirebase();
  const [difficulty, setDifficulty] = useState<'beginner' | 'elementary' | 'intermediate' | 'advanced'>('beginner');

  const PATHS = useMemo(() => ({
    mansaka: [
      {
        id: 1, unit: 'Unit 1', title: 'Greetings & Everyday Words',
        lessons: [
          { id: 'mansaka_u1_l1', icon: FileText, name: 'Hello, Goodbye & Thank You', type: 'VOCABULARY', dur: '5 MIN', xp: '1k', stars: 3 },
          { id: 'mansaka_u1_l2', icon: Hash, name: 'Numbers 1–10', type: 'VOCABULARY', dur: '8 MIN', xp: '1k', stars: 3 },
          { id: 'mansaka_u1_l3', icon: Headphones, name: 'Colors of the Weave', type: 'LISTENING', dur: '7 MIN', xp: '30', stars: 2 },
          { id: 'mansaka_u1_l4', icon: HelpCircle, name: 'Greetings Quiz', type: 'QUIZ', dur: '5 MIN', xp: '25', stars: 3 },
          { id: 'mansaka_u1_l5', icon: LinkIcon, name: 'Unit 1 Review', type: 'MATCHING', dur: '8 MIN', xp: '30', stars: 3 },
        ]
      },
      {
        id: 2, unit: 'Unit 2', title: 'Family & Kinship',
        lessons: [
          { id: 'mansaka_u2_l1', icon: FileText, name: 'Family Members', type: 'VOCABULARY', dur: '6 MIN', xp: '15', stars: 3 },
          { id: 'mansaka_u2_l2', icon: Headphones, name: 'Siblings & Extended Family', type: 'LISTENING', dur: '9 MIN', xp: '22', stars: 2 },
          { id: 'mansaka_u2_l3', icon: HelpCircle, name: 'Respect & Address Terms', type: 'QUIZ', dur: '7 MIN', xp: '20', stars: 0 },
          { id: 'mansaka_u2_l4', icon: LinkIcon, name: 'Family & Kinship Review', type: 'MATCHING', dur: '8 MIN', xp: '25', stars: 0 },
        ]
      },
      {
        id: 3, unit: 'Unit 3', title: 'Nature & The Forest',
        lessons: [
          { id: 'mansaka_u3_l1', icon: FileText, name: 'Trees & Plants', type: 'VOCABULARY', dur: '7 MIN', xp: '18', stars: 0 },
        ]
      },
    ]
  }), []);

  const currentPath = PATHS.mansaka;

  // Determine next lesson
  let nextLesson = null;
  let nextUnit = null;
  let nextUnitIndex = 0;
  let completedLessonsInNextUnit = 0;

  if (profile) {
    for (let i = 0; i < currentPath.length; i++) {
      const unit = currentPath[i];
      let unitCompletedCount = 0;
      for (const lesson of unit.lessons) {
        if (profile.completedLessons.includes(lesson.id)) {
          unitCompletedCount++;
        } else if (!nextLesson) {
          nextLesson = lesson;
          nextUnit = unit;
          nextUnitIndex = i;
        }
      }
      if (nextUnit === unit) {
        completedLessonsInNextUnit = unitCompletedCount;
      }
      if (nextLesson) break;
    }
  }

  // Fallback if all completed or no profile
  if (!nextLesson && currentPath.length > 0) {
    nextUnit = currentPath[0];
    nextLesson = nextUnit.lessons[0];
    nextUnitIndex = 0;
    completedLessonsInNextUnit = 0;
  }

  const getLessonStatus = (lessonId: string) => {
    if (!profile) return 'locked';
    if (profile.completedLessons.includes(lessonId)) return 'done';
    
    let allLessons: any[] = [];
    currentPath.forEach(u => allLessons = [...allLessons, ...u.lessons]);
    
    const idx = allLessons.findIndex(l => l.id === lessonId);
    if (idx === 0) return 'active';
    
    const prevLesson = allLessons[idx - 1];
    if (profile.completedLessons.includes(prevLesson.id)) return 'active';
    
    return 'locked';
  };

  return (
    <motion.div 
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="pb-32 max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12"
    >
      {/* Step 1: Continue where you left off */}
      <section className="bg-[#2d1b0e] border border-[#4a331c] rounded-lg p-8">
        <div className="flex items-center gap-2 mb-4">
          <div className="w-2 h-2 bg-green-500 rounded-full"></div>
          <span className="text-[10px] font-black uppercase tracking-widest text-green-500">Continue where you left off</span>
        </div>
        
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
          <div className="flex-1">
            <h2 className="text-2xl font-serif font-bold text-cream mb-2">
              {nextUnit?.unit} • {nextLesson?.name}
            </h2>
            <p className="text-cream/60 text-sm mb-6">
              {nextLesson?.type === 'QUIZ' ? 'Multiple-choice quiz' : nextLesson?.type === 'VOCABULARY' ? 'Vocabulary drill' : 'Interactive lesson'} - {nextLesson?.dur} - +{nextLesson?.xp} XP
            </p>
            
            <div className="space-y-2">
              <div className="flex justify-between text-[10px] font-black uppercase tracking-widest text-cream/40">
                <span>{nextUnit?.unit.toUpperCase()} PROGRESS</span>
                <span>{completedLessonsInNextUnit} / {nextUnit?.lessons.length} lessons complete</span>
              </div>
              <div className="h-1.5 bg-black/40 rounded-full overflow-hidden">
                <div 
                  className="h-full bg-green-500 rounded-full" 
                  style={{ width: `${(completedLessonsInNextUnit / (nextUnit?.lessons.length || 1)) * 100}%` }}
                ></div>
              </div>
            </div>
          </div>
          
          <div className="flex flex-col gap-3 w-full md:w-auto">
            <button 
              onClick={() => nextLesson && setIsQuizActive(true, nextLesson.id)}
              className="bg-primary text-black px-8 py-3 rounded font-black uppercase tracking-widest text-xs flex items-center justify-center gap-2 hover:bg-primary/90 transition-colors"
            >
              <Play className="w-4 h-4 fill-current" /> Continue Lesson
            </button>
            <button className="border border-[#4a331c] text-cream/60 px-8 py-3 rounded font-black uppercase tracking-widest text-xs flex items-center justify-center gap-2 hover:bg-white/5 transition-colors">
              <RotateCcw className="w-4 h-4" /> Restart Unit
            </button>
          </div>
        </div>
      </section>

      {/* Step 2: Select difficulty */}
      <section className="space-y-4">
        <div className="text-[10px] font-black uppercase tracking-widest text-primary">Step 2</div>
        <h2 className="text-3xl font-serif font-bold text-cream mb-6">Select <em className="text-primary italic font-serif">difficulty</em></h2>
        
        <div className="flex flex-wrap gap-3">
          {(['beginner', 'elementary', 'intermediate', 'advanced'] as const).map((level) => (
            <button
              key={level}
              onClick={() => setDifficulty(level)}
              className={`px-6 py-2.5 rounded text-[10px] font-black uppercase tracking-widest transition-colors ${
                difficulty === level 
                  ? 'border border-primary text-primary bg-primary/5' 
                  : 'border border-[#4a331c] text-cream/40 hover:bg-white/5 hover:text-cream/60'
              }`}
            >
              {level}
            </button>
          ))}
        </div>
      </section>

      {/* Step 3: Learning Path */}
      <section className="space-y-8">
        <div className="flex items-end justify-between mb-6">
          <div>
            <div className="text-[10px] font-black uppercase tracking-widest text-primary mb-2">Step 3</div>
            <h2 className="text-3xl font-serif font-bold text-cream">Mansaka Learning <em className="text-primary italic font-serif">Path</em></h2>
          </div>
          <button className="text-[10px] font-black uppercase tracking-widest text-primary hover:underline flex items-center gap-1">
            View All <ChevronRight className="w-3 h-3" />
          </button>
        </div>

        <div className="space-y-12">
          {currentPath.map((unit, uIdx) => {
            const completedLessons = unit.lessons.filter(l => profile?.completedLessons.includes(l.id)).length;
            const isUnitComplete = completedLessons === unit.lessons.length;
            const isUnitInProgress = completedLessons > 0 && !isUnitComplete;
            const isUnitNext = uIdx === nextUnitIndex;

            return (
              <div key={unit.id} className="space-y-4">
                {/* Unit Header */}
                <div className="flex items-center justify-between border-b border-[#4a331c] pb-4">
                  <div className="flex items-center gap-4">
                    <div className={`w-3 h-3 rounded-full ${isUnitComplete ? 'bg-primary' : isUnitInProgress || isUnitNext ? 'border-2 border-primary' : 'border-2 border-cream/20'}`}></div>
                    <div className="flex items-baseline gap-3">
                      <span className="text-[10px] font-black uppercase tracking-widest text-cream/40">{unit.unit}</span>
                      <h3 className="text-xl font-serif font-bold text-cream">{unit.title}</h3>
                    </div>
                  </div>
                  <div className="flex items-center gap-4">
                    <span className="text-[10px] font-mono text-cream/40">{completedLessons}/{unit.lessons.length}</span>
                    {isUnitComplete ? (
                      <div className="bg-green-500/10 border border-green-500/20 text-green-500 px-3 py-1 rounded text-[9px] font-black uppercase tracking-widest flex items-center gap-1">
                        <CheckCircle2 className="w-3 h-3" /> Complete
                      </div>
                    ) : isUnitInProgress || isUnitNext ? (
                      <div className="border border-primary text-primary px-3 py-1 rounded text-[9px] font-black uppercase tracking-widest flex items-center gap-1">
                        <Play className="w-3 h-3 fill-current" /> In Progress
                      </div>
                    ) : null}
                  </div>
                </div>

                {/* Lessons List */}
                <div className="space-y-2">
                  {unit.lessons.map((lesson, lIdx) => {
                    const status = getLessonStatus(lesson.id);
                    const isCompleted = status === 'done';
                    const isActive = status === 'active';

                    return (
                      <button 
                        key={lesson.id}
                        onClick={() => status !== 'locked' && setIsQuizActive(true, lesson.id)}
                        disabled={status === 'locked'}
                        className={`w-full flex items-center justify-between p-4 rounded-lg border transition-all text-left ${
                          status === 'locked' 
                            ? 'bg-[#1a110a] border-[#2a1a0a] opacity-50 cursor-not-allowed' 
                            : 'bg-[#21140b] border-[#3b2a1a] hover:bg-[#2d1b0e]'
                        }`}
                      >
                        <div className="flex items-center gap-4">
                          <div className={`w-10 h-10 rounded flex items-center justify-center ${
                            lesson.type === 'VOCABULARY' ? 'bg-blue-500/10 text-blue-400' :
                            lesson.type === 'LISTENING' ? 'bg-purple-500/10 text-purple-400' :
                            lesson.type === 'QUIZ' ? 'bg-pink-500/10 text-pink-400' :
                            'bg-gray-500/10 text-gray-400'
                          }`}>
                            <lesson.icon className="w-5 h-5" />
                          </div>
                          <div>
                            <div className="font-serif font-bold text-cream mb-1">{lesson.name}</div>
                            <div className="flex items-center gap-3 text-[9px] font-black uppercase tracking-widest">
                              <span className="border border-green-500/30 text-green-500 px-2 py-0.5 rounded">{lesson.type}</span>
                              <span className="text-cream/40 flex items-center gap-1">⏱ {lesson.dur}</span>
                              <span className="text-cream/40">+{lesson.xp} XP</span>
                            </div>
                          </div>
                        </div>
                        
                        <div className="flex items-center gap-4">
                          <div className="flex gap-1">
                            {[1, 2, 3].map(star => (
                              <Star 
                                key={star} 
                                className={`w-4 h-4 ${star <= (isCompleted ? lesson.stars : 0) ? 'text-primary fill-current' : 'text-cream/10'}`} 
                              />
                            ))}
                          </div>
                          {isCompleted ? (
                            <div className="w-6 h-6 rounded-full bg-green-500 flex items-center justify-center text-black">
                              <CheckCircle2 className="w-4 h-4" />
                            </div>
                          ) : (
                            <div className="w-6 h-6 rounded-full border-2 border-cream/10"></div>
                          )}
                        </div>
                      </button>
                    );
                  })}
                </div>
              </div>
            );
          })}
        </div>
      </section>
    </motion.div>
  );
};

export default Learn;

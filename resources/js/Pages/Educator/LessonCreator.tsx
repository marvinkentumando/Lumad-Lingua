import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Plus, Trash2, Save, ChevronRight, ChevronLeft, BookOpen, GraduationCap, Sparkles, Layout, ListChecks, Volume2, Link, Layers, Users, MessageSquare, Mic, Type } from 'lucide-react';
import { Lesson, LessonStep, StepType } from '../../types';
import { collection, addDoc, serverTimestamp } from 'firebase/firestore';
import { db } from '../../firebase';
import { toast } from 'sonner';

const STEP_TYPES: { type: StepType; label: string; icon: any; description: string }[] = [
  { type: 'vocab_drill', label: 'Vocabulary Drill', icon: BookOpen, description: 'Flashcards for new words' },
  { type: 'mcq', label: 'Multiple Choice', icon: ListChecks, description: 'Standard question with options' },
  { type: 'listen', label: 'Listening', icon: Volume2, description: 'Listen and choose the correct word' },
  { type: 'match', label: 'Matching', icon: Link, description: 'Match words with meanings' },
  { type: 'sorting', label: 'Sorting', icon: Layers, description: 'Drag and drop to sort items' },
  { type: 'sequence', label: 'Sequence', icon: Layers, description: 'Arrange items in correct order' },
  { type: 'family_tree', label: 'Family Tree', icon: Users, description: 'Identify family relationships' },
  { type: 'scenario', label: 'Scenario', icon: MessageSquare, description: 'Choose best response for a situation' },
  { type: 'pronunciation', label: 'Pronunciation', icon: Mic, description: 'Record and evaluate speech' },
  { type: 'sentence_building', label: 'Sentence Building', icon: Type, description: 'Arrange words to form a sentence' },
];

const LessonCreator: React.FC = () => {
  const [lesson, setLesson] = useState<Partial<Lesson>>({
    title: '',
    description: '',
    level: 1,
    steps: [],
    objectives: [''],
    discussion: {
      title: '',
      text: '',
      grammar: [''],
      culture: '',
    },
  });

  const [activeStep, setActiveStep] = useState<number | null>(null);

  const addStep = (type: StepType) => {
    const newStep: LessonStep = {
      id: Math.random().toString(36).substr(2, 9),
      type,
      title: `New ${type.replace('_', ' ')} Step`,
      content: type === 'sentence_building' ? [{ sentence: '', words: [] }] : [],
    };
    setLesson(prev => ({
      ...prev,
      steps: [...(prev.steps || []), newStep],
    }));
    setActiveStep((lesson.steps?.length || 0));
  };

  const removeStep = (index: number) => {
    setLesson(prev => ({
      ...prev,
      steps: prev.steps?.filter((_, i) => i !== index),
    }));
    if (activeStep === index) setActiveStep(null);
  };

  const updateStep = (index: number, updates: Partial<LessonStep>) => {
    setLesson(prev => ({
      ...prev,
      steps: prev.steps?.map((step, i) => i === index ? { ...step, ...updates } : step),
    }));
  };

  const handleSave = async () => {
    if (!lesson.title || !lesson.steps?.length) {
      toast.error('Please provide a title and at least one step');
      return;
    }

    try {
      await addDoc(collection(db, 'lessons'), {
        ...lesson,
        createdAt: serverTimestamp(),
      });
      toast.success('Lesson created successfully!');
    } catch (error) {
      console.error('Error saving lesson:', error);
      toast.error('Failed to save lesson');
    }
  };

  return (
    <div className="min-h-screen bg-forest p-8">
      <div className="max-w-6xl mx-auto space-y-8">
        <header className="flex items-center justify-between">
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 bg-primary rounded-2xl flex items-center justify-center gold-shadow">
              <Sparkles className="w-6 h-6 text-forest" />
            </div>
            <div>
              <h1 className="text-3xl font-headline font-bold text-cream">Lesson Weaver</h1>
              <p className="text-cream/40">Craft ancestral echoes into learning paths</p>
            </div>
          </div>
          <button 
            onClick={handleSave}
            className="bg-primary text-forest px-8 py-3 rounded-xl font-black uppercase tracking-widest gold-shadow hover:-translate-y-1 transition-all flex items-center gap-2"
          >
            <Save className="w-5 h-5" /> Save Lesson
          </button>
        </header>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Sidebar: Lesson Info & Steps */}
          <div className="space-y-6">
            <section className="bg-white/5 border border-white/10 rounded-[2rem] p-6 space-y-4">
              <h2 className="text-xs font-black uppercase tracking-widest text-primary/60">General Info</h2>
              <input 
                type="text" 
                placeholder="Lesson Title"
                value={lesson.title}
                onChange={e => setLesson(prev => ({ ...prev, title: e.target.value }))}
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-cream outline-none focus:border-primary/30"
              />
              <textarea 
                placeholder="Description"
                value={lesson.description}
                onChange={e => setLesson(prev => ({ ...prev, description: e.target.value }))}
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-cream outline-none focus:border-primary/30 h-24 resize-none"
              />
              <div className="flex items-center gap-4">
                <span className="text-xs font-black uppercase tracking-widest text-cream/40">Level</span>
                <input 
                  type="number" 
                  min="1"
                  max="50"
                  value={lesson.level}
                  onChange={e => setLesson(prev => ({ ...prev, level: parseInt(e.target.value) }))}
                  className="w-20 bg-white/5 border border-white/10 rounded-xl px-4 py-2 text-cream outline-none"
                />
              </div>
            </section>

            <section className="bg-white/5 border border-white/10 rounded-[2rem] p-6 space-y-4">
              <div className="flex items-center justify-between">
                <h2 className="text-xs font-black uppercase tracking-widest text-primary/60">Lesson Steps</h2>
                <span className="text-[10px] font-mono text-cream/20">{lesson.steps?.length || 0} Steps</span>
              </div>
              <div className="space-y-2 max-h-[400px] overflow-y-auto pr-2 custom-scrollbar">
                {lesson.steps?.map((step, i) => (
                  <div 
                    key={step.id}
                    onClick={() => setActiveStep(i)}
                    className={`group flex items-center gap-3 p-3 rounded-xl border transition-all cursor-pointer ${activeStep === i ? 'bg-primary/10 border-primary/30' : 'bg-white/5 border-white/10 hover:bg-white/10'}`}
                  >
                    <div className="w-8 h-8 bg-white/5 rounded-lg flex items-center justify-center text-xs font-bold text-cream/40">
                      {i + 1}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="text-sm font-bold text-cream truncate">{step.title}</div>
                      <div className="text-[10px] uppercase tracking-widest text-cream/20">{step.type.replace('_', ' ')}</div>
                    </div>
                    <button 
                      onClick={(e) => { e.stopPropagation(); removeStep(i); }}
                      className="opacity-0 group-hover:opacity-100 p-2 hover:text-terracotta transition-all"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                ))}
              </div>
              <div className="pt-4 border-t border-white/5">
                <h3 className="text-[10px] font-black uppercase tracking-widest text-cream/20 mb-3">Add New Step</h3>
                <div className="grid grid-cols-2 gap-2">
                  {STEP_TYPES.map(st => (
                    <button 
                      key={st.type}
                      onClick={() => addStep(st.type)}
                      className="flex flex-col items-center gap-1 p-2 bg-white/5 border border-white/10 rounded-xl hover:bg-primary/10 hover:border-primary/30 transition-all group"
                    >
                      <st.icon className="w-4 h-4 text-cream/40 group-hover:text-primary" />
                      <span className="text-[8px] font-black uppercase tracking-widest text-cream/40 group-hover:text-primary">{st.label}</span>
                    </button>
                  ))}
                </div>
              </div>
            </section>
          </div>

          {/* Main Content: Step Editor */}
          <div className="lg:col-span-2 space-y-6">
            <AnimatePresence mode="wait">
              {activeStep !== null ? (
                <motion.div 
                  key={activeStep}
                  initial={{ opacity: 0, x: 20 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: -20 }}
                  className="bg-white/5 border border-white/10 rounded-[3rem] p-8 space-y-8"
                >
                  <div className="flex items-center justify-between border-b border-white/5 pb-6">
                    <div className="flex items-center gap-4">
                      <div className="w-12 h-12 bg-primary/10 rounded-2xl flex items-center justify-center">
                        {React.createElement(STEP_TYPES.find(s => s.type === lesson.steps![activeStep].type)?.icon || Layout, { className: "w-6 h-6 text-primary" })}
                      </div>
                      <div>
                        <input 
                          type="text" 
                          value={lesson.steps![activeStep].title}
                          onChange={e => updateStep(activeStep, { title: e.target.value })}
                          className="bg-transparent text-2xl font-headline font-bold text-cream outline-none focus:text-primary transition-colors"
                        />
                        <p className="text-xs text-cream/40">{STEP_TYPES.find(s => s.type === lesson.steps![activeStep].type)?.description}</p>
                      </div>
                    </div>
                  </div>

                  {/* Dynamic Step Content Editor */}
                  <div className="space-y-6">
                    {lesson.steps![activeStep].type === 'sentence_building' && (
                      <div className="space-y-4">
                        <div className="flex items-center justify-between">
                          <label className="text-xs font-black uppercase tracking-widest text-primary/60">Target Sentences</label>
                          <button 
                            onClick={() => {
                              const newContent = [...lesson.steps![activeStep].content, { sentence: '', words: [] }];
                              updateStep(activeStep, { content: newContent });
                            }}
                            className="text-[10px] font-black uppercase tracking-widest text-primary hover:underline"
                          >
                            + Add Sentence
                          </button>
                        </div>
                        <div className="space-y-4">
                          {lesson.steps![activeStep].content.map((item: any, idx: number) => (
                            <div key={idx} className="space-y-3 p-4 bg-white/5 rounded-2xl border border-white/10">
                              <div className="flex gap-2">
                                <input 
                                  type="text" 
                                  placeholder="e.g., Magandang umaga sa inyong lahat"
                                  value={item.sentence}
                                  onChange={e => {
                                    const sentence = e.target.value;
                                    const words = sentence.split(' ').filter(w => w.length > 0);
                                    const newContent = [...lesson.steps![activeStep].content];
                                    newContent[idx] = { sentence, words };
                                    updateStep(activeStep, { content: newContent });
                                  }}
                                  className="flex-1 bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-cream outline-none focus:border-primary/30"
                                />
                                <button 
                                  onClick={() => {
                                    const newContent = lesson.steps![activeStep].content.filter((_: any, i: number) => i !== idx);
                                    updateStep(activeStep, { content: newContent });
                                  }}
                                  className="text-terracotta/40 hover:text-terracotta"
                                >
                                  <Trash2 className="w-4 h-4" />
                                </button>
                              </div>
                              <div className="flex flex-wrap gap-2">
                                {item.words.map((word: string, wIdx: number) => (
                                  <div key={wIdx} className="px-3 py-1 bg-primary/10 border border-primary/30 rounded-lg text-xs font-bold text-primary">
                                    {word}
                                  </div>
                                ))}
                              </div>
                            </div>
                          ))}
                        </div>
                      </div>
                    )}

                    {lesson.steps![activeStep].type === 'vocab_drill' && (
                      <div className="space-y-4">
                        <div className="flex items-center justify-between">
                          <label className="text-xs font-black uppercase tracking-widest text-primary/60">Vocabulary List</label>
                          <button 
                            onClick={() => {
                              const newContent = [...lesson.steps![activeStep].content, { word: '', meaning: '', context: '' }];
                              updateStep(activeStep, { content: newContent });
                            }}
                            className="text-[10px] font-black uppercase tracking-widest text-primary hover:underline"
                          >
                            + Add Word
                          </button>
                        </div>
                        <div className="space-y-3">
                          {lesson.steps![activeStep].content.map((item: any, idx: number) => (
                            <div key={idx} className="grid grid-cols-3 gap-3 p-4 bg-white/5 rounded-2xl border border-white/10">
                              <input 
                                type="text" 
                                placeholder="Word"
                                value={item.word}
                                onChange={e => {
                                  const newContent = [...lesson.steps![activeStep].content];
                                  newContent[idx].word = e.target.value;
                                  updateStep(activeStep, { content: newContent });
                                }}
                                className="bg-white/5 border border-white/10 rounded-lg px-3 py-2 text-sm text-cream outline-none"
                              />
                              <input 
                                type="text" 
                                placeholder="Meaning"
                                value={item.meaning}
                                onChange={e => {
                                  const newContent = [...lesson.steps![activeStep].content];
                                  newContent[idx].meaning = e.target.value;
                                  updateStep(activeStep, { content: newContent });
                                }}
                                className="bg-white/5 border border-white/10 rounded-lg px-3 py-2 text-sm text-cream outline-none"
                              />
                              <div className="flex gap-2">
                                <input 
                                  type="text" 
                                  placeholder="Context"
                                  value={item.context}
                                  onChange={e => {
                                    const newContent = [...lesson.steps![activeStep].content];
                                    newContent[idx].context = e.target.value;
                                    updateStep(activeStep, { content: newContent });
                                  }}
                                  className="flex-1 bg-white/5 border border-white/10 rounded-lg px-3 py-2 text-sm text-cream outline-none"
                                />
                                <button 
                                  onClick={() => {
                                    const newContent = lesson.steps![activeStep].content.filter((_: any, i: number) => i !== idx);
                                    updateStep(activeStep, { content: newContent });
                                  }}
                                  className="text-terracotta/40 hover:text-terracotta"
                                >
                                  <Trash2 className="w-4 h-4" />
                                </button>
                              </div>
                            </div>
                          ))}
                        </div>
                      </div>
                    )}

                    {/* Add more editors for other types as needed */}
                    <div className="p-12 border-2 border-dashed border-white/10 rounded-[2rem] flex flex-col items-center justify-center text-center space-y-4">
                      <div className="w-12 h-12 bg-white/5 rounded-full flex items-center justify-center">
                        <Plus className="w-6 h-6 text-cream/20" />
                      </div>
                      <p className="text-sm text-cream/40">More advanced editors for {lesson.steps![activeStep].type} coming soon.</p>
                    </div>
                  </div>
                </motion.div>
              ) : (
                <div className="h-full flex flex-col items-center justify-center text-center space-y-6 p-12 bg-white/5 border border-white/10 rounded-[3rem]">
                  <div className="w-24 h-24 bg-primary/10 rounded-[2.5rem] flex items-center justify-center gold-shadow">
                    <BookOpen className="w-12 h-12 text-primary" />
                  </div>
                  <div>
                    <h3 className="text-2xl font-headline font-bold text-cream">Select a Step to Edit</h3>
                    <p className="text-cream/40 max-w-xs mx-auto">Choose a step from the sidebar or add a new one to start weaving your lesson.</p>
                  </div>
                </div>
              )}
            </AnimatePresence>
          </div>
        </div>
      </div>
    </div>
  );
};

export default LessonCreator;

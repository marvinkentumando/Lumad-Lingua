import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  BookOpen, 
  Plus, 
  Search, 
  MoreVertical, 
  Edit2, 
  Trash2, 
  Globe, 
  Clock, 
  CheckCircle2,
  X
} from 'lucide-react';
import { useFirebase } from '../../Contexts/FirebaseContext';
import { collection, query, where, orderBy, onSnapshot } from 'firebase/firestore';
import { db } from '../../firebase';
import AppLayout from '../../Layouts/AppLayout';
import { motion, AnimatePresence } from 'framer-motion';

interface Lesson {
  id: string;
  title: string;
  description: string;
  dialect: string;
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  status: 'draft' | 'published';
  createdAt: any;
  wordCount: number;
}

const EducatorDashboard: React.FC = () => {
  const { profile, user } = useFirebase();
  const navigate = useNavigate();
  const [lessons, setLessons] = useState<Lesson[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [filter, setFilter] = useState<'all' | 'published' | 'draft'>('all');

  useEffect(() => {
    document.title = "Educator Dashboard - Lumad Lingua";
  }, []);

  useEffect(() => {
    if (!user) return;
    
    const q = query(
      collection(db, 'lessons'),
      where('educatorId', '==', user.uid),
      orderBy('createdAt', 'desc')
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const fetchedLessons = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        wordCount: doc.data().wordIds?.length || 0
      })) as Lesson[];
      setLessons(fetchedLessons);
      setLoading(false);
    }, (error) => {
      console.error('Error fetching lessons:', error);
      setLoading(false);
    });

    return () => unsubscribe();
  }, [user]);

  const [isCreating, setIsCreating] = useState(false);
  const [newLesson, setNewLesson] = useState({
    title: '',
    description: '',
    dialect: '',
    difficulty: 'beginner' as const,
    status: 'draft' as const
  });

  const handleCreateLesson = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) return;
    try {
      const { Timestamp } = await import('firebase/firestore');
      const { addDoc, collection } = await import('firebase/firestore');
      await addDoc(collection(db, 'lessons'), {
        ...newLesson,
        educatorId: user.uid,
        createdAt: Timestamp.now(),
        wordIds: []
      });
      setIsCreating(false);
      setNewLesson({ title: '', description: '', dialect: '', difficulty: 'beginner', status: 'draft' });
    } catch (error) {
      console.error('Error creating lesson:', error);
    }
  };

  const filteredLessons = lessons.filter(lesson => {
    const matchesSearch = lesson.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         lesson.dialect.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesFilter = filter === 'all' || lesson.status === filter;
    return matchesSearch && matchesFilter;
  });

  return (
    <AppLayout
      activeScreen="educator"
      setActiveScreen={(screen) => navigate(`/${screen}`)}
      userRole={profile?.role || 'learner'}
      onSearch={setSearchQuery}
      searchQuery={searchQuery}
      xp={profile?.xp || 0}
      streak={profile?.streak || 0}
      level={profile?.level || 1}
    >
      <div className="space-y-8 pb-24">
        <AnimatePresence>
          {isCreating && (
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 bg-forest/90 backdrop-blur-md z-[100] flex items-center justify-center p-4"
            >
              <motion.div 
                initial={{ scale: 0.9, y: 20 }}
                animate={{ scale: 1, y: 0 }}
                exit={{ scale: 0.9, y: 20 }}
                className="bg-surface-low border border-white/10 rounded-[3rem] p-8 md:p-12 max-w-2xl w-full relative"
              >
                <button 
                  onClick={() => setIsCreating(false)}
                  className="absolute top-8 right-8 text-cream/40 hover:text-primary transition-colors"
                >
                  <X className="w-6 h-6" />
                </button>
                <h3 className="text-3xl font-bold text-cream mb-8">Create New Lesson</h3>
                <form onSubmit={handleCreateLesson} className="space-y-6">
                  <div className="space-y-2">
                    <label className="text-[10px] font-black uppercase tracking-widest text-cream/40">Lesson Title</label>
                    <input 
                      required
                      value={newLesson.title}
                      onChange={e => setNewLesson({...newLesson, title: e.target.value})}
                      className="w-full bg-white/5 border border-white/10 rounded-xl p-4 text-cream focus:border-primary outline-none transition-all"
                      placeholder="e.g. Greetings & Basic Phrases"
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-[10px] font-black uppercase tracking-widest text-cream/40">Description</label>
                    <textarea 
                      required
                      value={newLesson.description}
                      onChange={e => setNewLesson({...newLesson, description: e.target.value})}
                      className="w-full bg-white/5 border border-white/10 rounded-xl p-4 text-cream focus:border-primary outline-none transition-all h-24 resize-none"
                      placeholder="What will students learn?"
                    />
                  </div>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div className="space-y-2">
                      <label className="text-[10px] font-black uppercase tracking-widest text-cream/40">Dialect / Language</label>
                      <select 
                        required
                        value={newLesson.dialect}
                        onChange={e => setNewLesson({...newLesson, dialect: e.target.value})}
                        className="w-full bg-white/5 border border-white/10 rounded-xl p-4 text-cream focus:border-primary outline-none transition-all appearance-none"
                      >
                        <option value="" disabled className="bg-surface-low">Select Dialect</option>
                        <option value="Mansaka" className="bg-surface-low">Mansaka</option>
                        <option value="Mandaya" className="bg-surface-low">Mandaya</option>
                        <option value="Kagan" className="bg-surface-low">Kagan</option>
                        <option value="B'laan" className="bg-surface-low">B'laan</option>
                        <option value="T'boli" className="bg-surface-low">T'boli</option>
                      </select>
                    </div>
                    <div className="space-y-2">
                      <label className="text-[10px] font-black uppercase tracking-widest text-cream/40">Difficulty</label>
                      <select 
                        required
                        value={newLesson.difficulty}
                        onChange={e => setNewLesson({...newLesson, difficulty: e.target.value as any})}
                        className="w-full bg-white/5 border border-white/10 rounded-xl p-4 text-cream focus:border-primary outline-none transition-all appearance-none"
                      >
                        <option value="beginner" className="bg-surface-low">Beginner</option>
                        <option value="intermediate" className="bg-surface-low">Intermediate</option>
                        <option value="advanced" className="bg-surface-low">Advanced</option>
                      </select>
                    </div>
                  </div>
                  <button 
                    type="submit"
                    className="w-full bg-primary text-forest py-5 rounded-2xl font-black uppercase tracking-widest gold-shadow hover:-translate-y-1 transition-all flex items-center justify-center gap-3"
                  >
                    <Plus className="w-5 h-5" />
                    Create Lesson
                  </button>
                </form>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>

        {/* Hero Section */}
        <section className="relative overflow-hidden rounded-[2.5rem] bg-surface-low border border-white/10 p-8 md:p-12">
          <div className="relative z-10 space-y-4">
            <div className="inline-flex items-center bg-primary/20 text-primary px-4 py-1.5 rounded-full text-[10px] font-black uppercase tracking-widest">
              Educator Portal
            </div>
            <h1 className="text-4xl md:text-5xl font-headline font-bold text-cream leading-tight">
              Shape the <br /> <span className="text-primary">Learning Journey</span>
            </h1>
            <p className="text-cream/60 max-w-md text-sm leading-relaxed">
              Create structured lessons, interactive quizzes, and preserve ancestral knowledge through modern pedagogy.
            </p>
            <button 
              onClick={() => navigate('/educator/lesson/new')}
              className="flex items-center gap-2 bg-primary text-forest px-6 py-3 rounded-2xl font-black uppercase tracking-widest text-xs gold-shadow hover:scale-105 transition-transform active:scale-95"
            >
              <Plus className="w-4 h-4" /> Create New Lesson
            </button>
          </div>
          
          {/* Decorative Elements */}
          <div className="absolute top-0 right-0 w-1/2 h-full opacity-10 pointer-events-none">
            <div className="absolute inset-0 bg-gradient-to-l from-primary/20 to-transparent" />
            <BookOpen className="absolute top-1/2 right-12 w-64 h-64 -translate-y-1/2 rotate-12" />
          </div>
        </section>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {[
            { label: 'Total Lessons', value: lessons.length, icon: BookOpen, color: 'text-primary' },
            { label: 'Published', value: lessons.filter(l => l.status === 'published').length, icon: Globe, color: 'text-green-400' },
            { label: 'Drafts', value: lessons.filter(l => l.status === 'draft').length, icon: Edit2, color: 'text-yellow-400' },
          ].map((stat, i) => (
            <div key={i} className="bg-surface-low border border-white/10 p-6 rounded-3xl flex items-center justify-between">
              <div>
                <p className="text-[10px] font-black uppercase tracking-widest text-cream/40">{stat.label}</p>
                <p className="text-3xl font-headline font-bold text-cream mt-1">{stat.value}</p>
              </div>
              <div className={`p-3 rounded-2xl bg-white/5 ${stat.color}`}>
                <stat.icon className="w-6 h-6" />
              </div>
            </div>
          ))}
        </div>

        {/* Lessons Table/List */}
        <div className="bg-surface-low border border-white/10 rounded-[2.5rem] overflow-hidden">
          <div className="p-6 border-b border-white/10 flex flex-col md:flex-row md:items-center justify-between gap-4">
            <h2 className="text-xl font-bold text-cream">Your Lessons</h2>
            
            <div className="flex items-center gap-2">
              <div className="flex bg-white/5 p-1 rounded-xl border border-white/10">
                {(['all', 'published', 'draft'] as const).map((f) => (
                  <button
                    key={f}
                    onClick={() => setFilter(f)}
                    className={`px-3 py-1.5 rounded-lg text-[10px] font-black uppercase tracking-widest transition-all ${
                      filter === f ? 'bg-primary text-forest' : 'text-cream/40 hover:text-cream'
                    }`}
                  >
                    {f}
                  </button>
                ))}
              </div>
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="border-b border-white/5">
                  <th className="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-cream/40">Lesson Title</th>
                  <th className="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-cream/40">Dialect</th>
                  <th className="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-cream/40">Difficulty</th>
                  <th className="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-cream/40">Status</th>
                  <th className="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-cream/40">Words</th>
                  <th className="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-cream/40 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-white/5">
                {loading ? (
                  <tr>
                    <td colSpan={6} className="px-6 py-12 text-center text-cream/40 italic">Loading lessons...</td>
                  </tr>
                ) : filteredLessons.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="px-6 py-12 text-center text-cream/40 italic">No lessons found.</td>
                  </tr>
                ) : (
                  filteredLessons.map((lesson) => (
                    <tr key={lesson.id} className="hover:bg-white/5 transition-colors group">
                      <td className="px-6 py-4">
                        <div className="font-bold text-cream">{lesson.title}</div>
                        <div className="text-xs text-cream/40 line-clamp-1">{lesson.description}</div>
                      </td>
                      <td className="px-6 py-4">
                        <span className="text-xs text-cream/60">{lesson.dialect}</span>
                      </td>
                      <td className="px-6 py-4">
                        <span className={`text-[10px] font-black uppercase tracking-widest px-2 py-1 rounded-md ${
                          lesson.difficulty === 'beginner' ? 'bg-green-500/20 text-green-400' :
                          lesson.difficulty === 'intermediate' ? 'bg-yellow-500/20 text-yellow-400' :
                          'bg-red-500/20 text-red-400'
                        }`}>
                          {lesson.difficulty}
                        </span>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-2">
                          {lesson.status === 'published' ? (
                            <CheckCircle2 className="w-3 h-3 text-green-400" />
                          ) : (
                            <Clock className="w-3 h-3 text-yellow-400" />
                          )}
                          <span className={`text-xs ${lesson.status === 'published' ? 'text-green-400' : 'text-yellow-400'}`}>
                            {lesson.status}
                          </span>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <span className="text-xs text-cream/60">{lesson.wordCount} words</span>
                      </td>
                      <td className="px-6 py-4 text-right">
                        <div className="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                          <button 
                            onClick={() => navigate(`/educator/lesson/edit/${lesson.id}`)}
                            className="p-2 hover:bg-white/10 rounded-lg text-cream/60 hover:text-primary transition-colors"
                          >
                            <Edit2 className="w-4 h-4" />
                          </button>
                          <button className="p-2 hover:bg-white/10 rounded-lg text-cream/60 hover:text-red-400 transition-colors">
                            <Trash2 className="w-4 h-4" />
                          </button>
                          <button className="p-2 hover:bg-white/10 rounded-lg text-cream/60 hover:text-cream transition-colors">
                            <MoreVertical className="w-4 h-4" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </AppLayout>
  );
};

export default EducatorDashboard;

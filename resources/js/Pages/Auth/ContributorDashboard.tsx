import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Users, 
  Globe, 
  Clock, 
  ChevronRight, 
  PlusCircle, 
  BookOpen, 
  Volume2, 
  MapPin, 
  Sparkles, 
  Hash,
  X,
  Send
} from 'lucide-react';
import { collection, addDoc, query, where, onSnapshot, Timestamp } from 'firebase/firestore';
import { db, handleFirestoreError, OperationType } from '../../firebase';
import { useFirebase } from '../../Contexts/FirebaseContext';

const ContributorDashboard: React.FC = () => {
  const { user } = useFirebase();
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submissions, setSubmissions] = useState<any[]>([]);
  const [newWord, setNewWord] = useState({
    term: '',
    pos: '',
    tag: '',
    category: '',
    filipino: '',
    english: '',
    definition: '',
    example: '',
    exampleTranslation: '',
    location: '',
    related: ''
  });

  useEffect(() => {
    if (!user) return;
    const q = query(collection(db, 'words'), where('contributorId', '==', user.uid));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      setSubmissions(snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })));
    }, (err) => handleFirestoreError(err, OperationType.LIST, 'words'));
    return () => unsubscribe();
  }, [user]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) return;
    try {
      await addDoc(collection(db, 'words'), {
        ...newWord,
        related: newWord.related.split(',').map(s => s.trim()).filter(Boolean),
        contributorId: user.uid,
        status: 'pending',
        createdAt: Timestamp.now()
      });
      setNewWord({ 
        term: '', pos: '', tag: '', category: '', filipino: '', english: '', 
        definition: '', example: '', exampleTranslation: '', location: '', related: '' 
      });
      setIsSubmitting(false);
    } catch (err) {
      handleFirestoreError(err, OperationType.CREATE, 'words');
    }
  };

  const stats = [
    { label: 'My Contributions', val: submissions.length, sub: 'Total submissions', icon: Globe, color: 'text-primary', bg: 'bg-primary/10' },
    { label: 'Validated', val: submissions.filter(s => s.status === 'validated').length, sub: 'Verified echoes', icon: BookOpen, color: 'text-green-500', bg: 'bg-green-500/10' },
    { label: 'Pending', val: submissions.filter(s => s.status === 'pending').length, sub: 'Awaiting review', icon: Clock, color: 'text-blue-400', bg: 'bg-blue-400/10' },
  ];

  return (
    <motion.div 
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      className="space-y-12 pb-32 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8"
    >
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-6 mb-4">
        <div className="flex items-center gap-4">
          <div className="w-12 h-12 bg-primary/10 rounded-2xl flex items-center justify-center text-primary gold-shadow">
            <Users className="w-6 h-6" />
          </div>
          <div>
            <h2 className="text-3xl font-bold text-primary leading-tight">Loom Dashboard</h2>
            <p className="text-cream/40 text-sm font-medium">Weave new echoes into the canopy</p>
          </div>
        </div>
        <button 
          onClick={() => setIsSubmitting(true)}
          className="w-full sm:w-auto bg-primary text-forest px-8 py-4 rounded-2xl font-black uppercase tracking-widest gold-shadow hover:-translate-y-1 transition-all flex items-center justify-center gap-3 min-h-[44px]"
        >
          <PlusCircle className="w-5 h-5" />
          New Submission
        </button>
      </div>

      <AnimatePresence>
        {isSubmitting && (
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
                onClick={() => setIsSubmitting(false)}
                className="absolute top-8 right-8 text-cream/40 hover:text-primary transition-colors"
              >
                <X className="w-6 h-6" />
              </button>
              <h3 className="text-3xl font-bold text-cream mb-8">Contribute an Echo</h3>
              <form onSubmit={handleSubmit} className="space-y-6 max-h-[70vh] overflow-y-auto pr-2">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="space-y-2">
                    <label className="text-[10px] font-black uppercase tracking-widest text-cream/40">Term / Phrase</label>
                    <input 
                      required
                      value={newWord.term}
                      onChange={e => setNewWord({...newWord, term: e.target.value})}
                      className="w-full bg-white/5 border border-white/10 rounded-xl p-4 text-cream focus:border-primary outline-none transition-all"
                      placeholder="e.g. Kalumanan"
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-[10px] font-black uppercase tracking-widest text-cream/40">Part of Speech</label>
                    <input 
                      required
                      value={newWord.pos}
                      onChange={e => setNewWord({...newWord, pos: e.target.value})}
                      className="w-full bg-white/5 border border-white/10 rounded-xl p-4 text-cream focus:border-primary outline-none transition-all"
                      placeholder="e.g. noun"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="space-y-2">
                    <label className="text-[10px] font-black uppercase tracking-widest text-cream/40">Tag</label>
                    <input 
                      required
                      value={newWord.tag}
                      onChange={e => setNewWord({...newWord, tag: e.target.value})}
                      className="w-full bg-white/5 border border-white/10 rounded-xl p-4 text-cream focus:border-primary outline-none transition-all"
                      placeholder="e.g. Heritage"
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-[10px] font-black uppercase tracking-widest text-cream/40">Category</label>
                    <input 
                      required
                      value={newWord.category}
                      onChange={e => setNewWord({...newWord, category: e.target.value})}
                      className="w-full bg-white/5 border border-white/10 rounded-xl p-4 text-cream focus:border-primary outline-none transition-all"
                      placeholder="e.g. Culture"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="space-y-2">
                    <label className="text-[10px] font-black uppercase tracking-widest text-cream/40">Filipino Translation</label>
                    <input 
                      required
                      value={newWord.filipino}
                      onChange={e => setNewWord({...newWord, filipino: e.target.value})}
                      className="w-full bg-white/5 border border-white/10 rounded-xl p-4 text-cream focus:border-primary outline-none transition-all"
                      placeholder="e.g. Pamana"
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-[10px] font-black uppercase tracking-widest text-cream/40">English Translation</label>
                    <input 
                      required
                      value={newWord.english}
                      onChange={e => setNewWord({...newWord, english: e.target.value})}
                      className="w-full bg-white/5 border border-white/10 rounded-xl p-4 text-cream focus:border-primary outline-none transition-all"
                      placeholder="e.g. Heritage / Ancestry"
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <label className="text-[10px] font-black uppercase tracking-widest text-cream/40">Definition</label>
                  <textarea 
                    required
                    value={newWord.definition}
                    onChange={e => setNewWord({...newWord, definition: e.target.value})}
                    className="w-full bg-white/5 border border-white/10 rounded-xl p-4 text-cream focus:border-primary outline-none transition-all h-24 resize-none"
                    placeholder="Full definition..."
                  />
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="space-y-2">
                    <label className="text-[10px] font-black uppercase tracking-widest text-cream/40">Example Usage</label>
                    <textarea 
                      value={newWord.example}
                      onChange={e => setNewWord({...newWord, example: e.target.value})}
                      className="w-full bg-white/5 border border-white/10 rounded-xl p-4 text-cream focus:border-primary outline-none transition-all h-24 resize-none"
                      placeholder="Use it in a sentence..."
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-[10px] font-black uppercase tracking-widest text-cream/40">Example Translation</label>
                    <textarea 
                      value={newWord.exampleTranslation}
                      onChange={e => setNewWord({...newWord, exampleTranslation: e.target.value})}
                      className="w-full bg-white/5 border border-white/10 rounded-xl p-4 text-cream focus:border-primary outline-none transition-all h-24 resize-none"
                      placeholder="Translation of the example..."
                    />
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="space-y-2">
                    <label className="text-[10px] font-black uppercase tracking-widest text-cream/40">Location / Community</label>
                    <input 
                      required
                      value={newWord.location}
                      onChange={e => setNewWord({...newWord, location: e.target.value})}
                      className="w-full bg-white/5 border border-white/10 rounded-xl p-4 text-cream focus:border-primary outline-none transition-all"
                      placeholder="e.g. Davao del Norte"
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-[10px] font-black uppercase tracking-widest text-cream/40">Related Words (comma separated)</label>
                    <input 
                      value={newWord.related}
                      onChange={e => setNewWord({...newWord, related: e.target.value})}
                      className="w-full bg-white/5 border border-white/10 rounded-xl p-4 text-cream focus:border-primary outline-none transition-all"
                      placeholder="e.g. Kabilin, Lumad"
                    />
                  </div>
                </div>

                <button 
                  type="submit"
                  className="w-full bg-primary text-forest py-5 rounded-2xl font-black uppercase tracking-widest gold-shadow hover:-translate-y-1 transition-all flex items-center justify-center gap-3"
                >
                  <Send className="w-5 h-5" />
                  Submit for Validation
                </button>
              </form>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {stats.map((stat, i) => (
          <div key={i} className="bg-white/5 border border-white/10 rounded-[2.5rem] p-8 relative overflow-hidden group hover:bg-white/10 transition-all min-h-[44px]">
            <div className={`absolute -bottom-6 -right-6 w-24 h-24 ${stat.bg} rounded-full blur-2xl group-hover:scale-150 transition-transform duration-700`}></div>
            <div className="relative z-10">
              <p className="text-[10px] font-black uppercase tracking-widest text-cream/40 mb-6">{stat.label}</p>
              <h3 className="text-4xl font-black text-cream mb-2 tracking-tight">{stat.val}</h3>
              <div className="flex items-center gap-2">
                <stat.icon className={`w-4 h-4 ${stat.color}`} />
                <span className="text-xs font-bold text-cream/60">{stat.sub}</span>
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        {/* Recent Submissions & Artifacts */}
        <div className="lg:col-span-8 space-y-8">
          <div className="bg-white/5 border border-white/10 rounded-[2.5rem] p-8 md:p-10">
            <div className="flex items-center justify-between mb-10">
              <h3 className="text-2xl font-bold text-cream">My Submissions</h3>
              <button className="text-primary text-xs font-black uppercase tracking-widest hover:underline min-h-[44px]">View All</button>
            </div>
            
            <div className="space-y-4">
              {submissions.slice(0, 5).map((sub) => (
                <div key={sub.id} className="flex items-center gap-6 p-6 bg-white/5 border border-white/10 rounded-2xl hover:bg-white/10 transition-all group min-h-[44px]">
                  <div className={`w-2 h-2 rounded-full ${
                    sub.status === 'validated' ? 'bg-green-500' : 
                    sub.status === 'rejected' ? 'bg-terracotta' : 'bg-primary'
                  }`}></div>
                  <div className="flex-1">
                    <div className="text-sm font-bold text-cream group-hover:text-primary transition-colors">{sub.term}</div>
                    <div className="text-[10px] text-cream/40 uppercase font-black tracking-widest mt-1">
                      {sub.definition} · {sub.createdAt?.toDate ? sub.createdAt.toDate().toLocaleDateString() : 'Just now'}
                    </div>
                  </div>
                  <div className={`text-[8px] font-black uppercase tracking-widest px-2 py-1 rounded border ${
                    sub.status === 'validated' ? 'border-green-500/30 text-green-500' : 
                    sub.status === 'rejected' ? 'border-terracotta/30 text-terracotta' : 'border-primary/30 text-primary'
                  }`}>
                    {sub.status}
                  </div>
                </div>
              ))}
              {submissions.length === 0 && (
                <div className="text-center py-12 text-cream/20 font-bold italic">No submissions yet. Start weaving!</div>
              )}
            </div>
          </div>

          {/* Artifacts & Badges Collection */}
          <div className="bg-white/5 border border-white/10 rounded-[2.5rem] p-8 md:p-10">
            <div className="flex items-center justify-between mb-10">
              <h3 className="text-2xl font-bold text-cream">Weaver's Collection</h3>
              <div className="flex items-center gap-2">
                <span className="text-[10px] font-black uppercase tracking-widest text-primary">12 / 24 Artifacts</span>
              </div>
            </div>
            
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 md:gap-6">
              {[
                { name: 'Golden Loom', icon: Globe, rarity: 'Epic', unlocked: true },
                { name: 'Sacred Thread', icon: Sparkles, rarity: 'Rare', unlocked: true },
                { name: 'Elder Voice', icon: Volume2, rarity: 'Common', unlocked: true },
                { name: 'Domain Map', icon: MapPin, rarity: 'Common', unlocked: true },
                { name: 'Spirit Needle', icon: Hash, rarity: 'Rare', unlocked: false },
                { name: 'Ancient Dye', icon: MapPin, rarity: 'Epic', unlocked: false },
              ].map((item, i) => (
                <div key={i} className={`relative aspect-square rounded-3xl border flex flex-col items-center justify-center gap-3 transition-all group ${
                  item.unlocked 
                    ? 'bg-white/5 border-white/10 hover:bg-white/10 hover:scale-105' 
                    : 'bg-black/20 border-white/5 opacity-40 grayscale'
                }`}>
                  <div className={`w-10 h-10 md:w-12 md:h-12 rounded-2xl flex items-center justify-center ${
                    item.rarity === 'Epic' ? 'bg-primary/20 text-primary' : 
                    item.rarity === 'Rare' ? 'bg-terracotta/20 text-terracotta' : 
                    'bg-blue-400/20 text-blue-400'
                  }`}>
                    <item.icon className="w-5 h-5 md:w-6 md:h-6" />
                  </div>
                  <div className="text-center px-2">
                    <div className="text-[9px] md:text-[10px] font-bold text-cream leading-tight truncate w-full">{item.name}</div>
                    <div className="text-[8px] font-black uppercase tracking-widest text-cream/20 mt-1">{item.rarity}</div>
                  </div>
                  {!item.unlocked && (
                    <div className="absolute inset-0 flex items-center justify-center">
                      <div className="bg-forest/80 backdrop-blur-sm p-2 rounded-full">
                        <Clock className="w-4 h-4 text-cream/40" />
                      </div>
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Contribution Tips */}
        <div className="lg:col-span-4 space-y-8">
          <div className="bg-white/5 border border-white/10 rounded-[2.5rem] p-8 md:p-10 space-y-8">
            <h3 className="text-xl font-bold text-cream">Contribution Tips</h3>
            <div className="space-y-6">
              {[
                { icon: Volume2, label: 'Audio Quality', desc: 'Ensure recordings are clear and free of background noise.' },
                { icon: MapPin, label: 'Location Accuracy', desc: 'Tag the specific community where the dialect is spoken.' },
                { icon: BookOpen, label: 'Contextual Usage', desc: 'Provide examples of how the word is used in daily life.' },
              ].map((tip, i) => (
                <div key={i} className="flex items-start gap-4">
                  <div className="w-8 h-8 bg-primary/10 rounded-lg flex items-center justify-center text-primary flex-shrink-0">
                    <tip.icon className="w-4 h-4" />
                  </div>
                  <div>
                    <div className="text-sm font-bold text-cream">{tip.label}</div>
                    <p className="text-xs text-cream/40 leading-relaxed">{tip.desc}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </motion.div>
  );
};

export default ContributorDashboard;

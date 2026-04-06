import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  CheckCircle2, 
  Globe, 
  Clock, 
  ChevronRight, 
  AlertTriangle, 
  BookOpen, 
  Volume2, 
  MapPin,
  X,
  Check,
  ThumbsDown
} from 'lucide-react';
import { collection, query, where, onSnapshot, doc, updateDoc, Timestamp } from 'firebase/firestore';
import { db, handleFirestoreError, OperationType } from '../../firebase';
import { useFirebase } from '../../Contexts/FirebaseContext';

const ValidatorDashboard: React.FC = () => {
  const { user } = useFirebase();
  const [pendingWords, setPendingWords] = useState<any[]>([]);
  const [validatedCount, setValidatedCount] = useState(0);
  const [rejectedCount, setRejectedCount] = useState(0);
  const [selectedWord, setSelectedWord] = useState<any | null>(null);

  useEffect(() => {
    const q = query(collection(db, 'words'), where('status', '==', 'pending'));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      setPendingWords(snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })));
    }, (err) => handleFirestoreError(err, OperationType.LIST, 'words'));

    // Also fetch stats (simplified)
    const qAll = query(collection(db, 'words'));
    const unsubscribeStats = onSnapshot(qAll, (snapshot) => {
      const docs = snapshot.docs.map(d => d.data());
      setValidatedCount(docs.filter(d => d.status === 'validated').length);
      setRejectedCount(docs.filter(d => d.status === 'rejected').length);
    });

    return () => {
      unsubscribe();
      unsubscribeStats();
    };
  }, []);

  const handleReview = async (status: 'validated' | 'rejected') => {
    if (!selectedWord || !user) return;
    const wordDocRef = doc(db, 'words', selectedWord.id);
    try {
      await updateDoc(wordDocRef, {
        status,
        validatorId: user.uid,
        validatedAt: Timestamp.now()
      });
      setSelectedWord(null);
    } catch (err) {
      handleFirestoreError(err, OperationType.UPDATE, `words/${selectedWord.id}`);
    }
  };

  const stats = [
    { label: 'Pending Review', val: pendingWords.length, sub: 'Urgent attention', icon: Clock, color: 'text-primary', bg: 'bg-primary/10' },
    { label: 'Validated', val: validatedCount, sub: 'Total echoes verified', icon: CheckCircle2, color: 'text-green-500', bg: 'bg-green-500/10' },
    { label: 'Rejected', val: rejectedCount, sub: 'Requires clarification', icon: AlertTriangle, color: 'text-terracotta', bg: 'bg-terracotta/10' },
  ];

  return (
    <motion.div 
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      className="space-y-12 pb-32 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8"
    >
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-4">
          <div className="w-12 h-12 bg-primary/10 rounded-2xl flex items-center justify-center text-primary gold-shadow">
            <CheckCircle2 className="w-6 h-6" />
          </div>
          <div>
            <h2 className="text-3xl font-bold text-primary leading-tight">Echo Dashboard</h2>
            <p className="text-cream/40 text-sm font-medium">Review and verify ancestral echoes</p>
          </div>
        </div>
        <div className="flex items-center gap-4">
          <button className="p-3 bg-white/5 rounded-2xl text-cream/40 hover:text-primary transition-colors border border-white/10">
            <Globe className="w-5 h-5" />
          </button>
          <div className="bg-terracotta text-white px-4 py-2 rounded-2xl text-xs font-black uppercase tracking-widest terracotta-shadow">Validator Mode</div>
        </div>
      </div>

      <AnimatePresence>
        {selectedWord && (
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
                onClick={() => setSelectedWord(null)}
                className="absolute top-8 right-8 text-cream/40 hover:text-primary transition-colors"
              >
                <X className="w-6 h-6" />
              </button>
              <h3 className="text-[10px] font-black uppercase tracking-widest text-primary mb-2">Reviewing Echo</h3>
              <h2 className="text-4xl font-headline font-bold text-cream mb-6">{selectedWord.term}</h2>
              
              <div className="space-y-6 mb-10 max-h-[60vh] overflow-y-auto pr-2">
                <div className="grid grid-cols-2 gap-8">
                  <div>
                    <div className="text-[10px] font-black uppercase tracking-widest text-cream/20 mb-1">Definition</div>
                    <div className="text-lg text-cream">{selectedWord.definition}</div>
                  </div>
                  <div>
                    <div className="text-[10px] font-black uppercase tracking-widest text-cream/20 mb-1">Part of Speech</div>
                    <div className="text-lg text-cream/60 italic">{selectedWord.pos || 'N/A'}</div>
                  </div>
                </div>
                <div className="grid grid-cols-2 gap-8">
                  <div>
                    <div className="text-[10px] font-black uppercase tracking-widest text-cream/20 mb-1">Filipino</div>
                    <div className="text-sm text-cream">{selectedWord.filipino}</div>
                  </div>
                  <div>
                    <div className="text-[10px] font-black uppercase tracking-widest text-cream/20 mb-1">English</div>
                    <div className="text-sm text-cream">{selectedWord.english}</div>
                  </div>
                </div>
                <div className="grid grid-cols-2 gap-8">
                  <div>
                    <div className="text-[10px] font-black uppercase tracking-widest text-cream/20 mb-1">Dialect / Language</div>
                    <div className="text-sm text-primary font-bold">{selectedWord.dialect || 'Lumad'}</div>
                  </div>
                  <div>
                    <div className="text-[10px] font-black uppercase tracking-widest text-cream/20 mb-1">Tag & Category</div>
                    <div className="text-sm text-cream">{selectedWord.tag} / {selectedWord.category}</div>
                  </div>
                </div>
                <div className="grid grid-cols-1 gap-8">
                  <div>
                    <div className="text-[10px] font-black uppercase tracking-widest text-cream/20 mb-1">Location / Community</div>
                    <div className="text-sm text-cream/60">{selectedWord.location || 'Unknown'}</div>
                  </div>
                </div>
                {selectedWord.example && (
                  <div className="p-6 bg-white/5 border-l-4 border-primary rounded-r-2xl">
                    <div className="text-[10px] font-black uppercase tracking-widest text-primary mb-2">Example Usage</div>
                    <div className="text-cream italic mb-2">"{selectedWord.example}"</div>
                    <div className="text-cream/60 text-sm">{selectedWord.exampleTranslation}</div>
                  </div>
                )}
                {selectedWord.related && selectedWord.related.length > 0 && (
                  <div>
                    <div className="text-[10px] font-black uppercase tracking-widest text-cream/20 mb-2">Related Words</div>
                    <div className="flex flex-wrap gap-2">
                      {selectedWord.related.map((rel: string, i: number) => (
                        <span key={i} className="bg-white/5 px-2 py-1 rounded text-xs text-cream/60">{rel}</span>
                      ))}
                    </div>
                  </div>
                )}
              </div>

              <div className="grid grid-cols-2 gap-4">
                <button 
                  onClick={() => handleReview('rejected')}
                  className="flex items-center justify-center gap-3 py-4 bg-terracotta/10 border border-terracotta/20 text-terracotta rounded-2xl font-black uppercase tracking-widest hover:bg-terracotta/20 transition-all"
                >
                  <ThumbsDown className="w-5 h-5" />
                  Reject
                </button>
                <button 
                  onClick={() => handleReview('validated')}
                  className="flex items-center justify-center gap-3 py-4 bg-green-500/10 border border-green-500/20 text-green-500 rounded-2xl font-black uppercase tracking-widest hover:bg-green-500/20 transition-all"
                >
                  <Check className="w-5 h-5" />
                  Validate
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {stats.map((stat, i) => (
          <div key={i} className="bg-white/5 border border-white/10 rounded-[2.5rem] p-8 relative overflow-hidden group hover:bg-white/10 transition-all">
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
        {/* Pending Submissions */}
        <div className="lg:col-span-8 bg-white/5 border border-white/10 rounded-[2.5rem] p-10">
          <div className="flex items-center justify-between mb-10">
            <h3 className="text-2xl font-bold text-cream">Pending Review</h3>
            <button className="text-primary text-xs font-black uppercase tracking-widest hover:underline">View All</button>
          </div>
          
          <div className="space-y-4">
            {pendingWords.map((sub) => (
              <div 
                key={sub.id} 
                onClick={() => setSelectedWord(sub)}
                className="flex items-center gap-6 p-6 bg-white/5 border border-white/10 rounded-2xl hover:bg-white/10 transition-all group cursor-pointer"
              >
                <div className="w-2 h-2 rounded-full bg-primary"></div>
                <div className="flex-1">
                  <div className="text-sm font-bold text-cream group-hover:text-primary transition-colors">{sub.term}</div>
                  <div className="text-[10px] text-cream/40 uppercase font-black tracking-widest mt-1">
                    {sub.definition} · {sub.createdAt?.toDate ? sub.createdAt.toDate().toLocaleDateString() : 'Just now'}
                  </div>
                </div>
                <ChevronRight className="w-4 h-4 text-cream/20 group-hover:text-primary group-hover:translate-x-1 transition-all" />
              </div>
            ))}
            {pendingWords.length === 0 && (
              <div className="text-center py-12 text-cream/20 font-bold italic">No pending echoes to review. Great job!</div>
            )}
          </div>
        </div>

        {/* Validation Guidelines */}
        <div className="lg:col-span-4 space-y-8">
          <div className="bg-white/5 border border-white/10 rounded-[2.5rem] p-10 space-y-8">
            <h3 className="text-xl font-bold text-cream">Validation Guidelines</h3>
            <div className="space-y-6">
              {[
                { icon: Volume2, label: 'Pronunciation', desc: 'Verify the audio matches the traditional pronunciation.' },
                { icon: MapPin, label: 'Dialect Context', desc: 'Confirm the word is specific to the tagged community.' },
                { icon: BookOpen, label: 'Definition Accuracy', desc: 'Ensure the meaning reflects the cultural context.' },
              ].map((guide, i) => (
                <div key={i} className="flex items-start gap-4">
                  <div className="w-8 h-8 bg-primary/10 rounded-lg flex items-center justify-center text-primary flex-shrink-0">
                    <guide.icon className="w-4 h-4" />
                  </div>
                  <div>
                    <div className="text-sm font-bold text-cream">{guide.label}</div>
                    <p className="text-xs text-cream/40 leading-relaxed">{guide.desc}</p>
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

export default ValidatorDashboard;

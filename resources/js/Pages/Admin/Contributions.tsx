import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Search, Filter, CheckCircle2, XCircle, Clock, MoreVertical, Globe, Volume2, MapPin, User, ArrowUpRight } from 'lucide-react';

const Contributions: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'pending' | 'validated' | 'rejected'>('pending');
  const [searchQuery, setSearchQuery] = useState('');

  const contributions = [
    { id: 1, term: 'Kalumanan', type: 'Word', community: 'Mansaka', user: 'Elder Weaver', time: '2h ago', status: 'pending', confidence: 98 },
    { id: 2, term: 'Dagmay', type: 'Phrase', community: 'Mandaya', user: 'Datu Marvin', time: '15m ago', status: 'pending', confidence: 85 },
    { id: 3, term: 'Lumad', type: 'Word', community: 'Kagan', user: 'Weaver_42', time: '1d ago', status: 'validated', confidence: 100 },
    { id: 4, term: 'Balay', type: 'Word', community: 'Mansaka', user: 'NewWeaver', time: '3h ago', status: 'rejected', confidence: 45 },
  ];

  const filtered = contributions.filter(c => {
    const matchesTab = c.status === activeTab;
    const matchesSearch = c.term.toLowerCase().includes(searchQuery.toLowerCase()) || 
                         c.user.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesTab && matchesSearch;
  });

  return (
    <motion.div 
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      className="space-y-10 pb-32"
    >
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-8">
        <div className="space-y-2">
          <div className="flex items-center gap-2 text-[10px] font-black uppercase tracking-widest text-primary/60">
            <Globe className="w-3 h-3" />
            <span>Ancestral Loom</span>
          </div>
          <h2 className="text-5xl font-headline font-bold text-cream tracking-tight">Contributions <em className="text-primary not-italic">Queue</em></h2>
          <p className="text-cream/40 font-medium">Review and weave ancestral echoes into the collective memory.</p>
        </div>

        <div className="flex gap-4">
          <div className="bg-white/5 border border-white/10 rounded-2xl p-4 flex items-center gap-4">
            <div className="text-right">
              <div className="text-xl font-black text-primary">42</div>
              <div className="text-[9px] font-black uppercase tracking-widest text-cream/20">Pending Review</div>
            </div>
            <div className="w-10 h-10 bg-primary/10 rounded-xl flex items-center justify-center text-primary">
              <Clock className="w-5 h-5" />
            </div>
          </div>
        </div>
      </div>

      <div className="flex flex-col md:flex-row gap-6">
        <div className="flex-1 relative group">
          <div className="absolute inset-y-0 left-5 flex items-center pointer-events-none">
            <Search className="w-5 h-5 text-cream/20 group-focus-within:text-primary transition-colors" />
          </div>
          <input 
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full bg-surface-low border border-white/10 rounded-2xl py-4 pl-14 pr-6 text-cream placeholder:text-cream/20 focus:border-primary/30 outline-none transition-all"
            placeholder="Search by term or weaver..."
          />
        </div>
        <div className="flex gap-2">
          {(['pending', 'validated', 'rejected'] as const).map(tab => (
            <button 
              key={tab}
              onClick={() => setActiveTab(tab)}
              className={`px-8 py-4 rounded-2xl font-black text-[10px] uppercase tracking-widest transition-all border ${
                activeTab === tab 
                  ? 'bg-primary border-primary text-forest gold-shadow' 
                  : 'bg-white/5 border-white/10 text-cream/40 hover:bg-white/10'
              }`}
            >
              {tab}
            </button>
          ))}
          <button className="p-4 bg-white/5 border border-white/10 rounded-2xl text-cream/40 hover:text-primary transition-all">
            <Filter className="w-5 h-5" />
          </button>
        </div>
      </div>

      <div className="bg-white/5 border border-white/10 rounded-[3rem] overflow-hidden">
        <table className="w-full text-left">
          <thead>
            <tr className="border-b border-white/10 bg-white/5">
              <th className="px-10 py-6 text-[10px] font-black uppercase tracking-[0.2em] text-cream/20">Ancestral Term</th>
              <th className="px-10 py-6 text-[10px] font-black uppercase tracking-[0.2em] text-cream/20">Community</th>
              <th className="px-10 py-6 text-[10px] font-black uppercase tracking-[0.2em] text-cream/20">Weaver</th>
              <th className="px-10 py-6 text-[10px] font-black uppercase tracking-[0.2em] text-cream/20">Confidence</th>
              <th className="px-10 py-6 text-[10px] font-black uppercase tracking-[0.2em] text-cream/20">Action</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-white/5">
            {filtered.map((c) => (
              <tr key={c.id} className="hover:bg-white/5 transition-colors group">
                <td className="px-10 py-8">
                  <div className="flex items-center gap-4">
                    <div className="w-10 h-10 bg-primary/10 rounded-xl flex items-center justify-center text-primary">
                      <Volume2 className="w-5 h-5" />
                    </div>
                    <div>
                      <div className="text-lg font-bold text-cream group-hover:text-primary transition-colors">{c.term}</div>
                      <div className="text-[10px] font-black uppercase tracking-widest text-cream/20">{c.type}</div>
                    </div>
                  </div>
                </td>
                <td className="px-10 py-8">
                  <div className="flex items-center gap-2 text-cream/60">
                    <MapPin className="w-3.5 h-3.5 text-primary/40" />
                    <span className="text-sm font-medium">{c.community}</span>
                  </div>
                </td>
                <td className="px-10 py-8">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-full bg-white/5 border border-white/10 flex items-center justify-center text-cream/20">
                      <User className="w-4 h-4" />
                    </div>
                    <div>
                      <div className="text-sm font-bold text-cream/80">{c.user}</div>
                      <div className="text-[9px] font-mono text-cream/20">{c.time}</div>
                    </div>
                  </div>
                </td>
                <td className="px-10 py-8">
                  <div className="flex items-center gap-3">
                    <div className="flex-1 h-1.5 bg-white/5 rounded-full overflow-hidden max-w-[100px]">
                      <div 
                        className={`h-full rounded-full ${c.confidence > 90 ? 'bg-green-500' : c.confidence > 70 ? 'bg-primary' : 'bg-terracotta'}`}
                        style={{ width: `${c.confidence}%` }}
                      ></div>
                    </div>
                    <span className="text-xs font-mono text-cream/40">{c.confidence}%</span>
                  </div>
                </td>
                <td className="px-10 py-8">
                  <div className="flex items-center gap-2">
                    {activeTab === 'pending' ? (
                      <>
                        <button className="p-3 bg-green-500/10 border border-green-500/20 rounded-xl text-green-500 hover:bg-green-500 hover:text-white transition-all">
                          <CheckCircle2 className="w-5 h-5" />
                        </button>
                        <button className="p-3 bg-terracotta/10 border border-terracotta/20 rounded-xl text-terracotta hover:bg-terracotta hover:text-white transition-all">
                          <XCircle className="w-5 h-5" />
                        </button>
                      </>
                    ) : (
                      <button className="p-3 bg-white/5 border border-white/10 rounded-xl text-cream/40 hover:text-primary transition-all">
                        <ArrowUpRight className="w-5 h-5" />
                      </button>
                    )}
                    <button className="p-3 text-cream/20 hover:text-cream/60 transition-colors">
                      <MoreVertical className="w-5 h-5" />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {filtered.length === 0 && (
          <div className="py-32 text-center space-y-4">
            <div className="text-6xl">🧶</div>
            <div className="text-cream/20 font-black uppercase tracking-widest text-sm">No echoes found in this section</div>
          </div>
        )}
      </div>
    </motion.div>
  );
};

export default Contributions;

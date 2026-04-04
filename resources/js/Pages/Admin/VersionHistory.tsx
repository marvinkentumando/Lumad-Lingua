import React from 'react';
import { motion } from 'framer-motion';
import { History, GitBranch, GitCommit, ChevronRight, Download, Share2, Shield, Globe, Clock } from 'lucide-react';

const VersionHistory: React.FC = () => {
  const versions = [
    { id: 1, version: 'v1.4.2', date: 'Oct 24, 2023', time: '14:20', user: 'Council Admin', action: 'Major Update', desc: 'Added 120 new Mansaka kinship terms and updated the ancestral map with 5 new sacred sites.', status: 'stable' },
    { id: 2, version: 'v1.4.1', date: 'Oct 20, 2023', time: '09:15', user: 'Datu Marvin', action: 'Patch', desc: 'Fixed pronunciation audio for "Kalumanan" and "Dagmay".', status: 'stable' },
    { id: 3, version: 'v1.4.0', date: 'Oct 15, 2023', time: '11:30', user: 'System', action: 'Minor Update', desc: 'Implemented the new "Ancestral Loom" contribution system.', status: 'stable' },
    { id: 4, version: 'v1.3.9', date: 'Oct 10, 2023', time: '16:45', user: 'Council Admin', action: 'Security Patch', desc: 'Enhanced encryption for ancestral data storage.', status: 'stable' },
  ];

  return (
    <motion.div 
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      className="space-y-12 pb-32"
    >
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-8">
        <div className="space-y-2">
          <div className="flex items-center gap-2 text-[10px] font-black uppercase tracking-widest text-primary/60">
            <History className="w-3 h-3" />
            <span>Ancestral Echoes</span>
          </div>
          <h2 className="text-5xl font-headline font-bold text-cream tracking-tight">Version <em className="text-primary not-italic">History</em></h2>
          <p className="text-cream/40 font-medium">Tracking the evolution of the collective memory.</p>
        </div>

        <div className="flex gap-4">
          <div className="bg-white/5 border border-white/10 rounded-2xl p-4 flex items-center gap-4">
            <div className="text-right">
              <div className="text-xl font-black text-primary">v1.4.2</div>
              <div className="text-[9px] font-black uppercase tracking-widest text-cream/20">Current Version</div>
            </div>
            <div className="w-10 h-10 bg-primary/10 rounded-xl flex items-center justify-center text-primary">
              <GitBranch className="w-5 h-5" />
            </div>
          </div>
        </div>
      </div>

      <div className="relative pl-10 space-y-12">
        <div className="absolute left-4.5 top-0 bottom-0 w-0.5 bg-gradient-to-b from-primary via-primary/30 to-transparent"></div>
        
        {versions.map((v, i) => (
          <div key={v.id} className="relative group">
            <div className="absolute -left-7.5 top-5 w-4 h-4 rounded-full border-2 bg-forest border-primary z-10 shadow-[0_0_12px_rgba(255,194,0,0.4)] group-hover:scale-125 transition-transform"></div>
            
            <div className="bg-white/5 border border-white/10 rounded-[2.5rem] p-10 hover:bg-white/10 transition-all gold-shadow relative overflow-hidden">
              <div className="absolute top-0 right-0 w-64 h-64 bg-primary/5 rounded-full -mr-32 -mt-32 blur-3xl group-hover:scale-110 transition-transform duration-1000"></div>
              
              <div className="relative z-10 flex flex-col md:flex-row gap-10">
                <div className="md:w-48 space-y-4">
                  <div className="text-3xl font-black text-primary tracking-tight">{v.version}</div>
                  <div className="space-y-1">
                    <div className="flex items-center gap-2 text-[10px] font-black uppercase tracking-widest text-cream/40">
                      <Clock className="w-3 h-3" />
                      <span>{v.date}</span>
                    </div>
                    <div className="text-[10px] font-mono text-cream/20">{v.time}</div>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="w-6 h-6 rounded-full bg-white/5 border border-white/10 flex items-center justify-center text-cream/20">
                      <GitCommit className="w-3 h-3" />
                    </div>
                    <span className="text-xs font-bold text-cream/60">{v.action}</span>
                  </div>
                </div>

                <div className="flex-1 space-y-6">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-full bg-primary/10 border border-primary/20 flex items-center justify-center text-primary">
                        <Globe className="w-4 h-4" />
                      </div>
                      <span className="text-sm font-bold text-cream">{v.user}</span>
                    </div>
                    <div className="flex gap-2">
                      <button className="p-2 bg-white/5 border border-white/10 rounded-lg text-cream/40 hover:text-primary transition-all">
                        <Download className="w-4 h-4" />
                      </button>
                      <button className="p-2 bg-white/5 border border-white/10 rounded-lg text-cream/40 hover:text-primary transition-all">
                        <Share2 className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                  
                  <p className="text-lg text-cream/70 leading-relaxed font-body">
                    {v.desc}
                  </p>

                  <div className="flex items-center gap-4 pt-4 border-t border-white/5">
                    <div className="flex items-center gap-2 text-green-500">
                      <Shield className="w-4 h-4" />
                      <span className="text-[10px] font-black uppercase tracking-widest">Verified Stable</span>
                    </div>
                    <button className="text-[10px] font-black uppercase tracking-widest text-primary hover:underline flex items-center gap-1">
                      Full Changelog
                      <ChevronRight className="w-3 h-3" />
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="text-center py-20 border-t border-white/5">
        <button className="bg-white/5 border border-white/10 px-10 py-4 rounded-2xl font-black text-cream/40 uppercase tracking-widest text-xs hover:bg-white/10 transition-all">
          Load Older Versions
        </button>
      </div>
    </motion.div>
  );
};

export default VersionHistory;

import React from 'react';
import { motion } from 'framer-motion';
import { toast } from 'sonner';
import { 
  Plus, 
  History, 
  Trophy, 
  Zap, 
  CheckCircle2, 
  Clock, 
  AlertCircle, 
  Volume2, 
  Languages, 
  BookOpen, 
  ChevronRight,
  Sparkles,
  MessageSquare
} from 'lucide-react';

const ContributorDashboard = () => {
  const stats = [
    { label: 'Words Contributed', val: '142', sub: '+12 this week', icon: BookOpen, color: 'text-primary' },
    { label: 'Validation Rate', val: '94%', sub: 'High accuracy', icon: CheckCircle2, color: 'text-green-400' },
    { label: 'Total XP Earned', val: '12,850', sub: 'Top 5% contributor', icon: Zap, color: 'text-blue-400' },
    { label: 'Community Rank', val: '#12', sub: 'Rising Star', icon: Trophy, color: 'text-terracotta' },
  ];

  const pendingSubmissions = [
    { id: 1, word: 'Kalumanan', lang: 'Mansaka', status: 'In Review', time: '2 hours ago', icon: Clock },
    { id: 2, word: 'Bagani', lang: 'Mandaya', status: 'Needs Feedback', time: '1 day ago', icon: AlertCircle },
    { id: 3, word: 'Dagat', lang: 'Kagan', status: 'Processing', time: '5 hours ago', icon: Clock },
  ];

  const recentActivity = [
    { id: 1, action: 'Word Validated', word: 'Abot', xp: '+50 XP', time: '3 hours ago', status: 'done' },
    { id: 2, action: 'New Contribution', word: 'Kalumanan', xp: '+20 XP', time: '5 hours ago', status: 'pending' },
    { id: 3, action: 'Feedback Received', word: 'Bagani', xp: '0 XP', time: '1 day ago', status: 'alert' },
  ];

  const handleAction = (action: string) => {
    toast.info(`${action} feature coming soon!`);
  };

  return (
    <motion.div 
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="space-y-10 pb-32"
    >
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h2 className="text-4xl font-headline font-bold text-primary mb-2">Weaver's Loom</h2>
          <p className="text-cream/40 font-medium">Weaving new echoes into the ancestral tapestry.</p>
        </div>
        <button 
          onClick={() => handleAction('Contribute New Word')}
          aria-label="Contribute New Word"
          className="bg-primary text-forest px-8 py-4 rounded-2xl font-black uppercase tracking-widest gold-shadow hover:-translate-y-1 active:translate-y-1 transition-all flex items-center gap-3"
        >
          <Plus className="w-6 h-6" />
          Contribute New Word
        </button>
      </div>

      {/* Stats Row */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat, idx) => (
          <div key={idx} className="bg-surface-low border border-white/5 rounded-3xl p-6 hover:border-primary/20 transition-all group">
            <div className="w-12 h-12 bg-white/5 rounded-2xl flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
              <stat.icon className={`w-6 h-6 ${stat.color}`} />
            </div>
            <p className="text-[10px] font-black uppercase tracking-widest text-cream/40 mb-1">{stat.label}</p>
            <p className="text-3xl font-black text-cream mb-1">{stat.val}</p>
            <p className="text-[10px] font-bold text-cream/20">{stat.sub}</p>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        {/* Pending Submissions */}
        <div className="lg:col-span-7 space-y-6">
          <div className="flex items-center justify-between">
            <h3 className="text-2xl font-bold text-cream">Pending Echoes</h3>
            <button 
              onClick={() => handleAction('View History')}
              className="text-xs font-bold text-primary hover:underline"
            >
              View History
            </button>
          </div>
          
          <div className="space-y-4">
            {pendingSubmissions.map((sub) => (
              <div key={sub.id} className="bg-white/5 border border-white/10 rounded-3xl p-6 flex items-center gap-6 group hover:bg-white/10 transition-all">
                <div className="w-16 h-16 bg-primary/10 rounded-2xl flex items-center justify-center">
                  <Languages className="w-8 h-8 text-primary" />
                </div>
                <div className="flex-1">
                  <div className="flex items-center gap-3 mb-1">
                    <h4 className="text-xl font-bold text-cream">{sub.word}</h4>
                    <span className="bg-white/5 border border-white/10 text-cream/40 text-[9px] font-black px-2 py-0.5 rounded uppercase tracking-widest">{sub.lang}</span>
                  </div>
                  <div className="flex items-center gap-3 text-xs text-cream/40">
                    <sub.icon className={`w-3 h-3 ${sub.status === 'Needs Feedback' ? 'text-terracotta' : 'text-primary'}`} />
                    <span>{sub.status}</span>
                    <span>•</span>
                    <span>{sub.time}</span>
                  </div>
                </div>
                <button 
                  onClick={() => handleAction(`View submission ${sub.word}`)}
                  aria-label={`View submission ${sub.word}`}
                  className="p-3 hover:bg-white/10 rounded-xl text-cream/20 hover:text-primary transition-colors"
                >
                  <ChevronRight className="w-6 h-6" />
                </button>
              </div>
            ))}
          </div>

          {/* Quick Contribution Form Preview */}
          <div className="bg-gradient-to-br from-surface-low to-forest border border-white/5 rounded-[2.5rem] p-10 relative overflow-hidden terracotta-shadow">
            <div className="absolute top-0 right-0 w-64 h-64 bg-primary/5 rounded-full -mr-32 -mt-32 blur-3xl"></div>
            <div className="relative z-10">
              <div className="flex items-center gap-3 mb-8">
                <div className="w-10 h-10 bg-white/10 rounded-xl flex items-center justify-center">
                  <Plus className="w-5 h-5 text-primary" />
                </div>
                <span className="text-[10px] font-black uppercase tracking-[0.4em] text-cream/40">Quick Submission</span>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
                <div className="space-y-2">
                  <label className="text-[10px] font-black uppercase tracking-widest text-cream/20 ml-2">Lumad Term</label>
                  <input type="text" placeholder="e.g. Kalumanan" className="w-full bg-white/5 border border-white/10 rounded-xl py-4 px-6 text-cream outline-none focus:border-primary/30 transition-all" />
                </div>
                <div className="space-y-2">
                  <label className="text-[10px] font-black uppercase tracking-widest text-cream/20 ml-2">English Meaning</label>
                  <input type="text" placeholder="e.g. Ancestral Land" className="w-full bg-white/5 border border-white/10 rounded-xl py-4 px-6 text-cream outline-none focus:border-primary/30 transition-all" />
                </div>
              </div>
              <button 
                onClick={() => handleAction('Continue Full Submission')}
                className="bg-white/5 border border-white/10 text-cream w-full py-4 rounded-2xl font-black uppercase tracking-widest hover:bg-white/10 transition-all"
              >
                Continue Full Submission →
              </button>
            </div>
          </div>
        </div>

        {/* Sidebar Activity */}
        <div className="lg:col-span-5 space-y-6">
          <div className="bg-surface-low border border-white/5 rounded-[2.5rem] p-8">
            <div className="flex items-center justify-between mb-8">
              <h3 className="text-xl font-bold text-cream">Recent Activity</h3>
              <History className="w-4 h-4 text-cream/20" />
            </div>
            <div className="space-y-6">
              {recentActivity.map((act) => (
                <div key={act.id} className="flex items-start gap-4 group">
                  <div className={`w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 transition-transform group-hover:scale-110 ${
                    act.status === 'done' ? 'bg-green-500/10 text-green-400' :
                    act.status === 'pending' ? 'bg-primary/10 text-primary' : 'bg-terracotta/10 text-terracotta'
                  }`}>
                    {act.status === 'done' ? <CheckCircle2 className="w-5 h-5" /> : 
                     act.status === 'pending' ? <Clock className="w-5 h-5" /> : <MessageSquare className="w-5 h-5" />}
                  </div>
                  <div className="flex-1">
                    <div className="flex justify-between items-start mb-1">
                      <p className="text-sm font-bold text-cream">{act.action}</p>
                      <span className={`text-[10px] font-black ${act.xp.startsWith('+') ? 'text-primary' : 'text-cream/20'}`}>{act.xp}</span>
                    </div>
                    <p className="text-xs text-cream/40 mb-1">Word: <span className="text-cream/60 font-bold">{act.word}</span></p>
                    <p className="text-[10px] font-mono text-cream/20 uppercase tracking-widest">{act.time}</p>
                  </div>
                </div>
              ))}
            </div>
            <button 
              onClick={() => handleAction('View Full Log')}
              className="w-full mt-8 py-4 text-xs font-black uppercase tracking-widest text-primary hover:text-primary/80 transition-colors"
            >
              View Full Log
            </button>
          </div>

          <div className="bg-gradient-to-br from-terracotta/20 to-transparent border border-terracotta/10 rounded-[2.5rem] p-8">
            <div className="flex items-center gap-3 mb-6">
              <div className="w-10 h-10 bg-terracotta/10 rounded-xl flex items-center justify-center">
                <Sparkles className="w-5 h-5 text-terracotta" />
              </div>
              <h3 className="text-xl font-bold text-terracotta">Next Milestone</h3>
            </div>
            <p className="text-sm text-cream/60 mb-6">Contribute 8 more words to unlock the <span className="text-cream font-bold">"Guardian of Echoes"</span> badge.</p>
            <div className="h-2 bg-white/10 rounded-full overflow-hidden mb-4">
              <div className="h-full bg-terracotta w-[65%] rounded-full"></div>
            </div>
            <p className="text-[10px] font-mono text-cream/40 uppercase tracking-widest">Progress: 12 / 20 Words</p>
          </div>
        </div>
      </div>
    </motion.div>
  );
};

export default ContributorDashboard;

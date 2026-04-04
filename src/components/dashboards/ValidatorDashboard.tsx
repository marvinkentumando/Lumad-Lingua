import React from 'react';
import { motion } from 'framer-motion';
import { toast } from 'sonner';
import { 
  ShieldCheck, 
  Search, 
  Filter, 
  CheckCircle2, 
  XCircle, 
  MessageSquare, 
  Clock, 
  AlertTriangle, 
  Volume2, 
  Languages, 
  BookOpen, 
  ChevronRight,
  User,
  History,
  MoreVertical
} from 'lucide-react';

const ValidatorDashboard = () => {
  const stats = [
    { label: 'Words Validated', val: '2,450', sub: '+45 today', icon: ShieldCheck, color: 'text-primary' },
    { label: 'Pending Queue', val: '156', sub: 'Priority: High', icon: Clock, color: 'text-terracotta' },
    { label: 'Accuracy Score', val: '99.2%', sub: 'Top Validator', icon: CheckCircle2, color: 'text-green-400' },
    { label: 'Community Feedback', val: '4.9/5', sub: 'Highly trusted', icon: MessageSquare, color: 'text-blue-400' },
  ];

  const validationQueue = [
    { id: 1, word: 'Kalumanan', lang: 'Mansaka', contributor: 'Datu Ramon', time: '2 hours ago', status: 'pending', priority: 'high' },
    { id: 2, word: 'Bagani', lang: 'Mandaya', contributor: 'Bae Marites', time: '5 hours ago', status: 'pending', priority: 'medium' },
    { id: 3, word: 'Dagat', lang: 'Kagan', contributor: 'Lolo Kiko', time: '1 day ago', status: 'pending', priority: 'low' },
  ];

  const recentDecisions = [
    { id: 1, word: 'Abot', action: 'Approved', time: '3 hours ago', status: 'approved' },
    { id: 2, word: 'Tangkad', action: 'Rejected', time: '5 hours ago', status: 'rejected' },
    { id: 3, word: 'Kuha', action: 'Needs Feedback', time: '1 day ago', status: 'feedback' },
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
          <h2 className="text-4xl font-headline font-bold text-primary mb-2">Guardian's Council</h2>
          <p className="text-cream/40 font-medium">Ensuring the purity and accuracy of ancestral echoes.</p>
        </div>
        <div className="flex gap-3">
          <button 
            onClick={() => handleAction('Full History')}
            aria-label="Full History"
            className="bg-white/5 border border-white/10 text-cream px-6 py-3 rounded-xl font-bold hover:bg-white/10 transition-all flex items-center gap-2"
          >
            <History className="w-4 h-4" />
            Full History
          </button>
          <button 
            onClick={() => handleAction('Start Batch Review')}
            aria-label="Start Batch Review"
            className="bg-primary text-forest px-6 py-3 rounded-xl font-bold gold-shadow hover:-translate-y-1 active:translate-y-1 transition-all flex items-center gap-2"
          >
            <ShieldCheck className="w-4 h-4" />
            Start Batch Review
          </button>
        </div>
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
        {/* Validation Queue */}
        <div className="lg:col-span-8 bg-surface-low border border-white/5 rounded-[2.5rem] p-8">
          <div className="flex items-center justify-between mb-8">
            <h3 className="text-2xl font-bold text-cream">Validation Queue</h3>
            <div className="flex gap-2">
              <button 
                onClick={() => handleAction('Filter Queue')}
                aria-label="Filter Queue"
                className="p-2 bg-white/5 border border-white/10 rounded-lg text-cream/40 hover:text-primary transition-colors"
              >
                <Filter className="w-4 h-4" />
              </button>
              <div className="relative group">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-cream/20 group-focus-within:text-primary transition-colors" />
                <input 
                  type="text" 
                  placeholder="Search queue..." 
                  className="bg-white/5 border border-white/10 rounded-lg py-2 pl-9 pr-4 text-sm text-cream outline-none focus:border-primary/30 transition-all"
                />
              </div>
            </div>
          </div>

          <div className="space-y-4">
            {validationQueue.map((item) => (
              <div key={item.id} className="bg-white/5 border border-white/10 rounded-3xl p-6 flex items-center gap-6 group hover:bg-white/10 transition-all">
                <div className="w-16 h-16 bg-primary/10 rounded-2xl flex items-center justify-center">
                  <Languages className="w-8 h-8 text-primary" />
                </div>
                <div className="flex-1">
                  <div className="flex items-center gap-3 mb-1">
                    <h4 className="text-xl font-bold text-cream">{item.word}</h4>
                    <span className="bg-white/5 border border-white/10 text-cream/40 text-[9px] font-black px-2 py-0.5 rounded uppercase tracking-widest">{item.lang}</span>
                    <span className={`text-[9px] font-black px-2 py-0.5 rounded uppercase tracking-widest ${
                      item.priority === 'high' ? 'bg-terracotta/20 text-terracotta' :
                      item.priority === 'medium' ? 'bg-primary/20 text-primary' : 'bg-white/10 text-cream/40'
                    }`}>
                      {item.priority} priority
                    </span>
                  </div>
                  <div className="flex items-center gap-3 text-xs text-cream/40">
                    <User className="w-3 h-3" />
                    <span>{item.contributor}</span>
                    <span>•</span>
                    <Clock className="w-3 h-3" />
                    <span>{item.time}</span>
                  </div>
                </div>
                <div className="flex items-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                  <button 
                    onClick={() => handleAction(`Approve ${item.word}`)}
                    aria-label={`Approve ${item.word}`}
                    className="w-10 h-10 bg-green-500/10 text-green-400 rounded-xl flex items-center justify-center hover:bg-green-500 hover:text-white transition-all"
                  >
                    <CheckCircle2 className="w-5 h-5" />
                  </button>
                  <button 
                    onClick={() => handleAction(`Reject ${item.word}`)}
                    aria-label={`Reject ${item.word}`}
                    className="w-10 h-10 bg-terracotta/10 text-terracotta rounded-xl flex items-center justify-center hover:bg-terracotta hover:text-white transition-all"
                  >
                    <XCircle className="w-5 h-5" />
                  </button>
                  <button 
                    onClick={() => handleAction(`View details for ${item.word}`)}
                    aria-label={`View details for ${item.word}`}
                    className="w-10 h-10 bg-white/5 text-cream/40 rounded-xl flex items-center justify-center hover:bg-white/10 hover:text-cream transition-all"
                  >
                    <ChevronRight className="w-5 h-5" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Recent Decisions & Alerts */}
        <div className="lg:col-span-4 space-y-6">
          <div className="bg-surface-low border border-white/5 rounded-[2.5rem] p-8">
            <h3 className="text-xl font-bold text-cream mb-8">Recent Decisions</h3>
            <div className="space-y-6">
              {recentDecisions.map((dec) => (
                <div key={dec.id} className="flex items-start gap-4 group">
                  <div className={`w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 transition-transform group-hover:scale-110 ${
                    dec.status === 'approved' ? 'bg-green-500/10 text-green-400' :
                    dec.status === 'rejected' ? 'bg-terracotta/10 text-terracotta' : 'bg-primary/10 text-primary'
                  }`}>
                    {dec.status === 'approved' ? <CheckCircle2 className="w-5 h-5" /> : 
                     dec.status === 'rejected' ? <XCircle className="w-5 h-5" /> : <MessageSquare className="w-5 h-5" />}
                  </div>
                  <div className="flex-1">
                    <div className="flex justify-between items-start mb-1">
                      <p className="text-sm font-bold text-cream">{dec.word}</p>
                      <span className={`text-[10px] font-black uppercase tracking-widest ${
                        dec.status === 'approved' ? 'text-green-400' :
                        dec.status === 'rejected' ? 'text-terracotta' : 'text-primary'
                      }`}>{dec.action}</span>
                    </div>
                    <p className="text-[10px] font-mono text-cream/20 uppercase tracking-widest">{dec.time}</p>
                  </div>
                </div>
              ))}
            </div>
            <button 
              onClick={() => handleAction('View Decision Log')}
              className="w-full mt-8 py-4 text-xs font-black uppercase tracking-widest text-primary hover:text-primary/80 transition-colors"
            >
              View Decision Log
            </button>
          </div>

          <div className="bg-gradient-to-br from-blue-500/20 to-transparent border border-blue-500/10 rounded-[2.5rem] p-8">
            <div className="flex items-center gap-3 mb-6">
              <div className="w-10 h-10 bg-blue-500/10 rounded-xl flex items-center justify-center">
                <AlertTriangle className="w-5 h-5 text-blue-400" />
              </div>
              <h3 className="text-xl font-bold text-blue-400">Cultural Alert</h3>
            </div>
            <p className="text-sm text-cream/60 mb-6">A new submission for <span className="text-cream font-bold">"Datu"</span> requires multi-elder verification due to regional dialect variations.</p>
            <button 
              onClick={() => handleAction('Review Alert')}
              className="w-full bg-blue-500/10 border border-blue-500/20 text-blue-400 py-3 rounded-xl text-xs font-black uppercase tracking-widest hover:bg-blue-500/20 transition-all"
            >
              Review Alert →
            </button>
          </div>
        </div>
      </div>
    </motion.div>
  );
};

export default ValidatorDashboard;

import React from 'react';
import { motion } from 'framer-motion';
import { Shield, Users, CheckCircle2, AlertTriangle, Settings, ChevronRight, BarChart3, Globe, Clock } from 'lucide-react';

const AdminDashboard: React.FC = () => {
  const stats = [
    { label: 'Total Weavers', val: '12,450', sub: '+124 this week', icon: Users, color: 'text-primary', bg: 'bg-primary/10' },
    { label: 'Submissions', val: '2,840', sub: '42 pending review', icon: Globe, color: 'text-blue-400', bg: 'bg-blue-400/10' },
    { label: 'Validated Echoes', val: '8,120', sub: '98% accuracy rate', icon: CheckCircle2, color: 'text-green-500', bg: 'bg-green-500/10' },
    { label: 'System Alerts', val: '3', sub: 'Requires attention', icon: AlertTriangle, color: 'text-terracotta', bg: 'bg-terracotta/10' },
  ];

  const recentActivity = [
    { id: 1, user: 'Elder Weaver', action: 'Validated "Kalumanan"', time: '2m ago', status: 'success' },
    { id: 2, user: 'Datu Marvin', action: 'Submitted "Dagmay"', time: '15m ago', status: 'pending' },
    { id: 3, user: 'System', action: 'Database backup complete', time: '1h ago', status: 'success' },
    { id: 4, user: 'Admin', action: 'Updated system settings', time: '3h ago', status: 'warning' },
  ];

  return (
    <motion.div 
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      className="space-y-12 pb-32"
    >
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-4">
          <div className="w-12 h-12 bg-primary/10 rounded-2xl flex items-center justify-center text-primary gold-shadow">
            <Shield className="w-6 h-6" />
          </div>
          <div>
            <h2 className="text-3xl font-bold text-primary leading-tight">Council Dashboard</h2>
            <p className="text-cream/40 text-sm font-medium">System Administration & Oversight</p>
          </div>
        </div>
        <div className="flex items-center gap-4">
          <button className="p-3 bg-white/5 rounded-2xl text-cream/40 hover:text-primary transition-colors border border-white/10">
            <Settings className="w-5 h-5" />
          </button>
          <button className="bg-primary/10 text-primary px-4 py-2 rounded-2xl text-xs font-black uppercase tracking-widest hover:bg-primary/20 transition-colors">
            Manage Weavers
          </button>
          <div className="bg-terracotta text-white px-4 py-2 rounded-2xl text-xs font-black uppercase tracking-widest terracotta-shadow">Admin Mode</div>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
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
        {/* Recent Activity */}
        <div className="lg:col-span-8 bg-white/5 border border-white/10 rounded-[2.5rem] p-10">
          <div className="flex items-center justify-between mb-10">
            <div className="flex items-center gap-3">
              <Clock className="w-5 h-5 text-primary" />
              <h3 className="text-2xl font-bold text-cream">Recent Activity</h3>
            </div>
            <button className="text-primary text-xs font-black uppercase tracking-widest hover:underline">View History</button>
          </div>
          
          <div className="space-y-4">
            {recentActivity.map((activity) => (
              <div key={activity.id} className="flex items-center gap-6 p-6 bg-white/5 border border-white/10 rounded-2xl hover:bg-white/10 transition-all group">
                <div className={`w-2 h-2 rounded-full ${
                  activity.status === 'success' ? 'bg-green-500' :
                  activity.status === 'pending' ? 'bg-primary' : 'bg-terracotta'
                }`}></div>
                <div className="flex-1">
                  <div className="text-sm font-bold text-cream group-hover:text-primary transition-colors">{activity.action}</div>
                  <div className="text-[10px] text-cream/40 uppercase font-black tracking-widest mt-1">{activity.user}</div>
                </div>
                <div className="text-[10px] font-mono text-cream/20">{activity.time}</div>
                <ChevronRight className="w-4 h-4 text-cream/20 group-hover:text-primary group-hover:translate-x-1 transition-all" />
              </div>
            ))}
          </div>
        </div>

        {/* System Health */}
        <div className="lg:col-span-4 space-y-8">
          <div className="bg-white/5 border border-white/10 rounded-[2.5rem] p-10 space-y-8">
            <div className="flex items-center gap-3 mb-2">
              <BarChart3 className="w-5 h-5 text-primary" />
              <h3 className="text-xl font-bold text-cream">Language Distribution</h3>
            </div>
            <div className="space-y-6">
              {[
                { label: 'Mansaka', val: 45, color: 'bg-primary' },
                { label: 'Mandaya', val: 32, color: 'bg-terracotta' },
                { label: 'Kagan', val: 15, color: 'bg-blue-400' },
                { label: 'Blaan', val: 8, color: 'bg-green-500' },
              ].map((lang, i) => (
                <div key={i} className="space-y-2">
                  <div className="flex justify-between text-[10px] font-black uppercase tracking-widest">
                    <span className="text-cream/60">{lang.label}</span>
                    <span className="text-cream/40">{lang.val}%</span>
                  </div>
                  <div className="h-2 bg-white/5 rounded-full overflow-hidden">
                    <div className={`h-full ${lang.color} transition-all duration-1000`} style={{ width: `${lang.val}%` }}></div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="bg-gradient-to-br from-forest to-surface-low border border-primary/20 rounded-[2.5rem] p-10 relative overflow-hidden group">
            <div className="absolute top-0 right-0 w-32 h-32 bg-primary/5 rounded-full -mr-16 -mt-16 blur-2xl group-hover:scale-150 transition-transform duration-1000"></div>
            <div className="relative z-10 space-y-6">
              <h4 className="text-xl font-bold text-cream">System Integrity</h4>
              <p className="text-cream/40 text-sm leading-relaxed">All ancestral databases are synchronized and encrypted with Lumad-standard protocols.</p>
              <div className="flex items-center gap-3 text-green-500">
                <CheckCircle2 className="w-5 h-5" />
                <span className="text-[10px] font-black uppercase tracking-widest">Status: Optimal</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </motion.div>
  );
};

export default AdminDashboard;

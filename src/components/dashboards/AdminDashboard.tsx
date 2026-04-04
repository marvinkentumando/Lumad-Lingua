import React from 'react';
import { motion } from 'framer-motion';
import { toast } from 'sonner';
import { 
  Users, 
  ShieldCheck, 
  Database, 
  Activity, 
  Settings, 
  AlertTriangle, 
  Search, 
  MoreVertical,
  UserPlus,
  Trash2,
  Edit3
} from 'lucide-react';

const AdminDashboard = () => {
  const stats = [
    { label: 'Total Weavers', val: '12,450', change: '+12%', icon: Users, color: 'text-blue-400' },
    { label: 'Validated Echoes', val: '4,210', change: '+5%', icon: ShieldCheck, color: 'text-primary' },
    { label: 'Pending Reviews', val: '156', change: '-2%', icon: AlertTriangle, color: 'text-terracotta' },
    { label: 'System Health', val: '99.9%', change: 'Stable', icon: Activity, color: 'text-green-400' },
  ];

  const recentUsers = [
    { id: 1, name: 'Datu Ramon', email: 'ramon@lumad.ph', role: 'Validator', status: 'Active', img: 'https://picsum.photos/seed/user1/100/100' },
    { id: 2, name: 'Bae Marites', email: 'marites@lumad.ph', role: 'Contributor', status: 'Active', img: 'https://picsum.photos/seed/user2/100/100' },
    { id: 3, name: 'Lolo Kiko', email: 'kiko@lumad.ph', role: 'Learner', status: 'Inactive', img: 'https://picsum.photos/seed/user3/100/100' },
    { id: 4, name: 'Teacher Aya', email: 'aya@lumad.ph', role: 'Contributor', status: 'Active', img: 'https://picsum.photos/seed/user4/100/100' },
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
          <h2 className="text-4xl font-headline font-bold text-primary mb-2">Chieftain's Hall</h2>
          <p className="text-cream/40 font-medium">Overseeing the growth of the ancestral digital archive.</p>
        </div>
        <div className="flex gap-3">
          <button 
            onClick={() => handleAction('Export Data')}
            aria-label="Export Data"
            className="bg-white/5 border border-white/10 text-cream px-6 py-3 rounded-xl font-bold hover:bg-white/10 transition-all flex items-center gap-2"
          >
            <Database className="w-4 h-4" />
            Export Data
          </button>
          <button 
            onClick={() => handleAction('Add Member')}
            aria-label="Add Member"
            className="bg-primary text-forest px-6 py-3 rounded-xl font-bold gold-shadow hover:-translate-y-1 active:translate-y-1 transition-all flex items-center gap-2"
          >
            <UserPlus className="w-4 h-4" />
            Add Member
          </button>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat, idx) => (
          <div key={idx} className="bg-surface-low border border-white/5 rounded-3xl p-6 hover:border-primary/20 transition-all group">
            <div className="flex items-center justify-between mb-4">
              <div className="w-12 h-12 bg-white/5 rounded-2xl flex items-center justify-center group-hover:scale-110 transition-transform">
                <stat.icon className={`w-6 h-6 ${stat.color}`} />
              </div>
              <span className={`text-xs font-bold ${stat.change.startsWith('+') ? 'text-green-400' : stat.change.startsWith('-') ? 'text-terracotta' : 'text-cream/40'}`}>
                {stat.change}
              </span>
            </div>
            <p className="text-sm font-bold text-cream/40 uppercase tracking-widest mb-1">{stat.label}</p>
            <p className="text-3xl font-black text-cream">{stat.val}</p>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        {/* User Management Table */}
        <div className="lg:col-span-8 bg-surface-low border border-white/5 rounded-[2.5rem] p-8">
          <div className="flex items-center justify-between mb-8">
            <h3 className="text-2xl font-bold text-cream">Member Management</h3>
            <div className="relative group">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-cream/20 group-focus-within:text-primary transition-colors" />
              <input 
                type="text" 
                placeholder="Search members..." 
                className="bg-white/5 border border-white/10 rounded-xl py-2 pl-10 pr-4 text-sm text-cream outline-none focus:border-primary/30 transition-all"
              />
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="border-b border-white/5">
                  <th className="pb-4 text-[10px] font-black uppercase tracking-widest text-cream/20 px-4">Member</th>
                  <th className="pb-4 text-[10px] font-black uppercase tracking-widest text-cream/20 px-4">Role</th>
                  <th className="pb-4 text-[10px] font-black uppercase tracking-widest text-cream/20 px-4">Status</th>
                  <th className="pb-4 text-[10px] font-black uppercase tracking-widest text-cream/20 px-4">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-white/5">
                {recentUsers.map((user) => (
                  <tr key={user.id} className="group hover:bg-white/5 transition-colors">
                    <td className="py-4 px-4">
                      <div className="flex items-center gap-3">
                        <img src={user.img} className="w-10 h-10 rounded-full border border-white/10" referrerPolicy="no-referrer" />
                        <div>
                          <p className="text-sm font-bold text-cream">{user.name}</p>
                          <p className="text-xs text-cream/40">{user.email}</p>
                        </div>
                      </div>
                    </td>
                    <td className="py-4 px-4">
                      <span className={`text-[10px] font-black px-2.5 py-1 rounded-full uppercase tracking-widest ${
                        user.role === 'Validator' ? 'bg-primary/10 text-primary' :
                        user.role === 'Contributor' ? 'bg-blue-500/10 text-blue-400' : 'bg-white/10 text-cream/40'
                      }`}>
                        {user.role}
                      </span>
                    </td>
                    <td className="py-4 px-4">
                      <div className="flex items-center gap-2">
                        <div className={`w-1.5 h-1.5 rounded-full ${user.status === 'Active' ? 'bg-green-400 animate-pulse' : 'bg-cream/20'}`}></div>
                        <span className="text-xs font-bold text-cream/60">{user.status}</span>
                      </div>
                    </td>
                    <td className="py-4 px-4">
                      <div className="flex items-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                        <button 
                          onClick={() => handleAction(`Edit ${user.name}`)}
                          aria-label={`Edit ${user.name}`}
                          className="p-2 hover:bg-white/10 rounded-lg text-cream/40 hover:text-primary transition-colors"
                        >
                          <Edit3 className="w-4 h-4" />
                        </button>
                        <button 
                          onClick={() => handleAction(`Delete ${user.name}`)}
                          aria-label={`Delete ${user.name}`}
                          className="p-2 hover:bg-white/10 rounded-lg text-cream/40 hover:text-terracotta transition-colors"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                        <button 
                          onClick={() => handleAction(`More options for ${user.name}`)}
                          aria-label="More options"
                          className="p-2 hover:bg-white/10 rounded-lg text-cream/40 hover:text-cream transition-colors"
                        >
                          <MoreVertical className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* System Settings Quick Access */}
        <div className="lg:col-span-4 space-y-6">
          <div className="bg-surface-low border border-white/5 rounded-[2.5rem] p-8">
            <h3 className="text-xl font-bold text-cream mb-6">Archive Settings</h3>
            <div className="space-y-4">
              {[
                { label: 'Public Access', desc: 'Allow anyone to view the dictionary.', active: true },
                { label: 'Contribution Lock', desc: 'Pause new word submissions.', active: false },
                { label: 'Auto-Validation', desc: 'Use AI to pre-screen entries.', active: true },
              ].map((setting, i) => (
                <div key={i} className="flex items-center justify-between p-4 bg-white/5 rounded-2xl border border-white/5">
                  <div>
                    <p className="text-sm font-bold text-cream">{setting.label}</p>
                    <p className="text-[10px] text-cream/40">{setting.desc}</p>
                  </div>
                  <button 
                    onClick={() => handleAction(`Toggle ${setting.label}`)}
                    aria-label={`Toggle ${setting.label}`}
                    className={`w-10 h-5 rounded-full relative transition-colors ${setting.active ? 'bg-primary' : 'bg-white/10'}`}
                  >
                    <div className={`absolute top-1 w-3 h-3 bg-forest rounded-full transition-all ${setting.active ? 'right-1' : 'left-1'}`}></div>
                  </button>
                </div>
              ))}
            </div>
            <button 
              onClick={() => handleAction('Advanced Settings')}
              aria-label="Advanced Settings"
              className="w-full mt-8 bg-white/5 border border-white/10 text-cream py-4 rounded-2xl font-bold hover:bg-white/10 transition-all flex items-center justify-center gap-2"
            >
              <Settings className="w-4 h-4" />
              Advanced Settings
            </button>
          </div>

          <div className="bg-gradient-to-br from-primary/20 to-transparent border border-primary/10 rounded-[2.5rem] p-8 relative overflow-hidden">
            <div className="relative z-10">
              <h3 className="text-xl font-bold text-primary mb-2">Storage Status</h3>
              <p className="text-sm text-cream/60 mb-6">Archive capacity is at 42%.</p>
              <div className="h-2 bg-white/10 rounded-full overflow-hidden mb-4">
                <div className="h-full bg-primary w-[42%] rounded-full"></div>
              </div>
              <p className="text-[10px] font-mono text-cream/40 uppercase tracking-widest">Last backup: 2 hours ago</p>
            </div>
          </div>
        </div>
      </div>
    </motion.div>
  );
};

export default AdminDashboard;

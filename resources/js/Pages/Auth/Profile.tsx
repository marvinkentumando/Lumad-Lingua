import React from 'react';
import { motion } from 'framer-motion';
import { 
  Settings, 
  Shield, 
  Globe, 
  Bell, 
  LogOut, 
  ChevronRight, 
  Star, 
  Trophy, 
  Target, 
  Zap, 
  BookOpen, 
  Sparkles, 
  Hash, 
  MapPin, 
  Clock, 
  Volume2,
  TrendingUp,
  BarChart3
} from 'lucide-react';
import { Role } from '../../types';
import { UserProfile } from '../../Contexts/FirebaseContext';
import { 
  AreaChart, 
  Area, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  BarChart,
  Bar,
  Cell
} from 'recharts';

interface ProfileProps {
  profile: UserProfile | null;
  userRole: Role;
  onRoleChange: (role: Role) => void;
  onLogout: () => void;
}

const progressData = [
  { day: 'Mon', xp: 400 },
  { day: 'Tue', xp: 300 },
  { day: 'Wed', xp: 600 },
  { day: 'Thu', xp: 800 },
  { day: 'Fri', xp: 500 },
  { day: 'Sat', xp: 900 },
  { day: 'Sun', xp: 1200 },
];

const accuracyData = [
  { subject: 'Greetings', score: 95 },
  { subject: 'Numbers', score: 82 },
  { subject: 'Nature', score: 75 },
  { subject: 'Family', score: 88 },
  { subject: 'Rituals', score: 60 },
];

const Profile: React.FC<ProfileProps> = ({ profile, userRole, onRoleChange, onLogout }) => {
  const stats = [
    { label: 'Total XP', val: (profile?.xp || 0).toLocaleString(), icon: Zap, color: 'text-primary' },
    { label: 'Lessons', val: (profile?.completedLessons?.length || 0).toString(), icon: BookOpen, color: 'text-blue-400' },
    { label: 'Streak', val: `${profile?.streak || 0} Days`, icon: Trophy, color: 'text-orange-500' },
    { label: 'Accuracy', val: `${profile?.accuracy || 0}%`, icon: Target, color: 'text-green-500' },
  ];

  const settings = [
    { icon: Settings, label: 'Account Settings', desc: 'Manage your profile and security' },
    { icon: Bell, label: 'Notifications', desc: 'Configure learning reminders' },
    { icon: Globe, label: 'Language Preferences', desc: 'Choose your primary dialects' },
    { icon: Shield, label: 'Privacy & Data', desc: 'Control your ancestral footprint' },
  ];

  const artifacts = [
    { name: 'Golden Loom', icon: Globe, rarity: 'Epic', unlocked: true },
    { name: 'Sacred Thread', icon: Sparkles, rarity: 'Rare', unlocked: true },
    { name: 'Elder Voice', icon: Volume2, rarity: 'Common', unlocked: true },
    { name: 'Domain Map', icon: MapPin, rarity: 'Common', unlocked: true },
    { name: 'Spirit Needle', icon: Hash, rarity: 'Rare', unlocked: false },
    { name: 'Ancient Dye', icon: MapPin, rarity: 'Epic', unlocked: false },
  ];

  return (
    <motion.div 
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      className="max-w-4xl mx-auto space-y-12 pb-32 px-4 sm:px-6 lg:px-8"
    >
      {/* Profile Header */}
      <section className="relative overflow-hidden bg-forest/50 rounded-[3rem] p-8 md:p-12 border border-white/5 text-center">
        <div className="absolute top-0 left-0 right-0 h-1.5 bg-gradient-to-r from-primary via-orange-500 to-primary"></div>
        <div className="relative z-10">
          <div className="w-24 h-24 md:w-32 md:h-32 rounded-full border-4 border-primary p-1 mx-auto mb-6 gold-shadow">
            <img 
              src="https://api.dicebear.com/7.x/avataaars/svg?seed=Datu" 
              alt="Profile" 
              className="w-full h-full rounded-full bg-forest"
              referrerPolicy="no-referrer"
            />
          </div>
          <h2 className="text-3xl md:text-4xl font-headline font-bold text-cream mb-2">Datu Marvin</h2>
          <div className="flex flex-wrap items-center justify-center gap-3 mb-8">
            <span className="bg-primary/10 border border-primary/20 px-3 py-1 rounded-lg text-[10px] font-bold text-primary uppercase tracking-widest">Level 12 Weaver</span>
            <span className="bg-white/5 border border-white/10 px-3 py-1 rounded-lg text-[10px] font-bold text-cream/40 uppercase tracking-widest">Mansaka Community</span>
          </div>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 max-w-2xl mx-auto">
            {stats.map((stat, i) => (
              <div key={i} className="bg-white/5 border border-white/10 p-4 rounded-2xl min-h-[44px]">
                <stat.icon className={`w-5 h-5 ${stat.color} mx-auto mb-2`} />
                <div className="text-xl font-bold text-cream">{stat.val}</div>
                <div className="text-[9px] font-black uppercase tracking-widest text-cream/20">{stat.label}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Learning Analytics */}
      <section className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="bg-white/5 border border-white/10 rounded-[2.5rem] p-8">
          <div className="flex items-center justify-between mb-8">
            <div>
              <h3 className="text-xl font-bold text-cream">XP Progress</h3>
              <p className="text-[10px] text-cream/40 uppercase font-black tracking-widest mt-1">Weekly activity</p>
            </div>
            <TrendingUp className="w-5 h-5 text-primary" />
          </div>
          <div className="h-64 w-full min-h-[256px]">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={progressData}>
                <defs>
                  <linearGradient id="colorXp" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#C4A484" stopOpacity={0.3}/>
                    <stop offset="95%" stopColor="#C4A484" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#ffffff05" vertical={false} />
                <XAxis 
                  dataKey="day" 
                  axisLine={false} 
                  tickLine={false} 
                  tick={{ fill: '#ffffff40', fontSize: 10 }}
                />
                <YAxis hide />
                <Tooltip 
                  contentStyle={{ backgroundColor: '#1a2e1a', border: '1px solid #ffffff10', borderRadius: '12px' }}
                  itemStyle={{ color: '#C4A484' }}
                />
                <Area 
                  type="monotone" 
                  dataKey="xp" 
                  stroke="#C4A484" 
                  fillOpacity={1} 
                  fill="url(#colorXp)" 
                  strokeWidth={3}
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="bg-white/5 border border-white/10 rounded-[2.5rem] p-8">
          <div className="flex items-center justify-between mb-8">
            <div>
              <h3 className="text-xl font-bold text-cream">Accuracy by Topic</h3>
              <p className="text-[10px] text-cream/40 uppercase font-black tracking-widest mt-1">Mastery levels</p>
            </div>
            <BarChart3 className="w-5 h-5 text-blue-400" />
          </div>
          <div className="h-64 w-full min-h-[256px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={accuracyData} layout="vertical">
                <CartesianGrid strokeDasharray="3 3" stroke="#ffffff05" horizontal={false} />
                <XAxis type="number" hide domain={[0, 100]} />
                <YAxis 
                  dataKey="subject" 
                  type="category" 
                  axisLine={false} 
                  tickLine={false} 
                  tick={{ fill: '#ffffff40', fontSize: 10 }}
                  width={70}
                />
                <Tooltip 
                  cursor={{ fill: '#ffffff05' }}
                  contentStyle={{ backgroundColor: '#1a2e1a', border: '1px solid #ffffff10', borderRadius: '12px' }}
                />
                <Bar dataKey="score" radius={[0, 10, 10, 0]}>
                  {accuracyData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.score > 80 ? '#C4A484' : '#8B310A'} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>
      </section>

      {/* Artifacts & Badges Collection */}
      <section className="bg-white/5 border border-white/10 rounded-[2.5rem] p-8 md:p-10">
        <div className="flex items-center justify-between mb-10">
          <h3 className="text-2xl font-bold text-cream">Weaver's Collection</h3>
          <div className="flex items-center gap-2">
            <span className="text-[10px] font-black uppercase tracking-widest text-primary">12 / 24 Artifacts</span>
          </div>
        </div>
        
        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-6 gap-4 md:gap-6">
          {artifacts.map((item, i) => (
            <div key={i} className={`relative aspect-square rounded-3xl border flex flex-col items-center justify-center gap-3 transition-all group ${
              item.unlocked 
                ? 'bg-white/5 border-white/10 hover:bg-white/10 hover:scale-105' 
                : 'bg-black/20 border-white/5 opacity-40 grayscale'
            }`}>
              <div className={`w-10 h-10 rounded-2xl flex items-center justify-center ${
                item.rarity === 'Epic' ? 'bg-primary/20 text-primary' : 
                item.rarity === 'Rare' ? 'bg-terracotta/20 text-terracotta' : 
                'bg-blue-400/20 text-blue-400'
              }`}>
                <item.icon className="w-5 h-5" />
              </div>
              <div className="text-center px-2">
                <div className="text-[9px] font-bold text-cream leading-tight truncate w-full">{item.name}</div>
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
      </section>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        {/* Settings */}
        <div className="space-y-6">
          <h3 className="text-[10px] font-black uppercase tracking-widest text-cream/20 border-b border-white/10 pb-2">Application Settings</h3>
          <div className="space-y-3">
            {settings.map((item, i) => (
              <button key={i} className="w-full flex items-center gap-4 p-4 bg-white/5 border border-white/10 rounded-2xl hover:bg-white/10 transition-all group text-left min-h-[44px]">
                <div className="w-10 h-10 bg-white/5 rounded-xl flex items-center justify-center text-cream/40 group-hover:text-primary transition-colors">
                  <item.icon className="w-5 h-5" />
                </div>
                <div className="flex-1">
                  <div className="text-sm font-bold text-cream">{item.label}</div>
                  <div className="text-[10px] text-cream/40 uppercase font-black tracking-widest mt-0.5">{item.desc}</div>
                </div>
                <ChevronRight className="w-4 h-4 text-cream/20 group-hover:text-primary group-hover:translate-x-1 transition-all" />
              </button>
            ))}
          </div>
        </div>

        {/* Role Switcher & Actions */}
        <div className="space-y-6">
          <h3 className="text-[10px] font-black uppercase tracking-widest text-cream/20 border-b border-white/10 pb-2">Role Management</h3>
          <div className="bg-white/5 border border-white/10 rounded-[2rem] p-8 space-y-6">
            <div className="flex items-center justify-between">
              <div>
                <div className="text-sm font-bold text-cream">Current Role</div>
                <div className="text-[10px] text-cream/40 uppercase font-black tracking-widest mt-0.5">Your active system identity</div>
              </div>
              <div className="bg-primary/10 border border-primary/20 px-4 py-2 rounded-xl text-xs font-black text-primary uppercase tracking-widest">
                {userRole}
              </div>
            </div>
            <div className="grid grid-cols-2 gap-3">
              {(['learner', 'contributor', 'validator', 'admin'] as Role[]).map((role) => (
                <button 
                  key={role}
                  onClick={() => onRoleChange(role)}
                  className={`px-4 py-3 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all border min-h-[44px] ${
                    userRole === role 
                      ? 'bg-primary border-primary text-forest gold-shadow' 
                      : 'bg-white/5 border-white/10 text-cream/40 hover:bg-white/10'
                  }`}
                >
                  {role}
                </button>
              ))}
            </div>
          </div>

          <div className="space-y-3">
            <button 
              onClick={onLogout}
              className="w-full flex items-center justify-center gap-3 p-4 bg-terracotta/10 border border-terracotta/20 rounded-2xl text-terracotta hover:bg-terracotta/20 transition-all font-black uppercase tracking-widest text-xs min-h-[44px]"
            >
              <LogOut className="w-4 h-4" />
              Sign Out of Echo
            </button>
          </div>
        </div>
      </div>
    </motion.div>
  );
};

export default Profile;

import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
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
  BarChart3,
  X
} from 'lucide-react';
import { Role } from '../../types';
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
import { useFirebase } from '../../Contexts/FirebaseContext';
import { toast } from 'sonner';

interface ProfileProps {
  userRole: Role;
  onLogout: () => void;
}

const defaultProgressData = [
  { day: 'Mon', xp: 0 },
  { day: 'Tue', xp: 0 },
  { day: 'Wed', xp: 0 },
  { day: 'Thu', xp: 0 },
  { day: 'Fri', xp: 0 },
  { day: 'Sat', xp: 0 },
  { day: 'Sun', xp: 0 },
];

const defaultAccuracyData = [
  { subject: 'Greetings', score: 0 },
  { subject: 'Numbers', score: 0 },
  { subject: 'Nature', score: 0 },
  { subject: 'Family', score: 0 },
  { subject: 'Rituals', score: 0 },
];

const Profile: React.FC<ProfileProps> = ({ userRole, onLogout }) => {
  const { profile, updateProfile } = useFirebase();
  const [activeModal, setActiveModal] = useState<string | null>(null);

  const progressData = profile?.xpHistory?.length ? profile.xpHistory : defaultProgressData;
  const accuracyData = profile?.accuracy?.length ? profile.accuracy : defaultAccuracyData;

  const overallAccuracy = profile?.accuracy?.length 
    ? Math.round(profile.accuracy.reduce((acc, curr) => acc + curr.score, 0) / profile.accuracy.length)
    : 0;

  const stats = [
    { label: 'Total XP', val: profile?.xp?.toLocaleString() || '0', icon: Zap, color: 'text-primary' },
    { label: 'Lessons', val: profile?.completedLessons?.length?.toString() || '0', icon: BookOpen, color: 'text-blue-400' },
    { label: 'Streak', val: `${profile?.streak || 0} Days`, icon: Trophy, color: 'text-orange-500' },
    { label: 'Accuracy', val: `${overallAccuracy}%`, icon: Target, color: 'text-green-500' },
  ];

  const settings = [
    { id: 'account', icon: Settings, label: 'Account Settings', desc: 'Manage your profile and security' },
    { id: 'notifications', icon: Bell, label: 'Notifications', desc: 'Configure learning reminders' },
    { id: 'language', icon: Globe, label: 'Language Preferences', desc: 'Choose your primary dialects' },
    { id: 'privacy', icon: Shield, label: 'Privacy & Data', desc: 'Control your ancestral footprint' },
  ];

  const artifacts = [
    { id: 'golden_loom', name: 'Golden Loom', icon: Globe, rarity: 'Epic' },
    { id: 'sacred_thread', name: 'Sacred Thread', icon: Sparkles, rarity: 'Rare' },
    { id: 'elder_voice', name: 'Elder Voice', icon: Volume2, rarity: 'Common' },
    { id: 'domain_map', name: 'Domain Map', icon: MapPin, rarity: 'Common' },
    { id: 'spirit_needle', name: 'Spirit Needle', icon: Hash, rarity: 'Rare' },
    { id: 'ancient_dye', name: 'Ancient Dye', icon: MapPin, rarity: 'Epic' },
  ].map(a => ({ ...a, unlocked: profile?.artifacts?.includes(a.id) || false }));

  const renderModal = () => {
    if (!activeModal) return null;

    const modalData: Record<string, { title: string; content: React.ReactNode }> = {
      account: {
        title: 'Account Settings',
        content: (
          <div className="space-y-6">
            <div className="space-y-4">
              <div className="p-4 bg-white/5 border border-white/10 rounded-2xl">
                <label className="text-[10px] font-black uppercase tracking-widest text-cream/40 mb-2 block">Display Name</label>
                <input 
                  type="text" 
                  defaultValue={profile?.displayName || ''} 
                  className="w-full bg-transparent border-none outline-none text-cream font-bold"
                  onBlur={(e) => updateProfile({ displayName: e.target.value })}
                />
              </div>
              <div className="p-4 bg-white/5 border border-white/10 rounded-2xl opacity-50">
                <label className="text-[10px] font-black uppercase tracking-widest text-cream/40 mb-2 block">Email Address</label>
                <div className="text-cream font-bold">{profile?.email}</div>
              </div>
            </div>
            <button 
              onClick={() => {
                setActiveModal(null);
                toast.success('Profile settings updated!');
              }}
              className="w-full bg-primary text-forest py-4 rounded-2xl font-black uppercase tracking-widest text-xs gold-shadow"
            >
              Save Changes
            </button>
          </div>
        )
      },
      notifications: {
        title: 'Notifications',
        content: (
          <div className="space-y-4">
            {['Daily Reminders', 'Streak Alerts', 'New Lessons', 'Community Updates'].map((item) => (
              <div key={item} className="flex items-center justify-between p-4 bg-white/5 border border-white/10 rounded-2xl">
                <span className="text-cream font-bold">{item}</span>
                <div className="w-10 h-5 bg-primary rounded-full relative">
                  <div className="absolute top-1 right-1 w-3 h-3 bg-forest rounded-full"></div>
                </div>
              </div>
            ))}
          </div>
        )
      },
      language: {
        title: 'Language Preferences',
        content: (
          <div className="space-y-4">
            <div className="space-y-2">
              <label className="text-[10px] font-black uppercase tracking-widest text-cream/40 px-2">Primary Dialect</label>
              <div className="grid grid-cols-2 gap-2">
                {['Mansaka', 'Mandaya'].map(d => (
                  <button key={d} className={`py-3 rounded-xl text-xs font-bold uppercase tracking-widest border transition-all ${d === 'Mansaka' ? 'bg-primary border-primary text-forest' : 'bg-white/5 border-white/10 text-cream/40'}`}>
                    {d}
                  </button>
                ))}
              </div>
            </div>
          </div>
        )
      },
      privacy: {
        title: 'Privacy & Data',
        content: (
          <div className="space-y-6">
            <div className="p-4 bg-white/5 border border-white/10 rounded-2xl">
              <div className="flex items-center justify-between mb-2">
                <span className="text-cream font-bold">Public Profile</span>
                <div className="w-10 h-5 bg-white/10 rounded-full relative">
                  <div className="absolute top-1 left-1 w-3 h-3 bg-cream/40 rounded-full"></div>
                </div>
              </div>
              <p className="text-[10px] text-cream/40">Allow other weavers to see your progress and artifacts.</p>
            </div>
            <button className="w-full bg-terracotta/10 border border-terracotta/20 text-terracotta py-4 rounded-2xl font-black uppercase tracking-widest text-xs">Delete Account Data</button>
          </div>
        )
      }
    };

    const currentModal = modalData[activeModal];
    if (!currentModal) return null;

    return (
      <motion.div 
        key="modal-overlay"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 z-[100] flex items-center justify-center px-4"
      >
        <div 
          onClick={() => setActiveModal(null)}
          className="absolute inset-0 bg-forest/80 backdrop-blur-md"
        />
        <motion.div 
          initial={{ opacity: 0, scale: 0.95, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.95, y: 20 }}
          className="relative w-full max-w-md bg-surface-high border border-white/10 rounded-[2.5rem] p-8 shadow-2xl"
        >
          <div className="flex items-center justify-between mb-8">
            <h3 className="text-2xl font-bold text-cream">{currentModal.title}</h3>
            <button 
              onClick={() => setActiveModal(null)}
              className="p-2 hover:bg-white/5 rounded-full transition-colors"
            >
              <X className="w-5 h-5 text-cream/40" />
            </button>
          </div>
          {currentModal.content}
        </motion.div>
      </motion.div>
    );
  };

  return (
    <motion.div 
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      className="max-w-4xl mx-auto space-y-8 md:space-y-12 pb-32"
    >
      <AnimatePresence>
        {renderModal()}
      </AnimatePresence>
      {/* Profile Header */}
      <section className="relative overflow-hidden bg-forest/50 rounded-[2rem] md:rounded-[3rem] p-6 md:p-12 border border-white/5 text-center">
        <div className="absolute top-0 left-0 right-0 h-1.5 bg-gradient-to-r from-primary via-orange-500 to-primary"></div>
        <div className="relative z-10">
          <div className="w-20 h-20 md:w-32 md:h-32 rounded-full border-4 border-primary p-1 mx-auto mb-4 md:mb-6 gold-shadow">
            <img 
              src={`https://api.dicebear.com/7.x/avataaars/svg?seed=${profile?.uid || 'default'}`} 
              alt="Profile" 
              className="w-full h-full rounded-full bg-forest"
              referrerPolicy="no-referrer"
            />
          </div>
          <h2 className="text-2xl md:text-4xl font-headline font-bold text-cream mb-2">{profile?.displayName || 'Unknown Weaver'}</h2>
          <div className="flex flex-wrap items-center justify-center gap-2 md:gap-3 mb-6 md:mb-8">
            <span className="bg-primary/10 border border-primary/20 px-2.5 py-1 rounded-lg text-[9px] md:text-[10px] font-bold text-primary uppercase tracking-widest">Level {profile?.level || 1} Weaver</span>
            <span className="bg-white/5 border border-white/10 px-2.5 py-1 rounded-lg text-[9px] md:text-[10px] font-bold text-cream/40 uppercase tracking-widest">Mansaka Community</span>
          </div>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4 max-w-2xl mx-auto">
            {stats.map((stat, i) => (
              <div key={i} className="bg-white/5 border border-white/10 p-3 md:p-4 rounded-xl md:rounded-2xl min-h-[44px]">
                <stat.icon className={`w-4 h-4 md:w-5 md:h-5 ${stat.color} mx-auto mb-1.5 md:mb-2`} />
                <div className="text-lg md:text-xl font-bold text-cream">{stat.val}</div>
                <div className="text-[8px] md:text-[9px] font-black uppercase tracking-widest text-cream/20">{stat.label}</div>
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
          <div className="h-[256px] w-full min-w-0">
            <ResponsiveContainer width="100%" height="100%" minWidth={0} debounce={1}>
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
          <div className="h-[256px] w-full min-w-0">
            <ResponsiveContainer width="100%" height="100%" minWidth={0} debounce={1}>
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
              <button 
                key={i} 
                onClick={() => setActiveModal(item.id)}
                className="w-full flex items-center gap-4 p-4 bg-white/5 border border-white/10 rounded-2xl hover:bg-white/10 transition-all group text-left min-h-[44px]"
              >
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

        {/* Contributor Application & Actions */}
        <div className="space-y-6">
          <h3 className="text-[10px] font-black uppercase tracking-widest text-cream/20 border-b border-white/10 pb-2">Community Contribution</h3>
          <div className="bg-white/5 border border-white/10 rounded-[2rem] p-8 space-y-6">
            <div className="flex items-center justify-between">
              <div>
                <div className="text-sm font-bold text-cream">Contributor Status</div>
                <div className="text-[10px] text-cream/40 uppercase font-black tracking-widest mt-0.5">Help preserve our heritage</div>
              </div>
              <div className="bg-primary/10 border border-primary/20 px-4 py-2 rounded-xl text-xs font-black text-primary uppercase tracking-widest">
                {userRole === 'learner' ? 'Not Applied' : userRole}
              </div>
            </div>
            
            {userRole === 'learner' && (
              <div className="space-y-4">
                <p className="text-xs text-cream/60 leading-relaxed">
                  Share your knowledge of dialects, rituals, and traditions. Join our community of elders and experts.
                </p>
                <button 
                  onClick={async () => {
                    try {
                      await updateProfile({ contributorApplicationStatus: 'pending' });
                      toast.success('Contributor application submitted! Our council will review your request.');
                    } catch (error) {
                      toast.error('Failed to submit application. Please try again.');
                    }
                  }}
                  disabled={profile?.contributorApplicationStatus === 'pending'}
                  className={`w-full py-4 rounded-2xl font-black uppercase tracking-widest text-xs transition-all min-h-[44px] ${
                    profile?.contributorApplicationStatus === 'pending'
                      ? 'bg-white/5 border border-white/10 text-cream/20 cursor-not-allowed'
                      : 'bg-primary text-forest gold-shadow hover:-translate-y-1 active:translate-y-0'
                  }`}
                >
                  {profile?.contributorApplicationStatus === 'pending' ? 'Application Pending' : 'Apply as a Contributor'}
                </button>
              </div>
            )}

            {userRole !== 'learner' && (
              <div className="p-4 bg-primary/5 border border-primary/10 rounded-2xl">
                <p className="text-xs text-primary font-bold">
                  You are already an active contributor to the Echo community. Thank you for your wisdom.
                </p>
              </div>
            )}
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

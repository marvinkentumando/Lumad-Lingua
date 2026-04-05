import React, { useState, useEffect } from 'react';
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
  Edit3,
  MapPin, 
  Plus, 
  Navigation, 
  Globe, 
  X
} from 'lucide-react';
import { collection, query, onSnapshot, doc, updateDoc, deleteDoc, addDoc, serverTimestamp } from 'firebase/firestore';
import { db } from '../../firebase';
import { useFirebase } from '../../Contexts/FirebaseContext';
import { AnimatePresence } from 'framer-motion';

const AdminDashboard = () => {
  const { profile } = useFirebase();
  const [users, setUsers] = useState<any[]>([]);
  const [words, setWords] = useState<any[]>([]);
  const [culturalSites, setCulturalSites] = useState<any[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [isAddingSite, setIsAddingSite] = useState(false);
  const [newSite, setNewSite] = useState({
    name: '',
    community: 'Mansaka',
    type: 'Sacred Site',
    coords: [7.0, 125.5],
    population: 0,
    dialect: '',
    status: 'Active',
    description: ''
  });

  useEffect(() => {
    const usersUnsubscribe = onSnapshot(collection(db, 'users'), (snapshot) => {
      const usersData = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setUsers(usersData);
    });

    const wordsUnsubscribe = onSnapshot(collection(db, 'words'), (snapshot) => {
      const wordsData = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setWords(wordsData);
    });

    const sitesUnsubscribe = onSnapshot(collection(db, 'cultural_sites'), (snapshot) => {
      const sitesData = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setCulturalSites(sitesData);
    });

    return () => {
      usersUnsubscribe();
      wordsUnsubscribe();
      sitesUnsubscribe();
    };
  }, []);

  const seedInitialSites = async () => {
    const initialSites = [
      { name: 'Mainit Hot Springs', community: 'Mansaka', type: 'Sacred Site', coords: [7.5, 126.0], population: 1240, dialect: 'Northern Mansaka', status: 'Active', description: 'A geothermal wonder considered sacred by the Mansaka people for its healing properties.' },
      { name: 'Maragusan Valley', community: 'Mansaka', type: 'Ancestral Domain', coords: [7.3, 126.1], population: 3500, dialect: 'Valley Mansaka', status: 'Protected', description: 'The heart of the Mansaka ancestral lands, rich in biodiversity and traditional agriculture.' },
      { name: 'Mount Hamiguitan', community: 'Mandaya', type: 'Heritage Site', coords: [6.7, 126.2], population: 800, dialect: 'Coastal Mandaya', status: 'UNESCO', description: 'A UNESCO World Heritage site known for its unique pygmy forest and Mandaya heritage.' },
      { name: 'Lake Sebu', community: 'Tboli', type: 'Cultural Hub', coords: [6.2, 124.7], population: 5200, dialect: 'Central Tboli', status: 'Active', description: 'The spiritual and cultural center of the Tboli people, famous for Tnalak weaving.' },
    ];

    try {
      for (const site of initialSites) {
        await addDoc(collection(db, 'cultural_sites'), {
          ...site,
          createdAt: serverTimestamp()
        });
      }
      toast.success('Initial sites seeded successfully!');
    } catch (error) {
      console.error('Error seeding sites:', error);
      toast.error('Failed to seed sites');
    }
  };

  const handleAddSite = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await addDoc(collection(db, 'cultural_sites'), {
        ...newSite,
        createdAt: serverTimestamp()
      });
      toast.success('Cultural site added successfully!');
      setIsAddingSite(false);
      setNewSite({
        name: '',
        community: 'Mansaka',
        type: 'Sacred Site',
        coords: [7.0, 125.5],
        population: 0,
        dialect: '',
        status: 'Active',
        description: ''
      });
    } catch (error) {
      console.error('Error adding site:', error);
      toast.error('Failed to add site');
    }
  };

  const [siteToDelete, setSiteToDelete] = useState<string | null>(null);

  const handleDeleteSite = async (id: string) => {
    setSiteToDelete(id);
  };

  const confirmDeleteSite = async () => {
    if (!siteToDelete) return;
    try {
      await deleteDoc(doc(db, 'cultural_sites', siteToDelete));
      toast.success('Site deleted successfully');
    } catch (error) {
      console.error('Error deleting site:', error);
      toast.error('Failed to delete site');
    } finally {
      setSiteToDelete(null);
    }
  };

  const totalWeavers = users.length;
  const validatedEchoes = words.filter(w => w.status === 'validated').length;
  const pendingReviews = words.filter(w => w.status === 'pending').length;

  const stats = [
    { label: 'Total Weavers', val: totalWeavers.toString(), change: '+12%', icon: Users, color: 'text-blue-400' },
    { label: 'Validated Echoes', val: validatedEchoes.toString(), change: '+5%', icon: ShieldCheck, color: 'text-primary' },
    { label: 'Pending Reviews', val: pendingReviews.toString(), change: '-2%', icon: AlertTriangle, color: 'text-terracotta' },
    { label: 'System Health', val: '99.9%', change: 'Stable', icon: Activity, color: 'text-green-400' },
  ];

  const filteredUsers = users.filter(user => 
    (user.displayName || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
    (user.email || '').toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleAction = (action: string) => {
    toast.info(`${action} feature coming soon!`);
  };

  const handleRoleChange = async (userId: string, newRole: string) => {
    try {
      await updateDoc(doc(db, 'users', userId), { role: newRole });
      toast.success('User role updated successfully');
    } catch (error) {
      console.error('Error updating role:', error);
      toast.error('Failed to update user role');
    }
  };

  const [userToDelete, setUserToDelete] = useState<string | null>(null);

  const handleDeleteUser = async (userId: string) => {
    setUserToDelete(userId);
  };

  const confirmDelete = async () => {
    if (!userToDelete) return;
    try {
      await deleteDoc(doc(db, 'users', userToDelete));
      toast.success('User deleted successfully');
    } catch (error) {
      console.error('Error deleting user:', error);
      toast.error('Failed to delete user');
    } finally {
      setUserToDelete(null);
    }
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
            onClick={seedInitialSites}
            className="bg-white/5 border border-white/10 text-cream px-6 py-3 rounded-xl font-bold hover:bg-white/10 transition-all flex items-center gap-2"
          >
            <Globe className="w-4 h-4" />
            Seed Map
          </button>
          <button 
            onClick={() => handleAction('Export Data')}
            aria-label="Export Data"
            className="bg-white/5 border border-white/10 text-cream px-6 py-3 rounded-xl font-bold hover:bg-white/10 transition-all flex items-center gap-2"
          >
            <Database className="w-4 h-4" />
            Export Data
          </button>
          <button 
            onClick={() => setIsAddingSite(true)}
            className="bg-primary text-forest px-6 py-3 rounded-xl font-bold gold-shadow hover:-translate-y-1 active:translate-y-1 transition-all flex items-center gap-2"
          >
            <MapPin className="w-4 h-4" />
            Add Site
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
        {/* Cultural Sites Management */}
        <div className="lg:col-span-12 bg-surface-low border border-white/5 rounded-[2.5rem] p-8">
          <div className="flex items-center justify-between mb-8">
            <div>
              <h3 className="text-2xl font-bold text-cream">Ancestral Map Management</h3>
              <p className="text-sm text-cream/40">Manage sacred sites and ancestral domains displayed on the interactive map.</p>
            </div>
            <div className="flex items-center gap-4">
              <div className="text-right">
                <div className="text-2xl font-black text-primary">{culturalSites.length}</div>
                <div className="text-[10px] font-black uppercase tracking-widest text-cream/20">Total Sites</div>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {culturalSites.map((site) => (
              <div key={site.id} className="bg-white/5 border border-white/10 rounded-3xl p-6 hover:border-primary/30 transition-all group relative">
                {siteToDelete === site.id ? (
                  <div className="absolute inset-0 bg-forest/90 backdrop-blur-sm rounded-3xl z-20 flex flex-col items-center justify-center p-6 text-center">
                    <p className="text-sm font-bold text-cream mb-4">Delete this site?</p>
                    <div className="flex gap-2">
                      <button 
                        onClick={confirmDeleteSite}
                        className="px-4 py-2 bg-terracotta text-white text-[10px] font-black rounded-xl uppercase tracking-widest hover:bg-terracotta/80 transition-all"
                      >
                        Confirm
                      </button>
                      <button 
                        onClick={() => setSiteToDelete(null)}
                        className="px-4 py-2 bg-white/10 text-cream/40 text-[10px] font-black rounded-xl uppercase tracking-widest hover:bg-white/20 transition-all"
                      >
                        Cancel
                      </button>
                    </div>
                  </div>
                ) : (
                  <button 
                    onClick={() => handleDeleteSite(site.id)}
                    className="absolute top-4 right-4 p-2 bg-terracotta/10 text-terracotta rounded-lg opacity-0 group-hover:opacity-100 transition-opacity hover:bg-terracotta/20"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                )}
                <div className="flex items-center gap-3 mb-4">
                  <div className="w-10 h-10 bg-primary/10 rounded-xl flex items-center justify-center text-primary">
                    <MapPin className="w-5 h-5" />
                  </div>
                  <div>
                    <h4 className="font-bold text-cream">{site.name}</h4>
                    <p className="text-[10px] font-black uppercase tracking-widest text-cream/40">{site.type}</p>
                  </div>
                </div>
                <div className="space-y-3 mb-6">
                  <div className="flex items-center justify-between">
                    <span className="text-[10px] font-black uppercase tracking-widest text-cream/20">Community</span>
                    <span className="text-xs font-bold text-cream">{site.community}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-[10px] font-black uppercase tracking-widest text-cream/20">Coordinates</span>
                    <span className="text-xs font-mono text-cream/60">{site.coords[0].toFixed(2)}, {site.coords[1].toFixed(2)}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-[10px] font-black uppercase tracking-widest text-cream/20">Status</span>
                    <span className={`text-[10px] font-black uppercase px-2 py-0.5 rounded-full ${
                      site.status === 'Active' ? 'bg-green-500/10 text-green-400' : 'bg-primary/10 text-primary'
                    }`}>{site.status}</span>
                  </div>
                </div>
                <p className="text-xs text-cream/40 line-clamp-2 italic">"{site.description}"</p>
              </div>
            ))}
            
            <button 
              onClick={() => setIsAddingSite(true)}
              className="border-2 border-dashed border-white/10 rounded-3xl p-6 flex flex-col items-center justify-center gap-3 hover:border-primary/30 hover:bg-white/5 transition-all text-cream/20 hover:text-primary group"
            >
              <div className="w-12 h-12 rounded-full border-2 border-dashed border-current flex items-center justify-center group-hover:scale-110 transition-transform">
                <Plus className="w-6 h-6" />
              </div>
              <span className="font-bold uppercase tracking-widest text-xs">Add New Site</span>
            </button>
          </div>
        </div>

        {/* User Management Table */}
        <div className="lg:col-span-8 bg-surface-low border border-white/5 rounded-[2.5rem] p-8">
          <div className="flex items-center justify-between mb-8">
            <h3 className="text-2xl font-bold text-cream">Member Management</h3>
            <div className="relative group">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-cream/20 group-focus-within:text-primary transition-colors" />
              <input 
                type="text" 
                placeholder="Search members..." 
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
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
                {filteredUsers.map((user) => (
                  <tr key={user.id} className="group hover:bg-white/5 transition-colors">
                    <td className="py-4 px-4">
                      <div className="flex items-center gap-3">
                        <img src={`https://api.dicebear.com/7.x/avataaars/svg?seed=${user.uid}`} className="w-10 h-10 rounded-full border border-white/10 bg-forest" referrerPolicy="no-referrer" alt="Avatar" />
                        <div>
                          <p className="text-sm font-bold text-cream">{user.displayName || 'Unknown User'}</p>
                          <p className="text-xs text-cream/40">{user.email || 'No email'}</p>
                        </div>
                      </div>
                    </td>
                    <td className="py-4 px-4">
                      <select 
                        value={user.role || 'learner'}
                        onChange={(e) => handleRoleChange(user.id, e.target.value)}
                        className={`text-[10px] font-black px-2.5 py-1 rounded-full uppercase tracking-widest outline-none cursor-pointer ${
                          user.role === 'validator' ? 'bg-primary/10 text-primary border border-primary/20' :
                          user.role === 'contributor' ? 'bg-blue-500/10 text-blue-400 border border-blue-500/20' : 
                          user.role === 'admin' ? 'bg-terracotta/10 text-terracotta border border-terracotta/20' :
                          'bg-white/10 text-cream/40 border border-white/10'
                        }`}
                      >
                        <option value="learner" className="bg-forest text-cream">Learner</option>
                        <option value="contributor" className="bg-forest text-cream">Contributor</option>
                        <option value="validator" className="bg-forest text-cream">Validator</option>
                        <option value="admin" className="bg-forest text-cream">Admin</option>
                      </select>
                    </td>
                    <td className="py-4 px-4">
                      <div className="flex items-center gap-2">
                        <div className={`w-1.5 h-1.5 rounded-full ${user.lastActive ? 'bg-green-400 animate-pulse' : 'bg-cream/20'}`}></div>
                        <span className="text-xs font-bold text-cream/60">{user.lastActive ? 'Active' : 'Inactive'}</span>
                      </div>
                    </td>
                    <td className="py-4 px-4">
                      <div className="flex items-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                        {userToDelete === user.id ? (
                          <div className="flex items-center gap-2">
                            <button 
                              onClick={confirmDelete}
                              className="px-3 py-1 bg-terracotta text-white text-[10px] font-black rounded-lg uppercase tracking-widest hover:bg-terracotta/80 transition-all"
                            >
                              Confirm
                            </button>
                            <button 
                              onClick={() => setUserToDelete(null)}
                              className="px-3 py-1 bg-white/5 text-cream/40 text-[10px] font-black rounded-lg uppercase tracking-widest hover:bg-white/10 transition-all"
                            >
                              Cancel
                            </button>
                          </div>
                        ) : (
                          <button 
                            onClick={() => handleDeleteUser(user.id)}
                            aria-label={`Delete ${user.displayName}`}
                            className="p-2 hover:bg-white/10 rounded-lg text-cream/40 hover:text-terracotta transition-colors"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        )}
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

      <AnimatePresence>
        {isAddingSite && (
          <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-[100] flex items-center justify-center px-4"
          >
            <div 
              onClick={() => setIsAddingSite(false)}
              className="absolute inset-0 bg-forest/80 backdrop-blur-md"
            />
            <motion.div 
              initial={{ opacity: 0, scale: 0.95, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: 20 }}
              className="relative w-full max-w-2xl bg-surface-high border border-white/10 rounded-[2.5rem] p-8 shadow-2xl overflow-y-auto max-h-[90vh]"
            >
              <div className="flex items-center justify-between mb-8">
                <h3 className="text-2xl font-bold text-cream">Add Cultural Site</h3>
                <button 
                  onClick={() => setIsAddingSite(false)}
                  className="p-2 hover:bg-white/5 rounded-full transition-colors"
                >
                  <X className="w-5 h-5 text-cream/40" />
                </button>
              </div>
              
              <form onSubmit={handleAddSite} className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="space-y-2">
                    <label className="text-[10px] font-black uppercase tracking-widest text-cream/40 px-2">Site Name</label>
                    <input 
                      required
                      type="text" 
                      value={newSite.name}
                      onChange={(e) => setNewSite({...newSite, name: e.target.value})}
                      placeholder="e.g. Mainit Hot Springs"
                      className="w-full bg-white/5 border border-white/10 rounded-2xl p-4 text-cream font-bold outline-none focus:border-primary/30 transition-all"
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-[10px] font-black uppercase tracking-widest text-cream/40 px-2">Community</label>
                    <select 
                      value={newSite.community}
                      onChange={(e) => setNewSite({...newSite, community: e.target.value})}
                      className="w-full bg-white/5 border border-white/10 rounded-2xl p-4 text-cream font-bold outline-none focus:border-primary/30 transition-all"
                    >
                      {['Mansaka', 'Mandaya', 'Tboli', 'Bagobo', 'Blaan'].map(c => (
                        <option key={c} value={c} className="bg-forest">{c}</option>
                      ))}
                    </select>
                  </div>
                  <div className="space-y-2">
                    <label className="text-[10px] font-black uppercase tracking-widest text-cream/40 px-2">Site Type</label>
                    <input 
                      required
                      type="text" 
                      value={newSite.type}
                      onChange={(e) => setNewSite({...newSite, type: e.target.value})}
                      placeholder="e.g. Sacred Site"
                      className="w-full bg-white/5 border border-white/10 rounded-2xl p-4 text-cream font-bold outline-none focus:border-primary/30 transition-all"
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-[10px] font-black uppercase tracking-widest text-cream/40 px-2">Status</label>
                    <input 
                      required
                      type="text" 
                      value={newSite.status}
                      onChange={(e) => setNewSite({...newSite, status: e.target.value})}
                      placeholder="e.g. Active"
                      className="w-full bg-white/5 border border-white/10 rounded-2xl p-4 text-cream font-bold outline-none focus:border-primary/30 transition-all"
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-[10px] font-black uppercase tracking-widest text-cream/40 px-2">Latitude</label>
                    <input 
                      required
                      type="number" 
                      step="0.000001"
                      value={newSite.coords[0]}
                      onChange={(e) => setNewSite({...newSite, coords: [parseFloat(e.target.value), newSite.coords[1]]})}
                      className="w-full bg-white/5 border border-white/10 rounded-2xl p-4 text-cream font-bold outline-none focus:border-primary/30 transition-all"
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-[10px] font-black uppercase tracking-widest text-cream/40 px-2">Longitude</label>
                    <input 
                      required
                      type="number" 
                      step="0.000001"
                      value={newSite.coords[1]}
                      onChange={(e) => setNewSite({...newSite, coords: [newSite.coords[0], parseFloat(e.target.value)]})}
                      className="w-full bg-white/5 border border-white/10 rounded-2xl p-4 text-cream font-bold outline-none focus:border-primary/30 transition-all"
                    />
                  </div>
                </div>
                
                <div className="space-y-2">
                  <label className="text-[10px] font-black uppercase tracking-widest text-cream/40 px-2">Description</label>
                  <textarea 
                    required
                    value={newSite.description}
                    onChange={(e) => setNewSite({...newSite, description: e.target.value})}
                    rows={4}
                    placeholder="Describe the cultural significance of this site..."
                    className="w-full bg-white/5 border border-white/10 rounded-2xl p-4 text-cream font-bold outline-none focus:border-primary/30 transition-all resize-none"
                  />
                </div>

                <button 
                  type="submit"
                  className="w-full bg-primary text-forest py-5 rounded-2xl font-black uppercase tracking-widest gold-shadow hover:-translate-y-1 transition-all"
                >
                  Create Site
                </button>
              </form>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
};

export default AdminDashboard;

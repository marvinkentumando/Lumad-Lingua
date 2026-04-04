import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Users, User, Bell, Lock } from 'lucide-react';

interface SignupProps {
  onSignup: () => void;
  onBackToLogin: () => void;
}

const Signup: React.FC<SignupProps> = ({ onSignup, onBackToLogin }) => {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  return (
    <div className="min-h-screen bg-forest flex items-center justify-center p-6 relative overflow-hidden">
      <div className="absolute top-0 left-0 w-full h-full pointer-events-none">
        <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-primary/10 rounded-full blur-[120px]"></div>
        <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] bg-terracotta/10 rounded-full blur-[120px]"></div>
      </div>

      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="w-full max-w-md bg-surface-low border border-white/10 rounded-[3rem] p-10 md:p-12 relative z-10 shadow-2xl"
      >
        <div className="text-center mb-10">
          <div className="w-20 h-20 bg-primary/10 rounded-[2rem] flex items-center justify-center mx-auto mb-6 gold-shadow">
            <Users className="w-10 h-10 text-primary" />
          </div>
          <h1 className="text-4xl font-headline font-bold text-cream mb-2">Join the Tribe</h1>
          <p className="text-cream/40 font-medium">Start your journey as a weaver of echoes</p>
        </div>

        <form 
          onSubmit={(e) => { e.preventDefault(); onSignup(); }}
          className="space-y-5"
        >
          <div className="space-y-2">
            <label className="text-[10px] font-black uppercase tracking-[0.2em] text-cream/30 ml-4">Full Name</label>
            <div className="relative group">
              <div className="absolute inset-y-0 left-5 flex items-center pointer-events-none">
                <User className="w-5 h-5 text-cream/20 group-focus-within:text-primary transition-colors" />
              </div>
              <input 
                type="text" 
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
                className="w-full bg-white/5 border-2 border-transparent rounded-2xl py-4 pl-14 pr-6 text-cream placeholder:text-cream/20 focus:border-primary/30 focus:bg-white/10 transition-all outline-none"
                placeholder="Datu Lumad"
              />
            </div>
          </div>

          <div className="space-y-2">
            <label className="text-[10px] font-black uppercase tracking-[0.2em] text-cream/30 ml-4">Weaver Email</label>
            <div className="relative group">
              <div className="absolute inset-y-0 left-5 flex items-center pointer-events-none">
                <Bell className="w-5 h-5 text-cream/20 group-focus-within:text-primary transition-colors" />
              </div>
              <input 
                type="email" 
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                className="w-full bg-white/5 border-2 border-transparent rounded-2xl py-4 pl-14 pr-6 text-cream placeholder:text-cream/20 focus:border-primary/30 focus:bg-white/10 transition-all outline-none"
                placeholder="weaver@ancestry.com"
              />
            </div>
          </div>

          <div className="space-y-2">
            <label className="text-[10px] font-black uppercase tracking-[0.2em] text-cream/30 ml-4">Secret Echo</label>
            <div className="relative group">
              <div className="absolute inset-y-0 left-5 flex items-center pointer-events-none">
                <Lock className="w-5 h-5 text-cream/20 group-focus-within:text-primary transition-colors" />
              </div>
              <input 
                type="password" 
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                className="w-full bg-white/5 border-2 border-transparent rounded-2xl py-4 pl-14 pr-6 text-cream placeholder:text-cream/20 focus:border-primary/30 focus:bg-white/10 transition-all outline-none"
                placeholder="••••••••"
              />
            </div>
          </div>

          <button 
            type="submit"
            className="w-full bg-primary text-forest py-5 rounded-2xl font-black uppercase tracking-widest gold-shadow hover:-translate-y-1 active:translate-y-1 transition-all mt-4"
          >
            Create Account
          </button>
        </form>

        <div className="mt-10 text-center">
          <p className="text-cream/40 text-sm">
            Already a weaver? <button onClick={onBackToLogin} className="text-primary font-bold hover:underline">Login here</button>
          </p>
        </div>
      </motion.div>
    </div>
  );
};

export default Signup;

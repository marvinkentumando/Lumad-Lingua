import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { TreePine, User, Lock } from 'lucide-react';

interface LoginProps {
  onLogin: () => void;
  onGoToSignup: () => void;
}

const Login: React.FC<LoginProps> = ({ onLogin, onGoToSignup }) => {
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
        <div className="text-center mb-12">
          <div className="w-20 h-20 bg-primary/10 rounded-[2rem] flex items-center justify-center mx-auto mb-6 gold-shadow">
            <TreePine className="w-10 h-10 text-primary" />
          </div>
          <h1 className="text-4xl font-headline font-bold text-cream mb-2">Lumad Lingua</h1>
          <p className="text-cream/40 font-medium">Enter the canopy of ancestral echoes</p>
        </div>

        <div className="space-y-6">
          <button 
            onClick={onLogin}
            className="w-full bg-white/5 border border-white/10 text-cream py-5 rounded-2xl font-black uppercase tracking-widest hover:bg-white/10 hover:-translate-y-1 active:translate-y-1 transition-all flex items-center justify-center gap-4 group"
          >
            <img src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg" className="w-6 h-6" alt="Google" />
            <span>Sign in with Google</span>
          </button>
          
          <div className="relative py-4">
            <div className="absolute inset-0 flex items-center"><div className="w-full border-t border-white/5"></div></div>
            <div className="relative flex justify-center text-[10px] uppercase tracking-widest font-black text-cream/20">
              <span className="bg-surface-low px-4">Traditional Weaver Access</span>
            </div>
          </div>

          <div className="space-y-4 opacity-40 pointer-events-none">
            <div className="space-y-2">
              <label className="text-[10px] font-black uppercase tracking-[0.2em] text-cream/30 ml-4">Weaver Email</label>
              <div className="relative">
                <div className="absolute inset-y-0 left-5 flex items-center"><User className="w-5 h-5 text-cream/20" /></div>
                <input disabled className="w-full bg-white/5 border-2 border-transparent rounded-2xl py-4 pl-14 pr-6 text-cream outline-none" placeholder="weaver@ancestry.com" />
              </div>
            </div>
            <p className="text-center text-[10px] text-cream/20 font-bold italic">Email login coming soon to the tribe</p>
          </div>
        </div>

        <div className="mt-10 text-center">
          <p className="text-cream/40 text-sm">
            New to the tribe? <button onClick={onGoToSignup} className="text-primary font-bold hover:underline">Join the Weavers</button>
          </p>
        </div>
      </motion.div>
    </div>
  );
};

export default Login;

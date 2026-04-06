import React, { useState, useEffect } from 'react';
import { Zap, Flame, Sparkles, Bell, Settings, Wifi, WifiOff, Book, PlayCircle, Heart } from 'lucide-react';
import NotificationPanel from './NotificationPanel';
import { useFirebase } from '../../Contexts/FirebaseContext';

interface HeaderProps {
  xp: number;
  streak: number;
  level: number;
}

const Header: React.FC<HeaderProps> = ({ xp, streak, level }) => {
  const { profile } = useFirebase();
  const [isOnline, setIsOnline] = useState(true);
  const [isNotificationOpen, setIsNotificationOpen] = useState(false);

  useEffect(() => {
    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  return (
    <header className="fixed top-0 left-0 right-0 h-20 md:h-24 bg-forest/80 backdrop-blur-xl border-b border-white/5 z-50 px-4 md:px-8 flex items-center justify-between">
      <div className="flex items-center gap-4 md:gap-12">
        <div className="flex items-center gap-2 md:gap-3">
          <div className="w-8 h-8 md:w-10 md:h-10 bg-primary rounded-xl flex items-center justify-center gold-shadow">
            <Sparkles className="w-5 h-5 md:w-6 md:h-6 text-forest" />
          </div>
          <div className="flex flex-col">
            <span className="text-lg md:text-xl font-headline font-bold text-cream tracking-tight leading-none">Lumad Lingua</span>
            <div className="flex items-center gap-1 mt-1">
              {isOnline ? (
                <div className="flex items-center gap-1">
                  <div className="w-1 h-1 md:w-1.5 md:h-1.5 bg-green-500 rounded-full animate-pulse"></div>
                  <span className="text-[7px] md:text-[8px] font-black uppercase tracking-widest text-green-500/60">Offline Ready</span>
                </div>
              ) : (
                <div className="flex items-center gap-1">
                  <div className="w-1 h-1 md:w-1.5 md:h-1.5 bg-orange-500 rounded-full"></div>
                  <span className="text-[7px] md:text-[8px] font-black uppercase tracking-widest text-orange-500/60">Offline Mode</span>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      <div className="flex items-center gap-3 md:gap-6">
        <div className="flex items-center gap-2 md:gap-4 bg-white/5 border border-white/10 rounded-xl md:rounded-2xl px-2 md:px-4 py-1.5 md:py-2">
          <div className="flex items-center gap-1.5 md:gap-2 border-r border-white/10 pr-2 md:pr-4">
            <Zap className="w-3.5 h-3.5 md:w-4 md:h-4 text-primary fill-current" />
            <span className="text-xs md:text-sm font-black text-cream">{xp.toLocaleString()}</span>
          </div>
          <div className="hidden sm:flex items-center gap-1.5 md:gap-2 border-r border-white/10 pr-2 md:pr-4">
            <Flame className="w-3.5 h-3.5 md:w-4 md:h-4 text-terracotta fill-current" />
            <span className="text-xs md:text-sm font-black text-cream">{streak}d</span>
          </div>
          <div className="hidden lg:flex items-center gap-1.5 md:gap-2 border-r border-white/10 pr-2 md:pr-4">
            <Heart className="w-3.5 h-3.5 md:w-4 md:h-4 text-red-500 fill-current" />
            <span className="text-xs md:text-sm font-black text-cream">{profile?.lives ?? 5}/5</span>
          </div>
          <div className="flex items-center gap-1.5 md:gap-2">
            <div className="w-5 h-5 md:w-6 md:h-6 bg-blue-500/20 rounded-lg flex items-center justify-center">
              <span className="text-[9px] md:text-[10px] font-black text-blue-400">{level}</span>
            </div>
            <span className="hidden sm:inline text-[9px] md:text-[10px] font-black text-cream/40 uppercase tracking-widest">Level</span>
          </div>
        </div>

        <div className="flex items-center gap-2 md:gap-3">
          <div className="relative">
            <button 
              onClick={() => setIsNotificationOpen(!isNotificationOpen)}
              className="w-10 h-10 md:w-11 md:h-11 bg-white/5 border border-white/10 rounded-xl flex items-center justify-center text-cream/40 hover:text-primary hover:bg-primary/10 transition-all active:scale-95 relative min-h-[40px] min-w-[40px]"
            >
              <Bell className="w-4 h-4 md:w-5 md:h-5" />
              <div className="absolute top-2 right-2 md:top-2.5 md:right-2.5 w-1.5 h-1.5 md:w-2 md:h-2 bg-terracotta rounded-full border-2 border-forest"></div>
            </button>
            <NotificationPanel isOpen={isNotificationOpen} onClose={() => setIsNotificationOpen(false)} />
          </div>
          <button className="hidden sm:flex w-10 h-10 md:w-11 md:h-11 bg-white/5 border border-white/10 rounded-xl items-center justify-center text-cream/40 hover:text-primary hover:bg-primary/10 transition-all min-h-[40px] min-w-[40px]">
            <Settings className="w-4 h-4 md:w-5 md:h-5" />
          </button>
          <div className="w-10 h-10 md:w-11 md:h-11 rounded-xl border-2 border-primary p-0.5 gold-shadow cursor-pointer hover:scale-105 transition-transform min-h-[40px] min-w-[40px]">
            <img 
              src="https://picsum.photos/seed/elderweaver/100/100" 
              alt="Profile" 
              className="w-full h-full object-cover rounded-lg"
              referrerPolicy="no-referrer"
            />
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;

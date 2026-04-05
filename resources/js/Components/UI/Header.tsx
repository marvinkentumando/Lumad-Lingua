import React, { useState, useEffect } from 'react';
import { Search, Zap, Flame, Sparkles, Bell, Settings, Wifi, WifiOff, Book, PlayCircle, Heart } from 'lucide-react';
import NotificationPanel from './NotificationPanel';

interface HeaderProps {
  onSearch: (query: string) => void;
  searchQuery?: string;
  searchResults?: any[];
  onSearchResultClick?: (result: any) => void;
  xp: number;
  streak: number;
  level: number;
}

const Header: React.FC<HeaderProps> = ({ onSearch, searchQuery, searchResults, onSearchResultClick, xp, streak, level }) => {
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
    <header className="fixed top-0 left-0 right-0 h-24 bg-forest/80 backdrop-blur-xl border-b border-white/5 z-50 px-8 flex items-center justify-between">
      <div className="flex items-center gap-12">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-primary rounded-xl flex items-center justify-center gold-shadow">
            <Sparkles className="w-6 h-6 text-forest" />
          </div>
          <div className="flex flex-col">
            <span className="text-xl font-headline font-bold text-cream tracking-tight leading-none">Lumad Lingua</span>
            <div className="flex items-center gap-1 mt-1">
              {isOnline ? (
                <div className="flex items-center gap-1">
                  <div className="w-1.5 h-1.5 bg-green-500 rounded-full animate-pulse"></div>
                  <span className="text-[8px] font-black uppercase tracking-widest text-green-500/60">Offline Ready</span>
                </div>
              ) : (
                <div className="flex items-center gap-1">
                  <div className="w-1.5 h-1.5 bg-orange-500 rounded-full"></div>
                  <span className="text-[8px] font-black uppercase tracking-widest text-orange-500/60">Offline Mode</span>
                </div>
              )}
            </div>
          </div>
        </div>

        <div className="hidden lg:flex relative group">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-cream/30 group-focus-within:text-primary transition-colors" />
          <input 
            type="text" 
            value={searchQuery || ''}
            placeholder="Search the canopy..." 
            onChange={(e) => onSearch(e.target.value)}
            className="bg-white/5 border border-white/10 rounded-xl py-2.5 pl-11 pr-6 text-sm text-cream placeholder:text-cream/30 focus:ring-2 focus:ring-primary/20 focus:border-primary/30 transition-all w-80"
          />
          {searchResults && searchResults.length > 0 && (
            <div className="absolute top-full left-0 right-0 mt-2 bg-surface-high border border-white/10 rounded-xl overflow-hidden shadow-2xl z-50">
              {searchResults.map((result, idx) => (
                <button
                  key={idx}
                  onClick={() => onSearchResultClick && onSearchResultClick(result)}
                  className="w-full flex items-center gap-3 p-3 hover:bg-white/5 transition-colors text-left border-b border-white/5 last:border-0"
                >
                  {result.type === 'Dictionary' ? <Book className="w-4 h-4 text-primary" /> : <PlayCircle className="w-4 h-4 text-green-400" />}
                  <div>
                    <div className="text-sm font-bold text-cream">{result.term}</div>
                    <div className="text-[10px] text-cream/40">{result.desc}</div>
                  </div>
                </button>
              ))}
            </div>
          )}
        </div>
      </div>

      <div className="flex items-center gap-6">
        <div className="hidden md:flex items-center gap-4 bg-white/5 border border-white/10 rounded-2xl px-4 py-2">
          <div className="flex items-center gap-2 border-r border-white/10 pr-4">
            <Zap className="w-4 h-4 text-primary fill-current" />
            <span className="text-sm font-black text-cream">{xp.toLocaleString()}</span>
          </div>
          <div className="flex items-center gap-2 border-r border-white/10 pr-4">
            <Flame className="w-4 h-4 text-terracotta fill-current" />
            <span className="text-sm font-black text-cream">{streak}d</span>
          </div>
          <div className="flex items-center gap-2 border-r border-white/10 pr-4">
            <Heart className="w-4 h-4 text-red-500 fill-current" />
            <span className="text-sm font-black text-cream">5/5</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-6 h-6 bg-blue-500/20 rounded-lg flex items-center justify-center">
              <span className="text-[10px] font-black text-blue-400">{level}</span>
            </div>
            <span className="text-[10px] font-black text-cream/40 uppercase tracking-widest">Level</span>
          </div>
        </div>

        <div className="flex items-center gap-3">
          <div className="relative">
            <button 
              onClick={() => setIsNotificationOpen(!isNotificationOpen)}
              className="w-11 h-11 bg-white/5 border border-white/10 rounded-xl flex items-center justify-center text-cream/40 hover:text-primary hover:bg-primary/10 transition-all active:scale-95 relative min-h-[44px] min-w-[44px]"
            >
              <Bell className="w-5 h-5" />
              <div className="absolute top-2.5 right-2.5 w-2 h-2 bg-terracotta rounded-full border-2 border-forest"></div>
            </button>
            <NotificationPanel isOpen={isNotificationOpen} onClose={() => setIsNotificationOpen(false)} />
          </div>
          <button className="w-11 h-11 bg-white/5 border border-white/10 rounded-xl flex items-center justify-center text-cream/40 hover:text-primary hover:bg-primary/10 transition-all min-h-[44px] min-w-[44px]">
            <Settings className="w-5 h-5" />
          </button>
          <div className="w-11 h-11 rounded-xl border-2 border-primary p-0.5 gold-shadow cursor-pointer hover:scale-105 transition-transform min-h-[44px] min-w-[44px]">
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

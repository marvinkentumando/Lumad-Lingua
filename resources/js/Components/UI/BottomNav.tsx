import React from 'react';
import { Home, Map as MapIcon, BookOpen, GraduationCap, User, Shield, Users, CheckCircle2 } from 'lucide-react';
import { Role, Screen } from '../../types';

interface BottomNavProps {
  active: Screen;
  setActive: (screen: Screen) => void;
  userRole: Role;
}

const BottomNav: React.FC<BottomNavProps> = ({ active, setActive, userRole }) => {
  const navItems = [
    { id: 'home', label: 'Home', icon: Home },
  ];

  if (userRole === 'admin') {
    navItems.push({ id: 'admin', label: 'Council', icon: Shield });
    navItems.push({ id: 'contributor', label: 'Loom', icon: Users });
    navItems.push({ id: 'validator', label: 'Echo', icon: CheckCircle2 });
    navItems.push({ id: 'educator', label: 'Library', icon: GraduationCap });
  } else if (userRole === 'contributor') {
    navItems.push({ id: 'contributor', label: 'Loom', icon: Users });
  } else if (userRole === 'validator') {
    navItems.push({ id: 'validator', label: 'Echo', icon: CheckCircle2 });
  } else if (userRole === 'educator') {
    navItems.push({ id: 'educator', label: 'Library', icon: GraduationCap });
  }

  navItems.push(
    { id: 'map', label: 'Map', icon: MapIcon },
    { id: 'dictionary', label: 'Canopy', icon: BookOpen },
    { id: 'learn', label: 'Ascent', icon: GraduationCap },
    { id: 'profile', label: 'Weaver', icon: User },
  );

  return (
    <nav className="fixed bottom-0 left-0 right-0 h-20 md:h-24 bg-forest/80 backdrop-blur-xl border-t border-white/5 z-50 px-4 flex items-center overflow-x-auto hide-scrollbar">
      <div className="flex items-center gap-3 sm:gap-8 justify-start sm:justify-center mx-auto px-4 min-w-max sm:min-w-0">
        {navItems.map((item) => (
          <button 
            key={item.id}
            onClick={() => setActive(item.id as Screen)}
            className={`flex flex-col items-center gap-1.5 md:gap-2 transition-all group relative min-h-[44px] min-w-[44px] ${
              active === item.id ? 'text-primary' : 'text-cream/30 hover:text-cream/60'
            }`}
          >
            {active === item.id && (
              <div className="absolute -top-6 md:-top-8 left-1/2 -translate-x-1/2 w-10 md:w-12 h-1 bg-primary rounded-full gold-shadow"></div>
            )}
            <item.icon className={`w-5 h-5 md:w-6 md:h-6 ${active === item.id ? 'fill-current' : ''}`} />
            <span className="text-[9px] md:text-[10px] font-black uppercase tracking-widest whitespace-nowrap">{item.label}</span>
          </button>
        ))}
      </div>
    </nav>
  );
};

export default BottomNav;

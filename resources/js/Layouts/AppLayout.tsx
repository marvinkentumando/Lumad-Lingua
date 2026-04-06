import React from 'react';
import Header from '../Components/UI/Header';
import BottomNav from '../Components/UI/BottomNav';
import { Role, Screen } from '../types';

interface AppLayoutProps {
  children: React.ReactNode;
  activeScreen: Screen;
  setActiveScreen: (screen: Screen) => void;
  userRole: Role;
  xp: number;
  streak: number;
  level: number;
}

const AppLayout: React.FC<AppLayoutProps> = ({ 
  children, 
  activeScreen, 
  setActiveScreen, 
  userRole, 
  xp, 
  streak, 
  level 
}) => {
  return (
    <div className="min-h-screen bg-forest text-cream font-body selection:bg-primary selection:text-forest">
      <Header 
        xp={xp} 
        streak={streak} 
        level={level} 
      />
      
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-24 md:pt-32">
        {children}
      </main>

      <BottomNav active={activeScreen} setActive={setActiveScreen} userRole={userRole} />
    </div>
  );
};

export default AppLayout;

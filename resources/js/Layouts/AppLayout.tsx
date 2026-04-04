import React from 'react';
import Header from '../Components/UI/Header';
import BottomNav from '../Components/UI/BottomNav';
import { Role, Screen } from '../types';

interface AppLayoutProps {
  children: React.ReactNode;
  activeScreen: Screen;
  setActiveScreen: (screen: Screen) => void;
  userRole: Role;
  onSearch: (query: string) => void;
  searchQuery?: string;
  searchResults?: any[];
  onSearchResultClick?: (result: any) => void;
  xp: number;
  streak: number;
  level: number;
}

const AppLayout: React.FC<AppLayoutProps> = ({ 
  children, 
  activeScreen, 
  setActiveScreen, 
  userRole, 
  onSearch, 
  searchQuery,
  searchResults,
  onSearchResultClick,
  xp, 
  streak, 
  level 
}) => {
  return (
    <div className="min-h-screen bg-forest text-cream font-body selection:bg-primary selection:text-forest">
      <Header 
        onSearch={onSearch} 
        searchQuery={searchQuery}
        searchResults={searchResults}
        onSearchResultClick={onSearchResultClick}
        xp={xp} 
        streak={streak} 
        level={level} 
      />
      
      <main className="max-w-7xl mx-auto px-6 pt-32">
        {children}
      </main>

      <BottomNav active={activeScreen} setActive={setActiveScreen} userRole={userRole} />
    </div>
  );
};

export default AppLayout;

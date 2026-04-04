import React, { useState, useEffect, useMemo } from 'react';
import { AnimatePresence } from 'framer-motion';
import { BrowserRouter, Routes, Route, Navigate, useNavigate, useLocation } from 'react-router-dom';
import { FirebaseProvider, useFirebase, ErrorBoundary } from '@/resources/js/Contexts/FirebaseContext';
import { Toaster } from 'sonner';

// Types
import { Role, Screen } from '@/resources/js/types';

// Layouts
import AppLayout from '@/resources/js/Layouts/AppLayout';
import GuestLayout from '@/resources/js/Layouts/GuestLayout';

// Pages
import Login from '@/resources/js/Pages/Auth/Login';
import Signup from '@/resources/js/Pages/Auth/Signup';
import Dashboard from '@/resources/js/Pages/Auth/Dashboard';
import Dictionary from '@/resources/js/Pages/Auth/Dictionary';
import Learn from '@/resources/js/Pages/Auth/Learn';
import Lesson from '@/resources/js/Pages/Auth/Lesson';
import Map from '@/resources/js/Pages/Auth/Map';
import Flashcards from '@/resources/js/Pages/Auth/Flashcards';
import Profile from '@/resources/js/Pages/Auth/Profile';
import AdminDashboard from '@/resources/js/Pages/Admin/Dashboard';
import ContributorDashboard from '@/resources/js/Pages/Auth/ContributorDashboard';
import ValidatorDashboard from '@/resources/js/Pages/Auth/ValidatorDashboard';
import Onboarding from '@/resources/js/Pages/Auth/Onboarding';

// Data
import { DICTIONARY_WORDS } from '@/resources/js/constants/dictionaryData';
import { LESSON_DATA } from '@/resources/js/constants/lessonData';

const AppRoutes: React.FC = () => {
  const { user, profile, loading, login, logout, updateProfile } = useFirebase();
  const [isQuizActive, setIsQuizActive] = useState(false);
  const [selectedLessonId, setSelectedLessonId] = useState<string | null>(null);
  const [selectedLessonType, setSelectedLessonType] = useState<string | null>(null);
  const [isSignup, setIsSignup] = useState(false);
  const [globalSearchQuery, setGlobalSearchQuery] = useState('');
  const navigate = useNavigate();
  const location = useLocation();

  // Memoize search results
  const searchResults = useMemo(() => {
    if (globalSearchQuery.trim() === '') return [];
    const dictionaryTerms = DICTIONARY_WORDS.map(w => ({ term: w.term, type: 'Dictionary', desc: w.english }));
    const lessons = Object.entries(LESSON_DATA).flatMap(([id, content]) => 
      content.steps.map(step => ({
        id,
        term: step.title,
        type: 'Lesson',
        desc: content.discussion.title
      }))
    );
    return [...dictionaryTerms, ...lessons].filter(item => 
      item.term.toLowerCase().includes(globalSearchQuery.toLowerCase()) || 
      item.desc.toLowerCase().includes(globalSearchQuery.toLowerCase())
    ).slice(0, 5);
  }, [globalSearchQuery]);

  const handleSearchResultClick = (result: any) => {
    setGlobalSearchQuery('');
    if (result.type === 'Dictionary') {
      navigate('/dictionary');
    } else if (result.type === 'Lesson') {
      navigate('/learn');
      setIsQuizActive(true);
      setSelectedLessonId(result.id);
      setSelectedLessonType('vocab');
    }
  };

  useEffect(() => {
    if (profile && location.pathname === '/') {
      if (profile.role === 'admin') navigate('/admin');
      else if (profile.role === 'contributor') navigate('/contributor');
      else if (profile.role === 'validator') navigate('/validator');
      else navigate('/home');
    }
  }, [profile?.role, location.pathname, navigate]);

  const handleLogin = () => login();
  const handleSignup = () => login();
  const handleLogout = () => {
    logout();
    navigate('/');
  };

  if (loading) {
    return (
      <div className="fixed inset-0 flex items-center justify-center bg-forest">
        <div className="w-12 h-12 border-4 border-primary border-t-transparent rounded-full animate-spin"></div>
      </div>
    );
  }

  if (!user) {
    return (
      <GuestLayout>
        {isSignup ? (
          <Signup onSignup={handleSignup} onBackToLogin={() => setIsSignup(false)} />
        ) : (
          <Login onLogin={handleLogin} onGoToSignup={() => setIsSignup(true)} />
        )}
      </GuestLayout>
    );
  }

  if (profile && !profile.onboarded) {
    return <Onboarding />;
  }

  if (isQuizActive) {
    return (
      <Lesson 
        lessonId={selectedLessonId} 
        lessonType={selectedLessonType}
        onExit={() => {
          setIsQuizActive(false);
          setSelectedLessonId(null);
          setSelectedLessonType(null);
        }} 
      />
    );
  }

  // Determine active screen for AppLayout based on path
  const path = location.pathname.substring(1) || 'home';

  return (
    <AppLayout
      activeScreen={path as Screen}
      setActiveScreen={(screen) => navigate(`/${screen}`)}
      userRole={profile?.role || 'learner'}
      onSearch={setGlobalSearchQuery}
      searchQuery={globalSearchQuery}
      searchResults={searchResults}
      onSearchResultClick={handleSearchResultClick}
      xp={profile?.xp || 0}
      streak={profile?.streak || 0}
      level={profile?.level || 1}
    >
      <AnimatePresence mode="wait">
        {/* @ts-ignore - RoutesProps doesn't explicitly include key but AnimatePresence requires it */}
        <Routes location={location} key={location.pathname}>
          <Route path="/home" element={<Dashboard onContinueAscent={() => navigate('/learn')} />} />
          <Route path="/map" element={<Map />} />
          <Route path="/dictionary" element={<Dictionary />} />
          <Route path="/learn" element={
            <Learn 
              setIsQuizActive={(active, lessonId, lessonType) => {
                setIsQuizActive(active);
                if (lessonId) setSelectedLessonId(lessonId);
                if (lessonType) setSelectedLessonType(lessonType);
              }} 
            />
          } />
          <Route path="/profile" element={
            <Profile 
              userRole={profile?.role || 'learner'} 
              onRoleChange={(role) => updateProfile({ role })} 
              onLogout={handleLogout} 
            />
          } />
          <Route path="/admin" element={<AdminDashboard />} />
          <Route path="/contributor" element={<ContributorDashboard />} />
          <Route path="/validator" element={<ValidatorDashboard />} />
          <Route path="/flashcards" element={<Flashcards />} />
          <Route path="*" element={<Navigate to="/home" replace />} />
        </Routes>
      </AnimatePresence>
    </AppLayout>
  );
};

const App: React.FC = () => {
  return (
    <ErrorBoundary>
      <FirebaseProvider>
        <BrowserRouter>
          <Toaster position="top-right" theme="dark" />
          <AppRoutes />
        </BrowserRouter>
      </FirebaseProvider>
    </ErrorBoundary>
  );
};

export default App;

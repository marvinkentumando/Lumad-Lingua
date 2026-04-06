import * as React from 'react';
import { createContext, useContext, useEffect, useState, ReactNode, Component } from 'react';
import { User, onAuthStateChanged, signInWithPopup, signOut } from 'firebase/auth';
import { doc, onSnapshot, setDoc, getDoc, query, collection, where, orderBy, limit } from 'firebase/firestore';
import { auth, db, googleProvider, handleFirestoreError, OperationType } from '../firebase';
import { Role } from '../types';

interface UserProfile {
  uid: string;
  displayName: string | null;
  email: string | null;
  role: Role;
  xp: number;
  streak: number;
  level: number;
  lives: number;
  lastLifeLostAt?: string;
  artifacts: string[];
  onboarded: boolean;
  completedLessons: string[];
  lastActive: string;
  lastLessonDate?: string;
  masteredCount: number;
  learningCount: number;
  bookmarks: string[];
  mistakes: string[];
  xpHistory?: { day: string; xp: number }[];
  accuracy?: { subject: string; score: number }[];
}

interface Notification {
  id: string;
  userId: string;
  title: string;
  message: string;
  type: 'validation' | 'challenge' | 'system' | 'social';
  read: boolean;
  createdAt: string;
  link?: string;
}

interface FirebaseContextType {
  user: User | null;
  profile: UserProfile | null;
  notifications: Notification[];
  loading: boolean;
  login: () => Promise<void>;
  logout: () => Promise<void>;
  updateProfile: (updates: Partial<UserProfile>) => Promise<void>;
  markNotificationAsRead: (notificationId: string) => Promise<void>;
}

const FirebaseContext = createContext<FirebaseContextType | undefined>(undefined);

export const FirebaseProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let unsubscribeProfile: (() => void) | null = null;
    let unsubscribeNotifications: (() => void) | null = null;

    const unsubscribeAuth = onAuthStateChanged(auth, async (currentUser) => {
      // Cleanup previous listeners
      if (unsubscribeProfile) unsubscribeProfile();
      if (unsubscribeNotifications) unsubscribeNotifications();

      setUser(currentUser);
      if (currentUser) {
        const userDocRef = doc(db, 'users', currentUser.uid);
        
        // Listen for profile changes
        unsubscribeProfile = onSnapshot(userDocRef, (docSnap) => {
          if (docSnap.exists()) {
            const data = docSnap.data();
            let role = data.role;
            if (currentUser.email === 'tumando.marvinken@dnsc.edu.ph' && role !== 'admin') {
              role = 'admin';
              setDoc(userDocRef, { role: 'admin' }, { merge: true }).catch(console.error);
            }

            let streak = data.streak || 0;
            const lastLessonDate = data.lastLessonDate;
            
            if (lastLessonDate) {
              const today = new Date().toISOString().split('T')[0];
              const lastDate = new Date(lastLessonDate.split('T')[0]);
              const currentDate = new Date(today);
              const diffTime = currentDate.getTime() - lastDate.getTime();
              const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

              if (diffDays > 1 && streak > 0) {
                streak = 0;
                setDoc(userDocRef, { streak: 0 }, { merge: true }).catch(console.error);
              }
            }

            // Life Regeneration Logic
            let lives = data.lives ?? 5;
            const lastLifeLostAt = data.lastLifeLostAt;
            if (lives < 5 && lastLifeLostAt) {
              const lastLost = new Date(lastLifeLostAt).getTime();
              const now = new Date().getTime();
              const diffMs = now - lastLost;
              const tenMinutesMs = 10 * 60 * 1000;
              const livesToRegain = Math.floor(diffMs / tenMinutesMs);

              if (livesToRegain > 0) {
                const newLives = Math.min(5, lives + livesToRegain);
                const newLastLifeLostAt = newLives === 5 ? null : new Date(lastLost + (livesToRegain * tenMinutesMs)).toISOString();
                
                lives = newLives;
                setDoc(userDocRef, { 
                  lives: newLives, 
                  lastLifeLostAt: newLastLifeLostAt 
                }, { merge: true }).catch(console.error);
              }
            }

            setProfile({
              ...data,
              role,
              streak,
              lives,
              completedLessons: data.completedLessons || [],
              artifacts: data.artifacts || [],
              masteredCount: data.masteredCount || 0,
              learningCount: data.learningCount || 0,
              bookmarks: data.bookmarks || [],
              mistakes: data.mistakes || [],
            } as UserProfile);
          } else {
            const initialProfile: UserProfile = {
              uid: currentUser.uid,
              displayName: currentUser.displayName,
              email: currentUser.email,
              role: currentUser.email === 'tumando.marvinken@dnsc.edu.ph' ? 'admin' : 'learner',
              xp: 0,
              streak: 0,
              level: 1,
              lives: 5,
              artifacts: [],
              onboarded: false,
              completedLessons: [],
              lastActive: new Date().toISOString(),
              lastLessonDate: '',
              masteredCount: 0,
              learningCount: 0,
              bookmarks: [],
              mistakes: [],
            };
            setDoc(userDocRef, initialProfile).catch(err => handleFirestoreError(err, OperationType.WRITE, `users/${currentUser.uid}`));
          }
          setLoading(false);
        }, (error) => {
          handleFirestoreError(error, OperationType.GET, `users/${currentUser.uid}`);
          setLoading(false);
        });

        // Listen for notifications
        const notificationsQuery = query(
          collection(db, 'notifications'),
          where('userId', '==', currentUser.uid),
          limit(20)
        );
        unsubscribeNotifications = onSnapshot(notificationsQuery, (snapshot) => {
          const notifs = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
          })) as Notification[];
          setNotifications(notifs);
        }, (error) => {
          handleFirestoreError(error, OperationType.GET, 'notifications');
        });
      } else {
        setProfile(null);
        setNotifications([]);
        setLoading(false);
      }
    });

    return () => {
      unsubscribeAuth();
      if (unsubscribeProfile) unsubscribeProfile();
      if (unsubscribeNotifications) unsubscribeNotifications();
    };
  }, []);

  const login = async () => {
    try {
      await signInWithPopup(auth, googleProvider);
    } catch (error) {
      console.error('Login Error:', error);
    }
  };

  const logout = async () => {
    try {
      await signOut(auth);
    } catch (error) {
      console.error('Logout Error:', error);
    }
  };

  const updateProfile = async (updates: Partial<UserProfile>) => {
    if (!user) return;
    const userDocRef = doc(db, 'users', user.uid);
    try {
      await setDoc(userDocRef, { ...updates, lastActive: new Date().toISOString() }, { merge: true });
    } catch (error) {
      handleFirestoreError(error, OperationType.UPDATE, `users/${user.uid}`);
    }
  };

  const markNotificationAsRead = async (notificationId: string) => {
    if (!user) return;
    const notifRef = doc(db, 'notifications', notificationId);
    try {
      await setDoc(notifRef, { read: true }, { merge: true });
    } catch (error) {
      handleFirestoreError(error, OperationType.UPDATE, `notifications/${notificationId}`);
    }
  };

  return (
    <FirebaseContext.Provider value={{ user, profile, notifications, loading, login, logout, updateProfile, markNotificationAsRead }}>
      {children}
    </FirebaseContext.Provider>
  );
};

export const useFirebase = () => {
  const context = useContext(FirebaseContext);
  if (context === undefined) {
    throw new Error('useFirebase must be used within a FirebaseProvider');
  }
  return context;
};

export class ErrorBoundary extends Component<any, any> {
  constructor(props: any) {
    super(props);
    // @ts-ignore
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: any) {
    return { hasError: true, error };
  }

  render() {
    // @ts-ignore
    if (this.state.hasError) {
      let message = "Something went wrong.";
      try {
        // @ts-ignore
        const err = this.state.error;
        if (err && typeof err.message === 'string' && err.message.startsWith('{')) {
          const errInfo = JSON.parse(err.message);
          message = `Firestore Error: ${errInfo.error} during ${errInfo.operationType} on ${errInfo.path}`;
        } else {
          // @ts-ignore
          message = this.state.error?.message || message;
        }
      } catch (e) {
        // @ts-ignore
        message = this.state.error?.message || message;
      }

      return (
        <div className="fixed inset-0 flex items-center justify-center bg-forest p-8 z-[999]">
          <div className="bg-surface-low border border-white/10 p-8 rounded-[2.5rem] max-w-md w-full text-center space-y-6">
            <div className="text-4xl">⚠️</div>
            <h2 className="text-2xl font-bold text-cream">Application Error</h2>
            <p className="text-cream/60 text-sm leading-relaxed">{message}</p>
            <button 
              onClick={() => window.location.reload()}
              className="w-full bg-primary text-forest py-4 rounded-2xl font-black uppercase tracking-widest gold-shadow"
            >
              Reload Application
            </button>
          </div>
        </div>
      );
    }

    // @ts-ignore
    return this.props.children;
  }
}

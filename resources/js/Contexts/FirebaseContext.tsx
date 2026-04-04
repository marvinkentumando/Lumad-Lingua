import * as React from 'react';
import { createContext, useContext, useEffect, useState, ReactNode, Component } from 'react';
import { User, onAuthStateChanged, signInWithPopup, signOut } from 'firebase/auth';
import { doc, onSnapshot, setDoc, getDoc } from 'firebase/firestore';
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
  artifacts: string[];
  onboarded: boolean;
  completedLessons: string[];
  lastActive: string;
}

interface FirebaseContextType {
  user: User | null;
  profile: UserProfile | null;
  loading: boolean;
  login: () => Promise<void>;
  logout: () => Promise<void>;
  updateProfile: (updates: Partial<UserProfile>) => Promise<void>;
}

const FirebaseContext = createContext<FirebaseContextType | undefined>(undefined);

export const FirebaseProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (currentUser) => {
      setUser(currentUser);
      if (currentUser) {
        const userDocRef = doc(db, 'users', currentUser.uid);
        
        // Listen for profile changes
        const unsubscribeProfile = onSnapshot(userDocRef, (docSnap) => {
          if (docSnap.exists()) {
            const data = docSnap.data();
            let role = data.role;
            if (currentUser.email === 'tumando.marvinken@dnsc.edu.ph' && role !== 'admin') {
              role = 'admin';
              setDoc(userDocRef, { role: 'admin' }, { merge: true }).catch(console.error);
            }
            setProfile({
              ...data,
              role,
              completedLessons: data.completedLessons || [],
              artifacts: data.artifacts || [],
            } as UserProfile);
          } else {
            // Create initial profile if it doesn't exist
            const initialProfile: UserProfile = {
              uid: currentUser.uid,
              displayName: currentUser.displayName,
              email: currentUser.email,
              role: currentUser.email === 'tumando.marvinken@dnsc.edu.ph' ? 'admin' : 'learner',
              xp: 0,
              streak: 0,
              level: 1,
              artifacts: [],
              onboarded: false,
              completedLessons: [],
              lastActive: new Date().toISOString(),
            };
            setDoc(userDocRef, initialProfile).catch(err => handleFirestoreError(err, OperationType.WRITE, `users/${currentUser.uid}`));
          }
          setLoading(false);
        }, (error) => {
          handleFirestoreError(error, OperationType.GET, `users/${currentUser.uid}`);
          setLoading(false);
        });

        return () => unsubscribeProfile();
      } else {
        setProfile(null);
        setLoading(false);
      }
    });

    return () => unsubscribe();
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
      await setDoc(userDocRef, { ...profile, ...updates, lastActive: new Date().toISOString() }, { merge: true });
    } catch (error) {
      handleFirestoreError(error, OperationType.UPDATE, `users/${user.uid}`);
    }
  };

  return (
    <FirebaseContext.Provider value={{ user, profile, loading, login, logout, updateProfile }}>
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
        const errInfo = JSON.parse(this.state.error.message);
        message = `Firestore Error: ${errInfo.error} during ${errInfo.operationType} on ${errInfo.path}`;
      } catch (e) {
        // @ts-ignore
        message = this.state.error.message || message;
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

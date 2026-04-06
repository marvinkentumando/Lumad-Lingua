import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Bell, CheckCircle, Trophy, Info, Users } from 'lucide-react';
import { useFirebase } from '../../Contexts/FirebaseContext';

interface NotificationPanelProps {
  isOpen: boolean;
  onClose: () => void;
}

const NotificationPanel: React.FC<NotificationPanelProps> = ({ isOpen, onClose }) => {
  const { notifications, markNotificationAsRead } = useFirebase();

  const getIcon = (type: string) => {
    switch (type) {
      case 'validation': return <CheckCircle className="w-4 h-4 text-green-500" />;
      case 'challenge': return <Trophy className="w-4 h-4 text-primary" />;
      case 'social': return <Users className="w-4 h-4 text-blue-400" />;
      default: return <Info className="w-4 h-4 text-cream/40" />;
    }
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0, y: 10, scale: 0.95 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          exit={{ opacity: 0, y: 10, scale: 0.95 }}
          className="absolute top-16 right-0 w-80 bg-surface-high border border-white/10 rounded-2xl shadow-2xl z-50 overflow-hidden"
        >
          <div className="p-4 border-b border-white/10 flex items-center justify-between">
            <h3 className="font-bold text-cream flex items-center gap-2">
              <Bell className="w-4 h-4 text-primary" /> Notifications
            </h3>
            <button onClick={onClose} className="text-cream/40 hover:text-cream transition-colors">
              <X className="w-4 h-4" />
            </button>
          </div>
          <div className="max-h-[400px] overflow-y-auto">
            {notifications.length === 0 ? (
              <div className="p-8 text-center text-cream/40 text-sm italic">
                No new notifications.
              </div>
            ) : (
              <div className="divide-y divide-white/5">
                {notifications.map((notif) => (
                  <div 
                    key={notif.id} 
                    onClick={() => !notif.read && markNotificationAsRead(notif.id)}
                    className={`p-4 hover:bg-white/5 transition-colors cursor-pointer relative ${!notif.read ? 'bg-primary/5' : ''}`}
                  >
                    {!notif.read && (
                      <div className="absolute top-4 right-4 w-2 h-2 bg-primary rounded-full"></div>
                    )}
                    <div className="flex gap-3">
                      <div className="mt-1">{getIcon(notif.type)}</div>
                      <div className="space-y-1">
                        <div className="text-sm font-bold text-cream">{notif.title}</div>
                        <p className="text-xs text-cream/60 leading-relaxed">{notif.message}</p>
                        <div className="text-[9px] font-black uppercase tracking-widest text-cream/20">
                          {new Date(notif.createdAt).toLocaleDateString()}
                        </div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};

export default NotificationPanel;

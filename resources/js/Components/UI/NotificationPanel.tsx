import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Bell } from 'lucide-react';

interface NotificationPanelProps {
  isOpen: boolean;
  onClose: () => void;
}

const NotificationPanel: React.FC<NotificationPanelProps> = ({ isOpen, onClose }) => {
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
            <button onClick={onClose} className="text-cream/40 hover:text-cream">
              <X className="w-4 h-4" />
            </button>
          </div>
          <div className="p-4 text-center text-cream/40 text-sm">
            No new notifications.
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};

export default NotificationPanel;

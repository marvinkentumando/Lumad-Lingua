import React from 'react';
import { Flame } from 'lucide-react';

interface StreakCalendarProps {
  streak: number;
  lastActive: string;
}

export const StreakCalendar: React.FC<StreakCalendarProps> = ({ streak, lastActive }) => {
  const lastActiveDate = new Date(lastActive);
  const days = Array.from({ length: 7 }, (_, i) => {
    const d = new Date();
    d.setDate(d.getDate() - (6 - i));
    return d;
  });

  return (
    <div className="bg-white/5 border border-white/10 rounded-3xl p-6 space-y-4">
      <div className="flex items-center justify-between">
        <h3 className="text-sm font-black uppercase tracking-widest text-cream/60">Activity</h3>
        <div className="flex items-center gap-2 text-orange-500">
          <Flame className="w-5 h-5 fill-orange-500" />
          <span className="font-bold">{streak} day streak</span>
        </div>
      </div>
      <div className="flex justify-between gap-2">
        {days.map((day, i) => {
          const isPast = day < lastActiveDate;
          const isToday = day.toDateString() === new Date().toDateString();
          const isActive = isToday || (streak > (6 - i) && isPast);

          return (
            <div key={i} className="flex flex-col items-center gap-2">
              <div className={`w-10 h-10 rounded-full flex items-center justify-center border-2 ${isActive ? 'bg-orange-500/20 border-orange-500 text-orange-400' : 'bg-white/5 border-white/5 text-cream/20'}`}>
                {day.getDate()}
              </div>
              <span className="text-[10px] font-mono text-cream/40 uppercase">{day.toLocaleDateString('en-US', { weekday: 'short' })}</span>
            </div>
          );
        })}
      </div>
    </div>
  );
};

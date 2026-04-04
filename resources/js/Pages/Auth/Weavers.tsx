import React from 'react';
import { motion } from 'framer-motion';
import { useFirebase } from '../../Contexts/FirebaseContext';
import { Users, MapPin, Star } from 'lucide-react';

const Weavers: React.FC = () => {
  const { weavers, loading } = useFirebase();

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin"></div>
      </div>
    );
  }

  return (
    <motion.div 
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="pb-32 max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12"
    >
      <div className="flex items-center gap-4 mb-8">
        <div className="w-12 h-12 bg-primary/10 rounded-2xl flex items-center justify-center text-primary gold-shadow">
          <Users className="w-6 h-6" />
        </div>
        <div>
          <h2 className="text-3xl font-serif font-bold text-cream">Master <em className="text-primary italic font-serif">Weavers</em></h2>
          <p className="text-cream/40 text-sm font-medium">Meet the guardians of our ancestral knowledge.</p>
        </div>
      </div>

      {weavers.length === 0 ? (
        <div className="bg-[#2d1b0e] border border-[#4a331c] rounded-lg p-12 text-center">
          <p className="text-cream/60">No master weavers have been added yet.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {weavers.map((weaver) => (
            <div key={weaver.id} className="bg-[#2d1b0e] border border-[#4a331c] rounded-lg overflow-hidden group hover:border-primary/50 transition-colors">
              <div className="h-48 bg-[#1a110a] relative">
                {weaver.imageUrl ? (
                  <img src={weaver.imageUrl} alt={weaver.name} className="w-full h-full object-cover opacity-80 group-hover:opacity-100 transition-opacity" referrerPolicy="no-referrer" />
                ) : (
                  <div className="w-full h-full flex items-center justify-center text-cream/10">
                    <Users className="w-16 h-16" />
                  </div>
                )}
                <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-[#2d1b0e] to-transparent h-24"></div>
              </div>
              
              <div className="p-6 relative -mt-12">
                <div className="bg-[#1a110a] border border-[#4a331c] inline-block px-3 py-1 rounded text-[10px] font-black uppercase tracking-widest text-primary mb-3">
                  {weaver.community}
                </div>
                <h3 className="text-xl font-serif font-bold text-cream mb-2">{weaver.name}</h3>
                
                {weaver.location && (
                  <div className="flex items-center gap-2 text-cream/40 text-xs mb-4">
                    <MapPin className="w-3 h-3" />
                    <span>{weaver.location}</span>
                  </div>
                )}
                
                <p className="text-cream/60 text-sm line-clamp-3 mb-6">
                  {weaver.bio}
                </p>
                
                {weaver.expertise && weaver.expertise.length > 0 && (
                  <div className="space-y-2">
                    <div className="text-[10px] font-black uppercase tracking-widest text-cream/40 flex items-center gap-1">
                      <Star className="w-3 h-3" /> Expertise
                    </div>
                    <div className="flex flex-wrap gap-2">
                      {weaver.expertise.map((exp, i) => (
                         <span key={i} className="bg-white/5 border border-white/10 text-cream/60 px-2 py-1 rounded text-[9px] font-black uppercase tracking-widest">
                           {exp}
                         </span>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      )}
    </motion.div>
  );
};

export default Weavers;

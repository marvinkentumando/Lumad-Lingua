import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  MapPin, 
  Navigation, 
  Info, 
  Users, 
  Volume2, 
  ChevronRight, 
  X, 
  Layers, 
  Maximize2, 
  Minus, 
  Plus, 
  Filter,
  Search,
  Globe,
  Activity
} from 'lucide-react';
import { MapContainer, TileLayer, CircleMarker, Popup, useMap, ZoomControl } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import { collection, onSnapshot, query } from 'firebase/firestore';
import { db } from '../../firebase';
import { toast } from 'sonner';

const Map: React.FC = () => {
  const [selectedLocation, setSelectedLocation] = useState<any>(null);
  const [activeFilter, setActiveFilter] = useState('All');
  const [searchQuery, setSearchQuery] = useState('');
  const [mapLayer, setMapLayer] = useState('dark');
  const [is3D, setIs3D] = useState(false);
  const [locations, setLocations] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const q = query(collection(db, 'cultural_sites'));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const sites = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      setLocations(sites);
      setLoading(false);
    }, (error) => {
      console.error("Error fetching cultural sites:", error);
      toast.error("Failed to load map data");
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const filteredLocations = locations.filter(loc => {
    const matchesFilter = activeFilter === 'All' || loc.community === activeFilter;
    const matchesSearch = loc.name.toLowerCase().includes(searchQuery.toLowerCase()) || 
                         loc.community.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesFilter && matchesSearch;
  });

  const toggleFullscreen = () => {
    if (!document.fullscreenElement) {
      document.documentElement.requestFullscreen().catch(err => {
        toast.error(`Error attempting to enable full-screen mode: ${err.message}`);
      });
    } else {
      document.exitFullscreen();
    }
  };

  const layers = {
    dark: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
    light: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
    satellite: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
  };

  return (
    <motion.div 
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="h-[calc(100vh-14rem)] md:h-[calc(100vh-12rem)] relative rounded-[2.5rem] overflow-hidden border border-white/10 shadow-2xl bg-forest"
    >
      {/* Top Legend / Filter Bar */}
      <div className="absolute top-4 left-4 right-4 z-10 flex flex-col md:flex-row gap-3 pointer-events-none">
        <div className="bg-forest/80 backdrop-blur-xl border border-white/10 p-2 rounded-2xl shadow-2xl flex items-center gap-2 pointer-events-auto overflow-x-auto no-scrollbar max-w-full">
          {['All', 'Mansaka', 'Mandaya', 'Tboli'].map(filter => (
            <button 
              key={filter}
              onClick={() => setActiveFilter(filter)}
              className={`whitespace-nowrap px-4 py-2 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all min-h-[44px] flex items-center gap-2 ${
                activeFilter === filter ? 'bg-primary text-forest gold-shadow' : 'bg-white/5 text-cream/40 hover:bg-white/10'
              }`}
            >
              {filter}
              {filter !== 'All' && (
                <div className={`w-1.5 h-1.5 rounded-full ${filter === 'Mansaka' ? 'bg-primary' : filter === 'Mandaya' ? 'bg-terracotta' : 'bg-blue-400'}`}></div>
              )}
            </button>
          ))}
        </div>
        
        <div className="hidden md:flex bg-forest/80 backdrop-blur-xl border border-white/10 p-2 rounded-2xl shadow-2xl items-center gap-2 pointer-events-auto ml-auto">
          <div className="flex items-center gap-2 px-4 py-2 bg-white/5 rounded-xl border border-white/5">
            <Search className="w-3.5 h-3.5 text-cream/40" />
            <input 
              type="text" 
              placeholder="Search ancestral lands..." 
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="bg-transparent border-none outline-none text-[10px] font-bold text-cream placeholder:text-cream/20 w-40"
            />
          </div>
        </div>
      </div>

      {/* Map Container */}
      <div className={`h-full w-full transition-all duration-700 ${is3D ? '[transform:rotateX(20deg)_rotateZ(-5deg)] scale-110' : ''}`}>
        <MapContainer 
          center={[7.0, 125.5]} 
          zoom={8} 
          className="h-full w-full z-0"
          zoomControl={false}
        >
          <TileLayer
            url={(layers as any)[mapLayer]}
            attribution='&copy; OpenStreetMap contributors'
          />
          {filteredLocations.map(loc => (
            <CircleMarker 
              key={loc.id}
              center={loc.coords as [number, number]}
              radius={14}
              pathOptions={{ 
                fillColor: loc.community === 'Mansaka' ? '#FFC200' : loc.community === 'Mandaya' ? '#FF4D00' : '#60A5FA',
                color: 'white',
                weight: 2,
                fillOpacity: 0.8
              }}
              eventHandlers={{
                click: () => setSelectedLocation(loc)
              }}
            >
              <Popup className="custom-popup">
                <div className="p-2">
                  <div className="font-bold text-forest">{loc.name}</div>
                  <div className="text-xs text-forest/60">{loc.community} Community</div>
                </div>
              </Popup>
            </CircleMarker>
          ))}
          <ZoomControl position="bottomright" />
        </MapContainer>
      </div>

      {/* Right Side Controls */}
      <div className="absolute right-4 top-24 md:top-4 z-10 flex flex-col gap-2">
        <button 
          onClick={() => {
            const nextLayer = mapLayer === 'dark' ? 'light' : mapLayer === 'light' ? 'satellite' : 'dark';
            setMapLayer(nextLayer);
            toast.info(`Switched to ${nextLayer} view`);
          }}
          className={`w-11 h-11 bg-forest/80 backdrop-blur-xl border border-white/10 rounded-xl flex items-center justify-center transition-colors shadow-xl min-h-[44px] min-w-[44px] ${mapLayer !== 'dark' ? 'text-primary' : 'text-cream/60'}`}
          title="Change Layers"
        >
          <Layers className="w-5 h-5" />
        </button>
        <button 
          onClick={() => {
            setIs3D(!is3D);
            toast.info(is3D ? "Switched to 2D view" : "Switched to 3D perspective");
          }}
          className={`w-11 h-11 bg-forest/80 backdrop-blur-xl border border-white/10 rounded-xl flex items-center justify-center transition-colors shadow-xl min-h-[44px] min-w-[44px] ${is3D ? 'text-primary' : 'text-cream/60'}`}
          title="3D View"
        >
          <Globe className="w-5 h-5" />
        </button>
        <button 
          onClick={toggleFullscreen}
          className="w-11 h-11 bg-forest/80 backdrop-blur-xl border border-white/10 rounded-xl flex items-center justify-center text-cream/60 hover:text-primary transition-colors shadow-xl min-h-[44px] min-w-[44px]"
          title="Fullscreen"
        >
          <Maximize2 className="w-5 h-5" />
        </button>
      </div>

      {/* Bottom Stats Bar */}
      <div className="absolute bottom-4 left-4 right-4 z-10 pointer-events-none">
        <div className="bg-forest/80 backdrop-blur-xl border border-white/10 p-4 rounded-[2rem] shadow-2xl flex items-center justify-between pointer-events-auto overflow-x-auto no-scrollbar">
          <div className="flex items-center gap-8 px-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-primary/10 rounded-xl flex items-center justify-center text-primary">
                <Users className="w-5 h-5" />
              </div>
              <div>
                <div className="text-[9px] font-black uppercase tracking-widest text-cream/20">Total Population</div>
                <div className="text-sm font-black text-cream">10,740</div>
              </div>
            </div>
            <div className="hidden sm:flex items-center gap-3">
              <div className="w-10 h-10 bg-terracotta/10 rounded-xl flex items-center justify-center text-terracotta">
                <Globe className="w-5 h-5" />
              </div>
              <div>
                <div className="text-[9px] font-black uppercase tracking-widest text-cream/20">Active Domains</div>
                <div className="text-sm font-black text-cream">14 Sites</div>
              </div>
            </div>
            <div className="hidden md:flex items-center gap-3">
              <div className="w-10 h-10 bg-blue-400/10 rounded-xl flex items-center justify-center text-blue-400">
                <Activity className="w-5 h-5" />
              </div>
              <div>
                <div className="text-[9px] font-black uppercase tracking-widest text-cream/20">Language Health</div>
                <div className="text-sm font-black text-cream">Stable</div>
              </div>
            </div>
          </div>
          
          <div className="flex items-center gap-2">
            <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
            <span className="text-[9px] font-black uppercase tracking-widest text-green-500">Live Updates</span>
          </div>
        </div>
      </div>

      {/* Responsive Ancestral Map Card (Detail Panel) */}
      <AnimatePresence>
        {selectedLocation && (
          <>
            {/* Mobile Backdrop */}
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setSelectedLocation(null)}
              className="absolute inset-0 bg-forest/40 backdrop-blur-sm z-20 md:hidden"
            />
            
            <motion.div 
              initial={{ x: '100%', y: 0 }}
              animate={{ x: 0, y: 0 }}
              exit={{ x: '100%', y: 0 }}
              transition={{ type: 'spring', damping: 25, stiffness: 200 }}
              className="absolute bottom-0 right-0 top-0 w-full md:w-[28rem] bg-forest/95 backdrop-blur-2xl border-l border-white/10 z-30 p-8 md:p-10 shadow-[-20px_0_40px_rgba(0,0,0,0.5)] flex flex-col overflow-y-auto"
            >
              <button 
                onClick={() => setSelectedLocation(null)}
                className="absolute top-6 right-6 p-3 hover:bg-white/5 rounded-full transition-colors min-h-[44px] min-w-[44px] flex items-center justify-center"
              >
                <X className="w-6 h-6 text-cream/40" />
              </button>

              <div className="space-y-10 flex-1">
                <div className="pt-8 md:pt-12">
                  <div className="flex items-center gap-2 text-[10px] font-black uppercase tracking-widest text-primary mb-4">
                    <MapPin className="w-3 h-3" />
                    <span>{selectedLocation.type}</span>
                  </div>
                  <h2 className="text-4xl md:text-5xl font-headline font-bold text-cream leading-tight mb-4">{selectedLocation.name}</h2>
                  <div className="flex flex-wrap items-center gap-3">
                    <div className="bg-primary/10 border border-primary/20 px-3 py-1.5 rounded-lg text-[10px] font-bold text-primary uppercase tracking-widest">
                      {selectedLocation.community}
                    </div>
                    <div className="bg-white/5 border border-white/10 px-3 py-1.5 rounded-lg text-[10px] font-bold text-cream/40 uppercase tracking-widest">
                      {selectedLocation.status}
                    </div>
                  </div>
                </div>

                <p className="text-cream/60 text-sm leading-relaxed">
                  {selectedLocation.description}
                </p>

                <div className="grid grid-cols-2 gap-4">
                  <div className="bg-white/5 border border-white/10 p-6 rounded-[2rem]">
                    <Users className="w-5 h-5 text-primary mb-4" />
                    <div className="text-2xl font-black text-cream">{selectedLocation.population.toLocaleString()}</div>
                    <div className="text-[9px] font-black uppercase tracking-widest text-cream/20">Population</div>
                  </div>
                  <div className="bg-white/5 border border-white/10 p-6 rounded-[2rem]">
                    <Volume2 className="w-5 h-5 text-primary mb-4" />
                    <div className="text-sm font-black text-cream leading-tight">{selectedLocation.dialect}</div>
                    <div className="text-[9px] font-black uppercase tracking-widest text-cream/20">Primary Dialect</div>
                  </div>
                </div>

                <div className="space-y-6">
                  <h4 className="text-[10px] font-black uppercase tracking-widest text-cream/20 border-b border-white/10 pb-2">Community Insights</h4>
                  <div className="space-y-4">
                    {[
                      { label: 'Oral Traditions', val: 'Rich collection of epics and chants recorded here.' },
                      { label: 'Accessibility', val: 'Highland terrain, accessible via traditional trails.' },
                    ].map((insight, i) => (
                      <div key={i} className="space-y-1">
                        <div className="text-xs font-bold text-primary">{insight.label}</div>
                        <p className="text-xs text-cream/60 leading-relaxed">{insight.val}</p>
                      </div>
                    ))}
                  </div>
                </div>

                <div className="pt-4 pb-8">
                  <button 
                    onClick={() => {
                      const [lat, lng] = selectedLocation.coords;
                      window.open(`https://www.google.com/maps/dir/?api=1&destination=${lat},${lng}`, '_blank');
                    }}
                    className="w-full bg-primary text-forest py-5 rounded-2xl font-black uppercase tracking-widest gold-shadow hover:-translate-y-1 transition-all flex items-center justify-center gap-3 min-h-[56px]"
                  >
                    <Navigation className="w-5 h-5" />
                    Navigate to Site
                  </button>
                </div>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </motion.div>
  );
};

export default Map;

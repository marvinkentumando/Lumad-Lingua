import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Sparkles, Globe, Heart, ChevronRight, BookOpen, Users, Volume2 } from 'lucide-react';
import { useFirebase } from '../../Contexts/FirebaseContext';
import { GoogleGenAI, Modality } from "@google/genai";

const Onboarding: React.FC = () => {
  const { updateProfile } = useFirebase();
  const [step, setStep] = useState(0);
  const [dialect, setDialect] = useState('Mansaka');
  const [goal, setGoal] = useState('Cultural Preservation');
  const [isActivated, setIsActivated] = useState(false);
  const [isSpeaking, setIsSpeaking] = useState(false);

  const dialectGreetings: Record<string, string> = {
    'Mansaka': 'Maayong buntag',
    'Mandaya': 'Maayong buntag',
    'Tboli': 'Hyun klowu',
    'Blaan': 'Fye flafus'
  };

  const handleSpeak = async (text: string) => {
    if (isSpeaking) return;
    setIsSpeaking(true);
    
    try {
      const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY! });
      const response = await ai.models.generateContent({
        model: "gemini-2.5-flash-preview-tts",
        contents: [{ parts: [{ text: `Say clearly: ${text}` }] }],
        config: {
          responseModalities: [Modality.AUDIO],
          speechConfig: {
            voiceConfig: {
              prebuiltVoiceConfig: { voiceName: 'Kore' },
            },
          },
        },
      });

      const base64Audio = response.candidates?.[0]?.content?.parts?.[0]?.inlineData?.data;
      if (base64Audio) {
        const binaryString = atob(base64Audio);
        const len = binaryString.length;
        const bytes = new Uint8Array(len);
        for (let i = 0; i < len; i++) {
          bytes[i] = binaryString.charCodeAt(i);
        }
        
        const float32Data = new Float32Array(bytes.length / 2);
        const dataView = new DataView(bytes.buffer);
        for (let i = 0; i < float32Data.length; i++) {
          float32Data[i] = dataView.getInt16(i * 2, true) / 32768.0;
        }

        const audioCtx = new (window.AudioContext || (window as any).webkitAudioContext)();
        const audioBuffer = audioCtx.createBuffer(1, float32Data.length, 24000);
        audioBuffer.getChannelData(0).set(float32Data);

        const source = audioCtx.createBufferSource();
        source.buffer = audioBuffer;
        source.connect(audioCtx.destination);
        source.onended = () => setIsSpeaking(false);
        source.start();
      }
    } catch (error) {
      console.error('TTS Error:', error);
      setIsSpeaking(false);
    }
  };

  const steps = [
    {
      id: 'welcome',
      title: "Welcome to Lumad Lingua",
      desc: "An ancestral space where we weave the echoes of the Lumad people into the digital canopy. Tap the Sacred Thread to begin.",
      icon: Sparkles,
      color: "text-primary",
      bg: "bg-primary/10",
      interactive: 'activate'
    },
    {
      id: 'dialect',
      title: "Choose Your Dialect",
      desc: "Which ancestral voice would you like to focus on first? Tap to hear a greeting.",
      icon: Globe,
      color: "text-blue-400",
      bg: "bg-blue-400/10",
      options: ['Mansaka', 'Mandaya', 'Tboli', 'Blaan']
    },
    {
      id: 'goal',
      title: "Set Your Mission",
      desc: "What brings you to the Loom today? Your choice helps us tailor your journey.",
      icon: Users,
      color: "text-green-500",
      bg: "bg-green-500/10",
      options: ['Cultural Preservation', 'Connect with Roots', 'Academic Interest', 'Just Exploring']
    },
    {
      id: 'finish',
      title: "The Loom is Ready",
      desc: "Your pattern is set. You are now a weaver of the digital canopy. May your journey be guided by the wisdom of the elders.",
      icon: Heart,
      color: "text-terracotta",
      bg: "bg-terracotta/10"
    }
  ];

  const handleNext = () => {
    if (step === 0 && !isActivated) return;
    if (step < steps.length - 1) {
      setStep(step + 1);
    } else {
      handleFinish();
    }
  };

  const handleFinish = () => {
    updateProfile({ 
      onboarded: true,
      dialect,
      goal
    });
  };

  const currentStep = steps[step];

  return (
    <div className="fixed inset-0 bg-forest flex items-center justify-center p-4 sm:p-8 z-[200] overflow-hidden">
      {/* Dynamic Background Pattern */}
      <div className="absolute inset-0 opacity-[0.03] pointer-events-none">
        <svg width="100%" height="100%">
          <pattern id="weave" x="0" y="0" width="40" height="40" patternUnits="userSpaceOnUse">
            <path d="M0 20 L40 20 M20 0 L20 40" stroke="white" strokeWidth="1" fill="none" />
          </pattern>
          <rect width="100%" height="100%" fill="url(#weave)" />
        </svg>
      </div>

      {/* Skip Button */}
      <motion.button
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        onClick={handleFinish}
        className="absolute top-8 right-8 text-[10px] font-black uppercase tracking-widest text-cream/40 hover:text-primary transition-colors z-[210] min-h-[44px] px-4"
      >
        Skip Onboarding
      </motion.button>

      {/* Weaving Progress Bar (Top) */}
      <div className="absolute top-0 left-0 right-0 h-1 flex gap-1 px-1">
        {steps.map((_, i) => (
          <div key={i} className="flex-1 relative">
            <div className="absolute inset-0 bg-white/5"></div>
            <motion.div 
              initial={{ width: 0 }}
              animate={{ width: i <= step ? '100%' : '0%' }}
              className={`absolute inset-0 ${i === step ? 'bg-primary shadow-[0_0_10px_rgba(196,164,132,0.5)]' : 'bg-primary/40'}`}
            />
          </div>
        ))}
      </div>

      <AnimatePresence mode="wait">
        <motion.div 
          key={step}
          initial={{ opacity: 0, scale: 0.9, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 1.1, y: -20 }}
          className="bg-surface-low border border-white/10 rounded-[3rem] p-8 sm:p-12 max-w-xl w-full text-center space-y-8 relative overflow-hidden shadow-2xl"
        >
          {/* Ambient Glows */}
          <motion.div 
            animate={{ 
              scale: [1, 1.2, 1],
              opacity: [0.3, 0.5, 0.3]
            }}
            transition={{ duration: 4, repeat: Infinity }}
            className={`absolute -top-24 -left-24 w-64 h-64 ${currentStep.bg} rounded-full blur-3xl transition-colors duration-700`}
          />
          <motion.div 
            animate={{ 
              scale: [1.2, 1, 1.2],
              opacity: [0.5, 0.3, 0.5]
            }}
            transition={{ duration: 4, repeat: Infinity, delay: 2 }}
            className={`absolute -bottom-24 -right-24 w-64 h-64 ${currentStep.bg} rounded-full blur-3xl transition-colors duration-700`}
          />

          <div className="relative z-10 space-y-8">
            {/* Interactive Icon */}
            <motion.button 
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              onClick={() => currentStep.id === 'welcome' && setIsActivated(true)}
              className={`w-20 h-20 sm:w-24 sm:h-24 ${currentStep.bg} ${currentStep.color} rounded-[2rem] flex items-center justify-center mx-auto gold-shadow relative group ${currentStep.id === 'welcome' && !isActivated ? 'cursor-pointer animate-pulse' : ''}`}
            >
              <currentStep.icon className={`w-10 h-10 sm:w-12 sm:h-12 transition-transform duration-500 ${isActivated && currentStep.id === 'welcome' ? 'rotate-[360deg]' : ''}`} />
              {currentStep.id === 'welcome' && !isActivated && (
                <div className="absolute inset-0 border-2 border-primary rounded-[2rem] animate-ping opacity-20"></div>
              )}
              {isSpeaking && (
                <div className="absolute -top-2 -right-2 w-6 h-6 bg-primary rounded-full flex items-center justify-center animate-bounce">
                  <Volume2 className="w-3 h-3 text-forest" />
                </div>
              )}
            </motion.button>
            
            <div className="space-y-4">
              <motion.h2 
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                className="text-3xl sm:text-4xl font-headline font-bold text-cream leading-tight tracking-tight"
              >
                {currentStep.title}
              </motion.h2>
              <motion.p 
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1 }}
                className="text-cream/60 text-base sm:text-lg leading-relaxed max-w-sm mx-auto"
              >
                {currentStep.id === 'welcome' && isActivated ? "The Loom is active. Let us begin." : currentStep.desc}
              </motion.p>
            </div>

            {/* Interactive Options */}
            {currentStep.options && (
              <div className="grid grid-cols-2 gap-3">
                {currentStep.options.map((option, idx) => (
                  <motion.button
                    key={option}
                    initial={{ opacity: 0, x: idx % 2 === 0 ? -10 : 10 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.2 + (idx * 0.05) }}
                    onClick={() => {
                      if (currentStep.id === 'dialect') {
                        setDialect(option);
                        handleSpeak(dialectGreetings[option]);
                      } else {
                        setGoal(option);
                      }
                    }}
                    className={`p-4 rounded-2xl border text-[10px] font-black uppercase tracking-widest transition-all min-h-[44px] flex flex-col items-center justify-center gap-1 ${
                      (currentStep.id === 'dialect' ? dialect === option : goal === option)
                        ? 'bg-primary border-primary text-forest gold-shadow'
                        : 'bg-white/5 border-white/10 text-cream/40 hover:bg-white/10'
                    }`}
                  >
                    <span>{option}</span>
                    {currentStep.id === 'dialect' && (
                      <span className="text-[8px] opacity-60 lowercase italic">
                        {dialectGreetings[option]}
                      </span>
                    )}
                  </motion.button>
                ))}
              </div>
            )}

            {/* Final Step Celebration */}
            {currentStep.id === 'finish' && (
              <motion.div 
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                className="flex justify-center gap-4"
              >
                {[Sparkles, Heart, Heart].map((Icon, i) => (
                  <motion.div
                    key={i}
                    animate={{ 
                      y: [0, -10, 0],
                      rotate: [0, 10, -10, 0]
                    }}
                    transition={{ duration: 2, repeat: Infinity, delay: i * 0.2 }}
                    className="w-8 h-8 rounded-full bg-primary/20 flex items-center justify-center text-primary"
                  >
                    <Icon className="w-4 h-4" />
                  </motion.div>
                ))}
              </motion.div>
            )}

            <div className="pt-4">
              <button 
                onClick={handleNext}
                disabled={currentStep.id === 'welcome' && !isActivated}
                className={`w-full py-5 rounded-2xl font-black uppercase tracking-widest transition-all flex items-center justify-center gap-3 active:translate-y-0 ${
                  (currentStep.id === 'welcome' && !isActivated)
                    ? 'bg-white/5 text-cream/20 cursor-not-allowed'
                    : 'bg-primary text-forest gold-shadow hover:-translate-y-1'
                }`}
              >
                {step === steps.length - 1 ? "Start Weaving" : "Continue"}
                <ChevronRight className="w-5 h-5" />
              </button>
            </div>
          </div>
        </motion.div>
      </AnimatePresence>
    </div>
  );
};

export default Onboarding;

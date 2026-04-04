import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Sparkles, Globe, Heart, ChevronRight, BookOpen, Users } from 'lucide-react';
import { useFirebase } from '../../Contexts/FirebaseContext';

const Onboarding: React.FC = () => {
  const { updateProfile } = useFirebase();
  const [step, setStep] = useState(0);

  const steps = [
    {
      title: "Welcome to Lumad Lingua",
      desc: "An ancestral space where we weave the echoes of the Lumad people into the digital canopy.",
      icon: Sparkles,
      color: "text-primary",
      bg: "bg-primary/10"
    },
    {
      title: "The Weaving Metaphor",
      desc: "Every word you learn is a thread. Every contribution you make is a pattern. Together, we weave a living tapestry of culture.",
      icon: Globe,
      color: "text-blue-400",
      bg: "bg-blue-400/10"
    },
    {
      title: "Community First",
      desc: "Our dictionary is built by elders and community members. You're not just learning a language; you're connecting with a people.",
      icon: Users,
      color: "text-green-500",
      bg: "bg-green-500/10"
    },
    {
      title: "Your Journey Begins",
      desc: "Earn XP, collect ancestral artifacts, and help preserve the voices of our ancestors. Are you ready to weave?",
      icon: Heart,
      color: "text-terracotta",
      bg: "bg-terracotta/10"
    }
  ];

  const handleNext = () => {
    if (step < steps.length - 1) {
      setStep(step + 1);
    } else {
      updateProfile({ onboarded: true });
    }
  };

  const currentStep = steps[step];

  return (
    <div className="fixed inset-0 bg-forest flex items-center justify-center p-8 z-[200]">
      <AnimatePresence mode="wait">
        <motion.div 
          key={step}
          initial={{ opacity: 0, scale: 0.9, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 1.1, y: -20 }}
          className="bg-surface-low border border-white/10 rounded-[3rem] p-12 max-w-xl w-full text-center space-y-10 relative overflow-hidden"
        >
          <div className={`absolute -top-24 -left-24 w-64 h-64 ${currentStep.bg} rounded-full blur-3xl opacity-50`}></div>
          <div className={`absolute -bottom-24 -right-24 w-64 h-64 ${currentStep.bg} rounded-full blur-3xl opacity-50`}></div>

          <div className="relative z-10 space-y-8">
            <div className={`w-24 h-24 ${currentStep.bg} ${currentStep.color} rounded-[2rem] flex items-center justify-center mx-auto gold-shadow`}>
              <currentStep.icon className="w-12 h-12" />
            </div>
            
            <div className="space-y-4">
              <h2 className="text-4xl font-headline font-bold text-cream leading-tight">{currentStep.title}</h2>
              <p className="text-cream/60 text-lg leading-relaxed">{currentStep.desc}</p>
            </div>

            <div className="flex justify-center gap-2">
              {steps.map((_, i) => (
                <div 
                  key={i} 
                  className={`h-1.5 rounded-full transition-all duration-500 ${i === step ? 'w-8 bg-primary' : 'w-2 bg-white/10'}`}
                />
              ))}
            </div>

            <button 
              onClick={handleNext}
              className="w-full bg-primary text-forest py-5 rounded-2xl font-black uppercase tracking-widest gold-shadow hover:-translate-y-1 transition-all flex items-center justify-center gap-3"
            >
              {step === steps.length - 1 ? "Start Weaving" : "Continue"}
              <ChevronRight className="w-5 h-5" />
            </button>
          </div>
        </motion.div>
      </AnimatePresence>
    </div>
  );
};

export default Onboarding;

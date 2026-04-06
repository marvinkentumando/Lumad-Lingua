import React, { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Heart, Star, BookOpen, GraduationCap, Volume2, Hash, Mic, Square, RefreshCw, Type, MessageSquare, CheckCircle2, AlertCircle } from 'lucide-react';
import confetti from 'canvas-confetti';
import { useFirebase } from '../../Contexts/FirebaseContext';
import { calculateSRS } from '../../lib/srs';
import { collection, doc, setDoc, getDoc, Timestamp } from 'firebase/firestore';
import { db, handleFirestoreError, OperationType } from '../../firebase';
import { DndContext, closestCenter, KeyboardSensor, PointerSensor, TouchSensor, useSensor, useSensors } from '@dnd-kit/core';
import { arrayMove, SortableContext, sortableKeyboardCoordinates, verticalListSortingStrategy, useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { GoogleGenAI, Modality } from "@google/genai";
import { toast } from 'sonner';

import { LESSON_DATA, LessonStep } from '../../constants/lessonData';

interface LessonProps {
  onExit: () => void;
  lessonId?: string | null;
  lessonType?: string | null;
}

const SortableItem = ({ id, text }: any) => {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
  } = useSortable({ id });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  };

  return (
    <div ref={setNodeRef} style={style} {...attributes} {...listeners} className="p-6 bg-white/5 border border-white/10 rounded-2xl flex items-center justify-between cursor-grab active:cursor-grabbing touch-none mb-4">
      <div className="text-xl font-bold text-cream">{text}</div>
      <div className="flex gap-2">
        <Hash className="w-5 h-5 text-cream/40" />
      </div>
    </div>
  );
};

const Lesson: React.FC<LessonProps> = ({ onExit, lessonId, lessonType }) => {
  const { profile, updateProfile, user } = useFirebase();
  const [currentStepIndex, setCurrentStepIndex] = useState(-1); // -1 for Intro
  const [isIntro, setIsIntro] = useState(true);

  const lessonContent = lessonId ? LESSON_DATA[lessonId] : null;
  const steps: LessonStep[] = lessonContent?.steps || [];

  const updateSRS = async (wordId: string, isCorrect: boolean) => {
    if (!user) return;
    const reviewId = `${user.uid}_${wordId}`;
    const reviewRef = doc(db, 'users', user.uid, 'reviews', reviewId);
    
    try {
      const snap = await getDoc(reviewRef);
      let currentSRS = { interval: 0, easeFactor: 2.5 };
      if (snap.exists()) {
        currentSRS = snap.data() as any;
      }
      
      const nextSRS = calculateSRS(isCorrect ? 5 : 0, Number(currentSRS.interval) || 0, Number(currentSRS.easeFactor) || 2.5);
      await setDoc(reviewRef, {
        userId: user.uid,
        wordId,
        ...nextSRS
      });
    } catch (err) {
      handleFirestoreError(err, OperationType.WRITE, `users/${user.uid}/reviews/${reviewId}`);
    }
  };
  const [vocabIndex, setVocabIndex] = useState(0);
  const [vocabFlipped, setVocabFlipped] = useState(false);
  const [mcqIndex, setMcqIndex] = useState(0);
  const [mcqAnswered, setMcqAnswered] = useState(false);
  const [selectedMcq, setSelectedMcq] = useState<string | null>(null);
  const [listenIndex, setListenIndex] = useState(0);
  const [listenAnswered, setListenAnswered] = useState(false);
  const [listenPlayed, setListenPlayed] = useState(false);
  const [matchedPairs, setMatchedPairs] = useState(0);
  const [selectedLeft, setSelectedLeft] = useState<{ idx: number; word: string } | null>(null);
  const [selectedRight, setSelectedRight] = useState<{ idx: number; word: string } | null>(null);
  const [xpEarned, setXpEarned] = useState(0);
  const [lives, setLives] = useState(3);
  const [streak, setStreak] = useState(0);
  const [maxStreak, setMaxStreak] = useState(0);
  const [totalCorrect, setTotalCorrect] = useState(0);
  const [totalWrong, setTotalWrong] = useState(0);
  const [isFinished, setIsFinished] = useState(false);
  const [timeLeft, setTimeLeft] = useState(30);

  // New Activity States
  const [selectedScenario, setSelectedScenario] = useState<string | null>(null);
  const [scenarioAnswered, setScenarioAnswered] = useState(false);
  const [fillBlanks, setFillBlanks] = useState<string[]>([]);
  const [fillAnswered, setFillAnswered] = useState(false);
  const [sequence, setSequence] = useState<any[]>([]);
  const [sequenceAnswered, setSequenceAnswered] = useState(false);
  const [sentenceWords, setSentenceWords] = useState<string[]>([]);
  const [targetSentence, setTargetSentence] = useState<string[]>([]);
  const [sentenceIndex, setSentenceIndex] = useState(0);
  const [sentenceAnswered, setSentenceAnswered] = useState(false);

  // Pronunciation States
  const [isRecording, setIsRecording] = useState(false);
  const [audioUrl, setAudioUrl] = useState<string | null>(null);
  const [pronunciationScore, setPronunciationScore] = useState<number | null>(null);
  const [pronunciationFeedback, setPronunciationFeedback] = useState<string | null>(null);
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [isSpeaking, setIsSpeaking] = useState(false);
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const audioChunksRef = useRef<Blob[]>([]);

  const [treeNodes, setTreeNodes] = useState<any[]>([]);
  const [selectedMember, setSelectedMember] = useState<any>(null);

  const currentStep = isIntro ? null : steps[currentStepIndex];

  useEffect(() => {
    if (currentStep && (currentStep.type === 'sorting' || currentStep.type === 'sequence') && sequence.length === 0) {
      const shuffled = [...currentStep.content].sort(() => Math.random() - 0.5);
      setSequence(shuffled);
    }
    if (currentStep && currentStep.type === 'sentence_building') {
      const current = currentStep.content[sentenceIndex];
      if (current && sentenceWords.length === 0) {
        const shuffled = [...current.words].sort(() => Math.random() - 0.5);
        setSentenceWords(shuffled);
        setTargetSentence([]);
        setSentenceAnswered(false);
      }
    }
    if (currentStep && currentStep.type === 'family_tree' && treeNodes.length === 0) {
      const nodes = currentStep.content.map((c: any) => ({ ...c, placed: false, currentPos: null }));
      setTreeNodes(nodes);
    }
  }, [currentStepIndex, currentStep]);

  const sensors = useSensors(
    useSensor(PointerSensor),
    useSensor(TouchSensor),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  );

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
      } else {
        throw new Error('No audio data received');
      }
    } catch (error) {
      console.error('TTS Error:', error);
      toast.error('Failed to play pronunciation');
      setIsSpeaking(false);
    }
  };

  const startRecording = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      const mediaRecorder = new MediaRecorder(stream);
      mediaRecorderRef.current = mediaRecorder;
      audioChunksRef.current = [];

      mediaRecorder.ondataavailable = (event) => {
        if (event.data.size > 0) {
          audioChunksRef.current.push(event.data);
        }
      };

      mediaRecorder.onstop = () => {
        const audioBlob = new Blob(audioChunksRef.current, { type: 'audio/webm' });
        const url = URL.createObjectURL(audioBlob);
        setAudioUrl(url);
        analyzePronunciation(audioBlob);
      };

      mediaRecorder.start();
      setIsRecording(true);
    } catch (error) {
      console.error('Error accessing microphone:', error);
      toast.error('Could not access microphone. Please check permissions.');
    }
  };

  const stopRecording = () => {
    if (mediaRecorderRef.current && isRecording) {
      mediaRecorderRef.current.stop();
      setIsRecording(false);
      mediaRecorderRef.current.stream.getTracks().forEach(track => track.stop());
    }
  };

  const analyzePronunciation = async (audioBlob: Blob) => {
    setIsAnalyzing(true);
    try {
      const reader = new FileReader();
      reader.readAsDataURL(audioBlob);
      reader.onloadend = async () => {
        const base64Audio = (reader.result as string).split(',')[1];
        const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });
        
        const targetWord = currentStep?.content[0]?.word || '';
        const prompt = `You are an expert language teacher. Listen to this audio recording of a student pronouncing the word "${targetWord}". 
        Evaluate their pronunciation on a scale of 0 to 100, where 100 is native-like. 
        Return ONLY a JSON object in this exact format: {"score": 85, "feedback": "Good effort, but emphasize the second syllable more."}`;

        const response = await ai.models.generateContent({
          model: "gemini-3-flash-preview",
          contents: [
            { text: prompt },
            { inlineData: { data: base64Audio, mimeType: audioBlob.type } }
          ],
          config: {
            responseMimeType: "application/json",
          }
        });

        try {
          const result = JSON.parse(response.text);
          setPronunciationScore(result.score);
          setPronunciationFeedback(result.feedback);
          if (result.score >= 70) {
            handleAnswer(true);
          } else {
            handleAnswer(false);
          }
        } catch (e) {
          console.error("Failed to parse Gemini response:", e);
          setPronunciationScore(75); // Fallback
          setPronunciationFeedback("Good try! Keep practicing.");
          handleAnswer(true);
        }
        setIsAnalyzing(false);
      };
    } catch (error) {
      console.error("Error analyzing pronunciation:", error);
      setIsAnalyzing(false);
    }
  };

  useEffect(() => {
    if (isFinished) return;
    if (isIntro || !currentStep) return;

    if (currentStep.type === 'mcq' || currentStep.type === 'listen' || currentStep.type === 'scenario') {
      setTimeLeft(30);
      const timer = setInterval(() => {
        setTimeLeft((prev) => {
          if (prev <= 1) {
            clearInterval(timer);
            handleTimeout();
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
      return () => clearInterval(timer);
    }
  }, [currentStepIndex, isIntro, isFinished]);

  const handleTimeout = () => {
    if (!currentStep) return;
    if (currentStep.type === 'mcq' && !mcqAnswered) {
      setMcqAnswered(true);
      setLives(prev => Math.max(0, prev - 1));
      setStreak(0);
      setTotalWrong(prev => prev + 1);
    }
    if (currentStep.type === 'listen' && !listenAnswered) {
      setListenAnswered(true);
      setLives(prev => Math.max(0, prev - 1));
      setStreak(0);
      setTotalWrong(prev => prev + 1);
    }
    if (currentStep.type === 'scenario' && !scenarioAnswered) {
      setScenarioAnswered(true);
      setLives(prev => Math.max(0, prev - 1));
      setStreak(0);
      setTotalWrong(prev => prev + 1);
    }
  };

  const playFeedbackSound = (isCorrect: boolean) => {
    try {
      // Short beep for correct, low boop for incorrect
      const audioCtx = new (window.AudioContext || (window as any).webkitAudioContext)();
      const oscillator = audioCtx.createOscillator();
      const gainNode = audioCtx.createGain();
      
      oscillator.connect(gainNode);
      gainNode.connect(audioCtx.destination);
      
      if (isCorrect) {
        oscillator.type = 'sine';
        oscillator.frequency.setValueAtTime(523.25, audioCtx.currentTime); // C5
        oscillator.frequency.exponentialRampToValueAtTime(1046.50, audioCtx.currentTime + 0.1); // C6
        gainNode.gain.setValueAtTime(0.1, audioCtx.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.1);
        oscillator.start(audioCtx.currentTime);
        oscillator.stop(audioCtx.currentTime + 0.1);
      } else {
        oscillator.type = 'sawtooth';
        oscillator.frequency.setValueAtTime(150, audioCtx.currentTime);
        oscillator.frequency.exponentialRampToValueAtTime(100, audioCtx.currentTime + 0.2);
        gainNode.gain.setValueAtTime(0.1, audioCtx.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.2);
        oscillator.start(audioCtx.currentTime);
        oscillator.stop(audioCtx.currentTime + 0.2);
      }
    } catch (e) {
      console.error("Audio context error", e);
    }
  };

  const handleAnswer = (isCorrect: boolean, wordId?: string) => {
    playFeedbackSound(isCorrect);
    if (wordId) updateSRS(wordId, isCorrect);
    if (isCorrect) {
      // Short vibration for correct answer
      if (typeof navigator !== 'undefined' && navigator.vibrate) {
        navigator.vibrate(50);
      }
      setTotalCorrect(prev => prev + 1);
      setStreak(prev => {
        const next = prev + 1;
        if (next > maxStreak) setMaxStreak(next);
        return next;
      });
      setXpEarned(prev => prev + 10 + (streak > 2 ? streak * 2 : 0));
    } else {
      // Double vibration for wrong answer
      if (typeof navigator !== 'undefined' && navigator.vibrate) {
        navigator.vibrate([100, 50, 100]);
      }
      setTotalWrong(prev => prev + 1);
      setStreak(0);
      setLives(prev => Math.max(0, prev - 1));
    }
  };

  const handleFinish = async () => {
    if (isFinished) return;
    confetti({
      particleCount: 150,
      spread: 70,
      origin: { y: 0.6 },
      colors: ['#D4AF37', '#2D5A27', '#E2725B', '#F5F5DC']
    });
    const finalXp = xpEarned + 20;
    const accuracyScore = Math.round((totalCorrect / (totalCorrect + totalWrong)) * 100) || 0;

    if (profile) {
      const newXP = profile.xp + finalXp;
      const newLevel = Math.floor(newXP / 500) + 1;
      
      const today = new Date().toISOString().split('T')[0];
      let newStreak = profile.streak;
      
      if (!profile.lastLessonDate) {
        newStreak = 1;
      } else {
        const lastDate = new Date(profile.lastLessonDate.split('T')[0]);
        const currentDate = new Date(today);
        const diffTime = currentDate.getTime() - lastDate.getTime();
        const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

        if (diffDays === 1) {
          newStreak = profile.streak + 1;
        } else if (diffDays > 1) {
          newStreak = 1;
        } else if (diffDays === 0) {
          newStreak = profile.streak;
        }
      }
      
      const updates: any = {
        xp: newXP,
        level: newLevel,
        streak: newStreak,
        lastActive: new Date().toISOString(),
        lastLessonDate: today,
      };

      if (lessonId && !profile.completedLessons.includes(lessonId)) {
        updates.completedLessons = [...profile.completedLessons, lessonId];
      }

      // Update xpHistory
      const todayDay = new Date().toLocaleDateString('en-US', { weekday: 'short' });
      const defaultXpHistory = [
        { day: 'Mon', xp: 0 }, { day: 'Tue', xp: 0 }, { day: 'Wed', xp: 0 },
        { day: 'Thu', xp: 0 }, { day: 'Fri', xp: 0 }, { day: 'Sat', xp: 0 }, { day: 'Sun', xp: 0 }
      ];
      let newXpHistory = profile.xpHistory?.length ? profile.xpHistory.map(entry => ({ ...entry })) : defaultXpHistory.map(entry => ({ ...entry }));
      const todayIndex = newXpHistory.findIndex(entry => entry.day === todayDay);
      if (todayIndex >= 0) {
        newXpHistory[todayIndex].xp += finalXp;
      } else {
        newXpHistory.push({ day: todayDay, xp: finalXp });
        if (newXpHistory.length > 7) newXpHistory.shift();
      }
      updates.xpHistory = newXpHistory;

      // Update accuracy
      const subject = lessonContent?.discussion.title || 'General';
      const defaultAccuracy = [
        { subject: 'Greetings', score: 0 }, { subject: 'Numbers', score: 0 },
        { subject: 'Nature', score: 0 }, { subject: 'Family', score: 0 }, { subject: 'Rituals', score: 0 }
      ];
      let newAccuracy = profile.accuracy?.length ? profile.accuracy.map(entry => ({ ...entry })) : defaultAccuracy.map(entry => ({ ...entry }));
      const subjectIndex = newAccuracy.findIndex(entry => entry.subject === subject);
      if (subjectIndex >= 0) {
        newAccuracy[subjectIndex].score = Math.round((newAccuracy[subjectIndex].score + accuracyScore) / 2);
      } else {
        newAccuracy.push({ subject, score: accuracyScore });
      }
      updates.accuracy = newAccuracy;

      // Unlock Artifacts
      const currentArtifacts = profile.artifacts || [];
      const newArtifacts = [...currentArtifacts];
      const totalLessons = updates.completedLessons?.length || profile.completedLessons.length;
      
      if (totalLessons >= 1 && !newArtifacts.includes('elder_voice')) newArtifacts.push('elder_voice');
      if (totalLessons >= 5 && !newArtifacts.includes('domain_map')) newArtifacts.push('domain_map');
      if (newLevel >= 3 && !newArtifacts.includes('sacred_thread')) newArtifacts.push('sacred_thread');
      if (newStreak >= 3 && !newArtifacts.includes('spirit_needle')) newArtifacts.push('spirit_needle');
      if (newLevel >= 10 && !newArtifacts.includes('golden_loom')) newArtifacts.push('golden_loom');
      if (totalLessons >= 20 && !newArtifacts.includes('ancient_dye')) newArtifacts.push('ancient_dye');
      
      if (newArtifacts.length > currentArtifacts.length) {
        updates.artifacts = newArtifacts;
        const unlockedCount = newArtifacts.length - currentArtifacts.length;
        toast.success(`Unlocked ${unlockedCount} new artifact${unlockedCount > 1 ? 's' : ''}!`);
      }

      await updateProfile(updates);
      toast.success(`Lesson Complete! +${finalXp} XP`);
    }
    setTimeout(() => setIsFinished(true), 1000);
  };

  const nextStep = () => {
    if (isIntro) {
      setIsIntro(false);
      setCurrentStepIndex(0);
      return;
    }

    if (currentStepIndex < steps.length - 1) {
      setCurrentStepIndex(prev => prev + 1);
      // Reset activity states
      setVocabIndex(0);
      setVocabFlipped(false);
      setMcqIndex(0);
      setMcqAnswered(false);
      setSelectedMcq(null);
      setListenIndex(0);
      setListenAnswered(false);
      setListenPlayed(false);
      setMatchedPairs(0);
      setSelectedLeft(null);
      setSelectedRight(null);
      setSelectedScenario(null);
      setScenarioAnswered(false);
      setFillBlanks([]);
      setFillAnswered(false);
      setSequence([]);
      setSequenceAnswered(false);
      setSentenceWords([]);
      setTargetSentence([]);
      setSentenceIndex(0);
      setSentenceAnswered(false);
      setTreeNodes([]);
      setSelectedMember(null);
      setIsRecording(false);
      setAudioUrl(null);
      setPronunciationScore(null);
      setPronunciationFeedback(null);
      setIsAnalyzing(false);
      setTimeLeft(30);
    } else {
      handleFinish();
    }
  };

  const handleMatch = (side: 'left' | 'right', idx: number, word: string) => {
    if (side === 'left') {
      setSelectedLeft({ idx, word });
    } else {
      setSelectedRight({ idx, word });
    }
  };

  useEffect(() => {
    if (selectedLeft && selectedRight) {
      if (selectedLeft.word === selectedRight.word) {
        setMatchedPairs(prev => prev + 1);
        setXpEarned(prev => prev + 10);
        setStreak(prev => prev + 1);
        setTotalCorrect(prev => prev + 1);
        updateSRS(selectedLeft.word, true);
      } else {
        setStreak(0);
        setLives(prev => Math.max(0, prev - 1));
        setTotalWrong(prev => prev + 1);
        updateSRS(selectedLeft.word, false);
      }
      setSelectedLeft(null);
      setSelectedRight(null);
    }
  }, [selectedLeft, selectedRight]);

  useEffect(() => {
    if (currentStep?.type === 'match' && currentStep.content.length > 0 && matchedPairs === currentStep.content.length) {
      setTimeout(nextStep, 1000);
    }
  }, [matchedPairs]);

  if (lives === 0) {
    return (
      <motion.div 
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        className="max-w-2xl mx-auto text-center space-y-8 py-12"
      >
        <div className="text-6xl mb-4">💔</div>
        <h2 className="text-5xl font-headline font-bold text-terracotta">Out of Lives</h2>
        <p className="text-cream/60 text-xl">Don't worry, every mistake is a step towards mastery. Take a short break and try again!</p>
        <div className="flex gap-4 justify-center pt-8">
          <button onClick={onExit} className="bg-white/10 text-cream px-10 py-4 rounded-2xl font-black text-lg hover:bg-white/20 transition-all">
            Back to Path
          </button>
          <button 
            onClick={() => {
              setLives(3);
              setCurrentStepIndex(-1);
              setIsIntro(true);
              setXpEarned(0);
              setTotalCorrect(0);
              setTotalWrong(0);
              setStreak(0);
            }} 
            className="bg-primary text-forest px-10 py-4 rounded-2xl font-black text-lg gold-shadow hover:-translate-y-1 transition-all"
          >
            Try Again
          </button>
        </div>
      </motion.div>
    );
  }

  if (isFinished) {
    const accuracy = Math.round((totalCorrect / (totalCorrect + totalWrong)) * 100) || 0;
    return (
      <motion.div 
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        className="max-w-2xl mx-auto text-center space-y-8 py-12"
      >
        <div className="text-6xl mb-4">🎉</div>
        <h2 className="text-5xl font-headline font-bold text-primary">Lesson Complete!</h2>
        <div className="flex justify-center gap-4">
          {[1, 2, 3].map(s => (
            <Star key={s} className={`w-12 h-12 ${s <= (accuracy > 80 ? 3 : accuracy > 50 ? 2 : 1) ? 'text-primary fill-primary' : 'text-white/10'}`} />
          ))}
        </div>
        <div className="text-6xl font-headline font-bold text-primary">+{xpEarned + 20} XP</div>
        <div className="grid grid-cols-4 gap-4 bg-white/5 border border-white/10 rounded-3xl p-8">
          <div className="text-center">
            <div className="text-2xl font-bold text-primary">{accuracy}%</div>
            <div className="text-[10px] uppercase font-black text-cream/40">Accuracy</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold text-green-500">{totalCorrect}</div>
            <div className="text-[10px] uppercase font-black text-cream/40">Correct</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold text-red-500">{totalWrong}</div>
            <div className="text-[10px] uppercase font-black text-cream/40">Wrong</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold text-blue-400">×{maxStreak}</div>
            <div className="text-[10px] uppercase font-black text-cream/40">Best Streak</div>
          </div>
        </div>
        <div className="flex gap-4 justify-center pt-8">
          <button onClick={onExit} className="bg-primary text-forest px-10 py-4 rounded-2xl font-black text-lg gold-shadow hover:-translate-y-1 transition-all">
            Continue Learning →
          </button>
        </div>
      </motion.div>
    );
  }

  return (
    <div className="fixed inset-0 bg-forest z-[100] flex flex-col font-body">
      {/* Top Bar */}
      <div className="bg-forest/90 backdrop-blur-md border-b border-white/10 px-4 md:px-8 py-3 md:py-4 flex items-center gap-4 md:gap-8 shrink-0">
        <button onClick={onExit} className="p-2 hover:bg-white/5 rounded-full transition-colors">
          <X className="w-5 h-5 md:w-6 md:h-6 text-cream/40" />
        </button>
        <div className="flex-1 min-w-0">
          <div className="text-[8px] md:text-[10px] font-mono text-cream/40 uppercase tracking-widest truncate">Mansaka · Learning Path</div>
          <div className="text-sm md:text-lg font-bold text-cream truncate">
            {isIntro ? 'Lesson Introduction' : currentStep?.title}
          </div>
        </div>
        <div className="hidden md:block w-64">
          <div className="flex justify-between text-[10px] font-mono text-cream/40 mb-1">
            <span>Progress</span>
            <span>{Math.round(((currentStepIndex + 1) / (steps.length + 1)) * 100)}%</span>
          </div>
          <div className="h-2 bg-white/10 rounded-full overflow-hidden">
            <div className="h-full bg-primary transition-all duration-500" style={{ width: `${((currentStepIndex + 1) / (steps.length + 1)) * 100}%` }}></div>
          </div>
        </div>
        <div className="flex items-center gap-2 md:gap-4">
          <div className="flex gap-0.5 md:gap-1">
            {[1, 2, 3].map(i => (
              <Heart key={i} className={`w-4 h-4 md:w-5 md:h-5 ${i <= lives ? 'text-red-500 fill-red-500' : 'text-white/10'}`} />
            ))}
          </div>
          {!isIntro && (currentStep?.type === 'mcq' || currentStep?.type === 'listen' || currentStep?.type === 'scenario') && (
            <div className={`text-base md:text-xl font-mono font-bold ${timeLeft < 10 ? 'text-red-500 animate-pulse' : 'text-primary'}`}>
              {timeLeft}
            </div>
          )}
          <div className="text-sm md:text-xl font-headline font-bold text-primary">+{xpEarned} XP</div>
        </div>
      </div>

      <div className="flex-1 flex overflow-hidden relative">
        {/* Main Stage */}
        <div className="flex-1 overflow-y-auto p-4 md:p-16 flex items-center justify-center">
          <AnimatePresence mode="wait">
            {isIntro && (
              <motion.div 
                key="intro"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -20 }}
                className="w-full max-w-3xl space-y-6 md:space-y-8"
              >
                <div className="bg-white/5 border border-white/10 rounded-[2rem] md:rounded-[3rem] p-6 md:p-12 space-y-6 md:space-y-8">
                  <div className="space-y-3 md:space-y-4">
                    <h2 className="text-2xl md:text-4xl font-headline font-bold text-primary">{lessonContent?.discussion.title}</h2>
                    <p className="text-base md:text-xl text-cream/80 leading-relaxed">{lessonContent?.discussion.text}</p>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6 md:gap-8">
                    <div className="space-y-3 md:space-y-4">
                      <h3 className="text-[10px] md:text-sm font-black uppercase tracking-widest text-primary/60 flex items-center gap-2">
                        <GraduationCap className="w-3 h-3 md:w-4 md:h-4" /> Learning Objectives
                      </h3>
                      <ul className="space-y-1.5 md:space-y-2">
                        {lessonContent?.objectives.map((obj, i) => (
                          <li key={i} className="text-cream/60 flex gap-2 md:gap-3 text-sm md:text-base">
                            <span className="text-primary">•</span> {obj}
                          </li>
                        ))}
                      </ul>
                    </div>
                    {lessonContent?.discussion.grammar && (
                      <div className="space-y-3 md:space-y-4">
                        <h3 className="text-[10px] md:text-sm font-black uppercase tracking-widest text-primary/60 flex items-center gap-2">
                          <BookOpen className="w-3 h-3 md:w-4 md:h-4" /> Grammar Notes
                        </h3>
                        <ul className="space-y-1.5 md:space-y-2">
                          {lessonContent.discussion.grammar.map((note, i) => (
                            <li key={i} className="text-cream/60 flex gap-2 md:gap-3 text-sm md:text-base">
                              <span className="text-primary">•</span> {note}
                            </li>
                          ))}
                        </ul>
                      </div>
                    )}
                  </div>

                  {lessonContent?.discussion.culture && (
                    <div className="p-4 md:p-6 bg-primary/5 border border-primary/20 rounded-xl md:rounded-2xl">
                      <h3 className="text-[10px] md:text-sm font-black uppercase tracking-widest text-primary mb-1 md:mb-2">Cultural Context</h3>
                      <p className="text-xs md:text-sm text-cream/60 italic">{lessonContent.discussion.culture}</p>
                    </div>
                  )}

                  <button 
                    onClick={nextStep}
                    className="w-full bg-primary text-forest py-4 md:py-6 rounded-xl md:rounded-2xl font-black text-lg md:text-xl gold-shadow hover:-translate-y-1 transition-all"
                  >
                    Start Activities →
                  </button>
                </div>
              </motion.div>
            )}

            {!isIntro && currentStep?.type === 'vocab_drill' && (
              <motion.div 
                key="vocab"
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.9 }}
                className="w-full max-w-xl space-y-6 md:space-y-8"
              >
                <div className="text-center space-y-2">
                  <span className="px-3 md:px-4 py-1 bg-green-500/20 text-green-400 rounded-full text-[8px] md:text-[10px] font-black uppercase tracking-widest border border-green-500/30">📝 Vocabulary Drill</span>
                  <div className="text-cream/40 font-mono text-[10px] md:text-xs">Word {vocabIndex + 1} of {currentStep.content.length}</div>
                </div>

                <motion.div 
                  onClick={() => setVocabFlipped(!vocabFlipped)}
                  className="aspect-[4/3] bg-white/5 border border-white/10 rounded-[2rem] md:rounded-[3rem] p-6 md:p-12 flex flex-col items-center justify-center text-center cursor-pointer hover:bg-white/10 transition-all gold-shadow relative overflow-hidden group touch-none"
                >
                  {!vocabFlipped ? (
                    <>
                      <img 
                        src={`https://picsum.photos/seed/${currentStep.content[vocabIndex].word}/400/300`} 
                        alt={currentStep.content[vocabIndex].word}
                        className="w-24 h-24 md:w-32 md:h-32 rounded-xl md:rounded-2xl mb-4 md:mb-6 object-cover border-2 border-primary/20"
                        referrerPolicy="no-referrer"
                      />
                      <div className="text-4xl md:text-6xl font-headline font-bold text-cream mb-2 md:mb-4">{currentStep.content[vocabIndex].word}</div>
                      <div className="mt-8 md:mt-12 text-[8px] md:text-[10px] font-black uppercase tracking-widest text-primary/40">Tap to reveal meaning</div>
                    </>
                  ) : (
                    <motion.div 
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      className="space-y-4 md:space-y-6"
                    >
                      <div className="text-2xl md:text-3xl font-bold text-primary">{currentStep.content[vocabIndex].meaning}</div>
                      <div className="text-base md:text-lg text-cream/60 italic">{currentStep.content[vocabIndex].context}</div>
                    </motion.div>
                  )}
                </motion.div>

                {vocabFlipped && (
                  <div className="flex gap-4">
                    <button 
                      onClick={() => {
                        if (vocabIndex < currentStep.content.length - 1) {
                          setVocabIndex(prev => prev + 1);
                          setVocabFlipped(false);
                        } else {
                          nextStep();
                        }
                      }} 
                      className="flex-1 bg-primary text-forest py-4 rounded-2xl font-black gold-shadow hover:-translate-y-1 transition-all"
                    >
                      {vocabIndex < currentStep.content.length - 1 ? 'Next Word →' : 'Continue →'}
                    </button>
                  </div>
                )}
              </motion.div>
            )}

            {!isIntro && currentStep?.type === 'match' && (
              <motion.div 
                key="match"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -20 }}
                className="w-full max-w-4xl space-y-8 md:space-y-12"
              >
                <div className="text-center space-y-2">
                  <span className="px-3 md:px-4 py-1 bg-orange-500/20 text-orange-400 rounded-full text-[8px] md:text-[10px] font-black uppercase tracking-widest border border-orange-500/30">🔗 Word Matching</span>
                  <div className="text-cream/40 font-mono text-[10px] md:text-xs">{matchedPairs} / {currentStep.content.length} pairs matched</div>
                </div>

                <div className="grid grid-cols-2 gap-4 md:gap-12">
                  <div className="space-y-3 md:space-y-4">
                    {currentStep.content.map((pair: any, i: number) => (
                      <button 
                        key={i}
                        onClick={() => handleMatch('left', i, pair.left)}
                        className={`w-full p-4 md:p-6 rounded-2xl md:rounded-3xl border-2 transition-all text-left text-base md:text-xl font-headline font-bold ${
                          selectedLeft?.idx === i 
                            ? 'bg-primary/10 border-primary text-primary' 
                            : 'bg-white/5 border-white/10 text-cream/80 hover:bg-white/10'
                        }`}
                      >
                        {pair.left}
                      </button>
                    ))}
                  </div>
                  <div className="space-y-3 md:space-y-4">
                    {[...currentStep.content].sort((a, b) => a.right.localeCompare(b.right)).map((pair: any, i: number) => (
                      <button 
                        key={i}
                        onClick={() => handleMatch('right', i, pair.left)}
                        className={`w-full p-4 md:p-6 rounded-2xl md:rounded-3xl border-2 transition-all text-left text-sm md:text-lg font-bold ${
                          selectedRight?.idx === i 
                            ? 'bg-primary/10 border-primary text-primary' 
                            : 'bg-white/5 border-white/10 text-cream/80 hover:bg-white/10'
                        }`}
                      >
                        {pair.right}
                      </button>
                    ))}
                  </div>
                </div>
              </motion.div>
            )}

            {!isIntro && currentStep?.type === 'listen' && (
              <motion.div 
                key="listen"
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.95 }}
                className="w-full max-w-2xl space-y-8 md:space-y-12"
              >
                <div className="text-center space-y-2">
                  <span className="px-3 md:px-4 py-1 bg-blue-500/20 text-blue-400 rounded-full text-[8px] md:text-[10px] font-black uppercase tracking-widest border border-blue-500/30">🎧 Listening Exercise</span>
                  <div className="text-cream/40 font-mono text-[10px] md:text-xs">Question {listenIndex + 1} of {currentStep.content.length}</div>
                </div>

                <div className="bg-white/5 border border-white/10 rounded-[2rem] md:rounded-[3rem] p-8 md:p-12 text-center space-y-6 md:space-y-8">
                  <button 
                    onClick={() => {
                      setListenPlayed(true);
                      handleSpeak(currentStep.content[listenIndex].word);
                    }}
                    disabled={isSpeaking}
                    className={`w-20 h-20 md:w-24 md:h-24 rounded-full border-4 border-primary flex items-center justify-center text-primary hover:bg-primary hover:text-forest transition-all mx-auto ${listenPlayed ? 'animate-pulse' : ''} disabled:opacity-50`}
                  >
                    {isSpeaking ? <RefreshCw className="w-8 h-8 md:w-10 md:h-10 animate-spin" /> : <Volume2 className="w-8 h-8 md:w-10 md:h-10" />}
                  </button>
                  <div className="text-cream/60 text-sm md:text-base">Press play to hear the word</div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-3 md:gap-4">
                  {currentStep.content[listenIndex].options.map((opt: string, i: number) => {
                    const isCorrect = opt === currentStep.content[listenIndex].correct;
                    const isSelected = selectedMcq === opt;
                    let stateStyles = "bg-white/5 border-white/10 text-cream/80";
                    if (listenAnswered) {
                      if (isCorrect) stateStyles = "bg-green-500/20 border-green-500 text-green-400";
                      else if (isSelected) stateStyles = "bg-red-500/20 border-red-500 text-red-400";
                      else stateStyles = "bg-white/5 border-white/5 text-cream/20";
                    }

                    return (
                      <button 
                        key={i}
                        disabled={listenAnswered || !listenPlayed}
                        onClick={() => {
                          setSelectedMcq(opt);
                          setListenAnswered(true);
                          handleAnswer(isCorrect, currentStep.content[listenIndex].word);
                        }}
                        className={`p-4 md:p-6 rounded-2xl md:rounded-3xl border-2 transition-all text-left flex items-center gap-4 group ${stateStyles} ${!listenPlayed ? 'opacity-50 grayscale cursor-not-allowed' : ''}`}
                      >
                        <span className="font-bold text-base md:text-lg">{opt}</span>
                      </button>
                    );
                  })}
                </div>

                {listenAnswered && (
                  <div className="flex justify-center pt-8">
                    <button 
                      onClick={() => {
                        if (listenIndex < currentStep.content.length - 1) {
                          setListenIndex(prev => prev + 1);
                          setListenAnswered(false);
                          setListenPlayed(false);
                        } else {
                          nextStep();
                        }
                      }} 
                      className="bg-primary text-forest px-12 py-4 rounded-2xl font-black text-lg gold-shadow hover:-translate-y-1 transition-all"
                    >
                      Next →
                    </button>
                  </div>
                )}
              </motion.div>
            )}

            {!isIntro && currentStep?.type === 'mcq' && (
              <motion.div 
                key="mcq"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                className="w-full max-w-2xl space-y-6 md:space-y-8"
              >
                <div className="text-center space-y-2">
                  <span className="px-3 md:px-4 py-1 bg-primary/20 text-primary rounded-full text-[8px] md:text-[10px] font-black uppercase tracking-widest border border-primary/30">❓ Multiple Choice</span>
                  <div className="text-cream/40 font-mono text-[10px] md:text-xs">Question {mcqIndex + 1} of {currentStep.content.length}</div>
                </div>

                <div className="space-y-3 md:space-y-4">
                  <div className="text-[10px] md:text-sm font-mono text-cream/40 uppercase tracking-widest text-center">{currentStep.content[mcqIndex].instruction}</div>
                  <div className="text-4xl md:text-6xl font-headline font-bold text-cream text-center">{currentStep.content[mcqIndex].word}</div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-3 md:gap-4">
                  {currentStep.content[mcqIndex].options.map((opt: string, i: number) => {
                    const isCorrect = opt === currentStep.content[mcqIndex].correct;
                    const isSelected = selectedMcq === opt;
                    let stateStyles = "bg-white/5 border-white/10 text-cream/80";
                    if (mcqAnswered) {
                      if (isCorrect) stateStyles = "bg-green-500/20 border-green-500 text-green-400";
                      else if (isSelected) stateStyles = "bg-red-500/20 border-red-500 text-red-400";
                      else stateStyles = "bg-white/5 border-white/5 text-cream/20";
                    } else if (isSelected) {
                      stateStyles = "bg-primary/10 border-primary text-primary";
                    }

                    return (
                      <button 
                        key={i}
                        disabled={mcqAnswered}
                        onClick={() => {
                          setSelectedMcq(opt);
                          setMcqAnswered(true);
                          handleAnswer(isCorrect, currentStep.content[mcqIndex].word);
                        }}
                        className={`p-4 md:p-6 rounded-2xl md:rounded-3xl border-2 transition-all text-left flex items-center gap-4 group ${stateStyles}`}
                      >
                        <span className="font-bold text-base md:text-lg">{opt}</span>
                      </button>
                    );
                  })}
                </div>

                {mcqAnswered && (
                  <motion.div 
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    className={`p-6 rounded-3xl border flex items-center justify-between gap-6 ${
                      selectedMcq === currentStep.content[mcqIndex].correct ? 'bg-green-500/10 border-green-500/30' : 'bg-red-500/10 border-red-500/30'
                    }`}
                  >
                    <div className="flex-1">
                      <div className={`font-black text-lg mb-1 ${selectedMcq === currentStep.content[mcqIndex].correct ? 'text-green-400' : 'text-red-400'}`}>
                        {selectedMcq === currentStep.content[mcqIndex].correct ? '✓ Correct!' : '✗ Not quite.'}
                      </div>
                      <div className="text-sm text-cream/60 leading-relaxed">{currentStep.content[mcqIndex].note}</div>
                    </div>
                    <button 
                      onClick={() => {
                        if (mcqIndex < currentStep.content.length - 1) {
                          setMcqIndex(prev => prev + 1);
                          setMcqAnswered(false);
                          setSelectedMcq(null);
                        } else {
                          nextStep();
                        }
                      }} 
                      className="bg-primary text-forest px-8 py-3 rounded-xl font-black gold-shadow hover:-translate-y-1 transition-all"
                    >
                      Next →
                    </button>
                  </motion.div>
                )}
              </motion.div>
            )}

            {!isIntro && currentStep?.type === 'scenario' && (
              <motion.div 
                key="scenario"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -20 }}
                className="w-full max-w-2xl space-y-6 md:space-y-8"
              >
                <div className="text-center space-y-2">
                  <span className="px-3 md:px-4 py-1 bg-purple-500/20 text-purple-400 rounded-full text-[8px] md:text-[10px] font-black uppercase tracking-widest border border-purple-500/30">🎭 Scenario Selection</span>
                </div>

                <div className="bg-white/5 border border-white/10 rounded-[2rem] md:rounded-[3rem] p-6 md:p-12 text-center space-y-4 md:space-y-6">
                  <div className="text-lg md:text-2xl font-bold text-cream leading-relaxed">{currentStep.content[0].scenario}</div>
                  <div className="text-[10px] md:text-sm text-cream/40 italic">What would you say?</div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-3 md:gap-4">
                  {currentStep.content[0].options.map((opt: string, i: number) => {
                    const isCorrect = opt === currentStep.content[0].correct;
                    const isSelected = selectedScenario === opt;
                    let stateStyles = "bg-white/5 border-white/10 text-cream/80";
                    if (scenarioAnswered) {
                      if (isCorrect) stateStyles = "bg-green-500/20 border-green-500 text-green-400";
                      else if (isSelected) stateStyles = "bg-red-500/20 border-red-500 text-red-400";
                      else stateStyles = "bg-white/5 border-white/5 text-cream/20";
                    }

                    return (
                      <button 
                        key={i}
                        disabled={scenarioAnswered}
                        onClick={() => {
                          setSelectedScenario(opt);
                          setScenarioAnswered(true);
                          handleAnswer(isCorrect);
                        }}
                        className={`p-4 md:p-6 rounded-2xl md:rounded-3xl border-2 transition-all text-left font-bold text-base md:text-lg ${stateStyles}`}
                      >
                        {opt}
                      </button>
                    );
                  })}
                </div>

                {scenarioAnswered && (
                  <button onClick={nextStep} className="w-full bg-primary text-forest py-6 rounded-2xl font-black text-xl gold-shadow">
                    Continue →
                  </button>
                )}
              </motion.div>
            )}

            {!isIntro && currentStep?.type === 'sequence' && (
              <motion.div 
                key="sequence"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -20 }}
                className="w-full max-w-2xl space-y-8"
              >
                <div className="text-center space-y-2">
                  <span className="px-4 py-1 bg-yellow-500/20 text-yellow-400 rounded-full text-[10px] font-black uppercase tracking-widest border border-yellow-500/30">🔢 Listen & Sequence</span>
                </div>

                <div className="space-y-4">
                  {currentStep.content.map((item: any, i: number) => (
                    <div key={item.id} className="p-6 bg-white/5 border border-white/10 rounded-2xl flex items-center gap-6">
                      <div className="w-10 h-10 rounded-full bg-primary/20 flex items-center justify-center font-bold text-primary">{i + 1}</div>
                      <div className="text-xl font-bold text-cream">{item.text}</div>
                    </div>
                  ))}
                </div>

                <button onClick={nextStep} className="w-full bg-primary text-forest py-6 rounded-2xl font-black text-xl gold-shadow">
                  I've memorized the order →
                </button>
              </motion.div>
            )}

            {!isIntro && currentStep?.type === 'fill_blank' && (
              <motion.div 
                key="fill"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -20 }}
                className="w-full max-w-2xl space-y-8"
              >
                <div className="text-center space-y-2">
                  <span className="px-4 py-1 bg-cyan-500/20 text-cyan-400 rounded-full text-[10px] font-black uppercase tracking-widest border border-cyan-500/30">✍️ Fill the Blanks</span>
                </div>

                <div className="space-y-6">
                  {currentStep.content.map((item: any, i: number) => (
                    <div key={i} className="p-8 bg-white/5 border border-white/10 rounded-[2rem] space-y-4">
                      <div className="text-2xl font-bold text-cream text-center">
                        {item.sentence.split('___').map((part: string, idx: number) => (
                          <React.Fragment key={idx}>
                            {part}
                            {idx === 0 && (
                              <input 
                                type="text"
                                className="mx-2 bg-white/10 border-b-2 border-primary outline-none text-primary px-2 w-24 text-center"
                                onChange={(e) => {
                                  const newBlanks = [...fillBlanks];
                                  newBlanks[i] = e.target.value;
                                  setFillBlanks(newBlanks);
                                }}
                              />
                            )}
                          </React.Fragment>
                        ))}
                      </div>
                    </div>
                  ))}
                </div>

                <button 
                  onClick={() => {
                    const allCorrect = currentStep.content.every((item: any, i: number) => fillBlanks[i]?.toLowerCase() === item.answer.toLowerCase());
                    handleAnswer(allCorrect);
                    setFillAnswered(true);
                  }}
                  className="w-full bg-primary text-forest py-6 rounded-2xl font-black text-xl gold-shadow"
                >
                  Check Answers
                </button>

                {fillAnswered && (
                  <button onClick={nextStep} className="w-full bg-white/10 text-cream py-6 rounded-2xl font-black text-xl">
                    Continue →
                  </button>
                )}
              </motion.div>
            )}

            {!isIntro && currentStep?.type === 'sentence_building' && (
              <motion.div 
                key="sentence"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -20 }}
                className="w-full max-w-3xl space-y-8 md:space-y-12"
              >
                <div className="text-center space-y-3 md:space-y-4">
                  <span className="px-3 md:px-4 py-1 bg-primary/20 text-primary rounded-full text-[8px] md:text-[10px] font-black uppercase tracking-widest border border-primary/30">🧶 Sentence Weaver</span>
                  <div className="text-cream/40 font-mono text-[10px] md:text-xs">Sentence {sentenceIndex + 1} of {currentStep.content.length}</div>
                  <h3 className="text-xl md:text-2xl font-bold text-cream">Arrange the words correctly</h3>
                </div>

                <div className="min-h-[100px] md:min-h-[120px] p-6 md:p-8 bg-white/5 border-2 border-dashed border-white/10 rounded-[2rem] md:rounded-[2.5rem] flex flex-wrap justify-center gap-2 md:gap-3 items-center">
                  <AnimatePresence>
                    {targetSentence.map((word, idx) => (
                      <motion.button
                        key={`${word}-${idx}`}
                        initial={{ scale: 0, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        exit={{ scale: 0, opacity: 0 }}
                        onClick={() => {
                          if (sentenceAnswered) return;
                          setTargetSentence(prev => prev.filter((_, i) => i !== idx));
                          setSentenceWords(prev => [...prev, word]);
                        }}
                        className="px-4 md:px-6 py-2 md:py-3 bg-primary text-forest rounded-xl md:rounded-2xl font-bold text-base md:text-lg gold-shadow hover:-translate-y-1 transition-all"
                      >
                        {word}
                      </motion.button>
                    ))}
                  </AnimatePresence>
                  {targetSentence.length === 0 && <span className="text-cream/20 font-bold italic text-sm md:text-base">Tap words below to weave your sentence...</span>}
                </div>

                <div className="flex flex-wrap justify-center gap-2 md:gap-3">
                  <AnimatePresence>
                    {sentenceWords.map((word, idx) => (
                      <motion.button
                        key={`${word}-${idx}`}
                        initial={{ scale: 0, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        exit={{ scale: 0, opacity: 0 }}
                        onClick={() => {
                          if (sentenceAnswered) return;
                          setSentenceWords(prev => prev.filter((_, i) => i !== idx));
                          setTargetSentence(prev => [...prev, word]);
                        }}
                        className="px-4 md:px-6 py-2 md:py-3 bg-white/5 border border-white/10 text-cream rounded-xl md:rounded-2xl font-bold text-base md:text-lg hover:bg-white/10 hover:-translate-y-1 transition-all"
                      >
                        {word}
                      </motion.button>
                    ))}
                  </AnimatePresence>
                </div>

                {targetSentence.length === currentStep.content[sentenceIndex].words.length && !sentenceAnswered && (
                  <motion.button
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    onClick={() => {
                      const isCorrect = targetSentence.join(' ') === currentStep.content[sentenceIndex].sentence;
                      handleAnswer(isCorrect);
                      setSentenceAnswered(true);
                    }}
                    className="w-full bg-primary text-forest py-6 rounded-2xl font-black text-xl gold-shadow"
                  >
                    Check Sentence →
                  </motion.button>
                )}

                {sentenceAnswered && (
                  <motion.div
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    className={`p-6 rounded-[2rem] border flex items-center justify-between gap-6 ${
                      targetSentence.join(' ') === currentStep.content[sentenceIndex].sentence ? 'bg-green-500/10 border-green-500/30' : 'bg-red-500/10 border-red-500/30'
                    }`}
                  >
                    <div className="flex-1">
                      <div className={`font-black text-lg mb-1 ${targetSentence.join(' ') === currentStep.content[sentenceIndex].sentence ? 'text-green-400' : 'text-red-400'}`}>
                        {targetSentence.join(' ') === currentStep.content[sentenceIndex].sentence ? '✓ Perfect Weaving!' : '✗ The threads are tangled.'}
                      </div>
                      <div className="text-sm text-cream/60">
                        {targetSentence.join(' ') === currentStep.content[sentenceIndex].sentence ? 'Your sentence is grammatically correct.' : `Correct: ${currentStep.content[sentenceIndex].sentence}`}
                      </div>
                    </div>
                    <button 
                      onClick={() => {
                        if (sentenceIndex < currentStep.content.length - 1) {
                          setSentenceIndex(prev => prev + 1);
                          setSentenceWords([]);
                          setTargetSentence([]);
                          setSentenceAnswered(false);
                        } else {
                          nextStep();
                        }
                      }}
                      className="bg-primary text-forest px-8 py-3 rounded-xl font-black gold-shadow hover:-translate-y-1 transition-all"
                    >
                      Next →
                    </button>
                  </motion.div>
                )}
              </motion.div>
            )}

            {!isIntro && currentStep?.type === 'pronounce' && (
              <motion.div 
                key="pronounce"
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.95 }}
                className="w-full max-w-2xl space-y-8 md:space-y-12"
              >
                <div className="text-center space-y-2">
                  <span className="px-3 md:px-4 py-1 bg-pink-500/20 text-pink-400 rounded-full text-[8px] md:text-[10px] font-black uppercase tracking-widest border border-pink-500/30">🗣️ Pronunciation Practice</span>
                </div>

                <div className="bg-white/5 border border-white/10 rounded-[2rem] md:rounded-[3rem] p-8 md:p-12 text-center space-y-6 md:space-y-8">
                  <div className="text-4xl md:text-6xl font-headline font-bold text-primary">{currentStep.content[0].word}</div>
                  <div className="text-lg md:text-xl text-cream/40 italic">{currentStep.content[0].phonetic}</div>
                  
                  <div className="flex justify-center gap-4 md:gap-6">
                    <button 
                      onClick={() => handleSpeak(currentStep.content[0].word)}
                      disabled={isSpeaking}
                      className="w-16 h-16 md:w-20 md:h-20 rounded-full bg-primary/10 border-2 border-primary flex items-center justify-center text-primary hover:bg-primary hover:text-forest transition-all disabled:opacity-50"
                    >
                      {isSpeaking ? <RefreshCw className="w-6 h-6 md:w-8 md:h-8 animate-spin" /> : <Volume2 className="w-6 h-6 md:w-8 md:h-8" />}
                    </button>
                    <button 
                      onClick={isRecording ? stopRecording : startRecording}
                      className={`w-16 h-16 md:w-20 md:h-20 rounded-full border-2 flex items-center justify-center transition-all ${
                        isRecording ? 'bg-red-500 text-white border-red-500 animate-pulse' : 'bg-red-500/10 border-red-500 text-red-500 hover:bg-red-500 hover:text-white'
                      }`}
                    >
                      {isRecording ? <Square className="w-6 h-6 md:w-8 md:h-8 fill-current" /> : <Mic className="w-6 h-6 md:w-8 md:h-8" />}
                    </button>
                  </div>
                  <div className="text-[10px] md:text-sm text-cream/40">
                    {isRecording ? 'Recording... Tap to stop' : isAnalyzing ? 'Analyzing pronunciation...' : 'Listen and then record your voice'}
                  </div>

                  {pronunciationScore !== null && (
                    <motion.div 
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      className={`p-6 rounded-2xl border ${pronunciationScore >= 70 ? 'bg-green-500/10 border-green-500/30 text-green-400' : 'bg-orange-500/10 border-orange-500/30 text-orange-400'}`}
                    >
                      <div className="text-3xl font-bold mb-2">{pronunciationScore}% Match</div>
                      <div className="text-sm opacity-80">{pronunciationFeedback}</div>
                    </motion.div>
                  )}
                </div>

                <button 
                  onClick={nextStep} 
                  disabled={pronunciationScore === null && !isAnalyzing}
                  className={`w-full py-6 rounded-2xl font-black text-xl transition-all ${
                    pronunciationScore !== null ? 'bg-primary text-forest gold-shadow hover:-translate-y-1' : 'bg-white/5 text-cream/20 cursor-not-allowed'
                  }`}
                >
                  Continue →
                </button>
              </motion.div>
            )}

            {!isIntro && currentStep?.type === 'family_tree' && (
              <motion.div 
                key="family"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -20 }}
                className="w-full max-w-4xl space-y-8"
              >
                <div className="text-center space-y-2">
                  <span className="px-4 py-1 bg-emerald-500/20 text-emerald-400 rounded-full text-[10px] font-black uppercase tracking-widest border border-emerald-500/30">🌳 Family Tree</span>
                  <div className="text-cream/40 font-mono text-xs">Select a member and tap an empty slot to place them</div>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                  {/* Bank */}
                  <div className="bg-white/5 border border-white/10 rounded-[2rem] p-6 space-y-3">
                    <h4 className="font-bold text-cream/60 mb-4 text-center">Members</h4>
                    {treeNodes.filter(n => !n.placed).map((member: any, i: number) => (
                      <button 
                        key={i}
                        onClick={() => setSelectedMember(member)}
                        className={`w-full p-4 rounded-xl border-2 transition-all text-left font-bold ${
                          selectedMember?.word === member.word ? 'bg-primary/20 border-primary text-primary' : 'bg-white/5 border-white/10 text-cream hover:bg-white/10'
                        }`}
                      >
                        {member.word}
                      </button>
                    ))}
                  </div>

                  {/* Tree Diagram */}
                  <div className="lg:col-span-2 bg-white/5 border border-white/10 rounded-[1.5rem] md:rounded-[2rem] p-4 md:p-8 flex flex-col items-center justify-center gap-6 md:gap-8 relative overflow-x-auto">
                    {/* Top row: Parents */}
                    <div className="flex gap-4 md:gap-12">
                      {['Amahan', 'Inahan'].map((rel, idx) => {
                        const placedNode = treeNodes.find(n => n.placed && n.relation === rel);
                        return (
                          <div key={idx} className="flex flex-col items-center gap-2">
                            <button 
                              onClick={() => {
                                if (selectedMember) {
                                  setTreeNodes(prev => prev.map(n => 
                                    n.word === selectedMember.word ? { ...n, placed: true, currentPos: rel } : n
                                  ));
                                  setSelectedMember(null);
                                } else if (placedNode) {
                                  setTreeNodes(prev => prev.map(n => 
                                    n.word === placedNode.word ? { ...n, placed: false, currentPos: null } : n
                                  ));
                                }
                              }}
                              className={`w-24 h-16 md:w-32 md:h-20 rounded-xl md:rounded-2xl border-2 border-dashed flex items-center justify-center transition-all ${
                                placedNode ? 'bg-primary/20 border-primary text-primary font-bold text-base md:text-xl' : 'border-white/20 hover:border-primary/50 hover:bg-white/5'
                              }`}
                            >
                              {placedNode ? placedNode.word : '?'}
                            </button>
                            <div className="text-[8px] md:text-[10px] font-black uppercase tracking-widest text-cream/40">{rel}</div>
                          </div>
                        );
                      })}
                    </div>
                    
                    {/* Lines */}
                    <div className="w-px h-4 md:h-8 bg-white/20"></div>
                    <div className="w-48 md:w-64 h-px bg-white/20"></div>
                    
                    {/* Bottom row: Children */}
                    <div className="flex gap-4 md:gap-8">
                      {['Igsoon (Lalaki)', 'Igsoon (Babaye)', 'Anak'].map((rel, idx) => {
                        const placedNode = treeNodes.find(n => n.placed && n.relation === rel);
                        return (
                          <div key={idx} className="flex flex-col items-center gap-2">
                            <div className="w-px h-4 md:h-8 bg-white/20"></div>
                            <button 
                              onClick={() => {
                                if (selectedMember) {
                                  setTreeNodes(prev => prev.map(n => 
                                    n.word === selectedMember.word ? { ...n, placed: true, currentPos: rel } : n
                                  ));
                                  setSelectedMember(null);
                                } else if (placedNode) {
                                  setTreeNodes(prev => prev.map(n => 
                                    n.word === placedNode.word ? { ...n, placed: false, currentPos: null } : n
                                  ));
                                }
                              }}
                              className={`w-20 h-14 md:w-28 md:h-16 rounded-xl md:rounded-2xl border-2 border-dashed flex items-center justify-center transition-all ${
                                placedNode ? 'bg-primary/20 border-primary text-primary font-bold text-sm md:text-lg' : 'border-white/20 hover:border-primary/50 hover:bg-white/5'
                              }`}
                            >
                              {placedNode ? placedNode.word : '?'}
                            </button>
                            <div className="text-[8px] md:text-[10px] font-black uppercase tracking-widest text-cream/40 text-center">{rel}</div>
                          </div>
                        );
                      })}
                    </div>
                  </div>
                </div>

                <button 
                  onClick={() => {
                    if (sequenceAnswered) {
                      nextStep();
                    } else {
                      const isCorrect = treeNodes.every(n => n.placed && n.currentPos === n.relation);
                      handleAnswer(isCorrect);
                      setSequenceAnswered(true);
                    }
                  }} 
                  disabled={treeNodes.filter(n => n.placed).length !== currentStep.content.length && !sequenceAnswered}
                  className={`w-full py-6 rounded-2xl font-black text-xl transition-all ${
                    sequenceAnswered ? 'bg-white/10 text-cream' : 
                    treeNodes.filter(n => n.placed).length === currentStep.content.length ? 'bg-primary text-forest gold-shadow hover:-translate-y-1' : 'bg-white/5 text-cream/20 cursor-not-allowed'
                  }`}
                >
                  {sequenceAnswered ? 'Continue →' : 'Check Tree →'}
                </button>
              </motion.div>
            )}

            {!isIntro && (currentStep?.type === 'sorting' || currentStep?.type === 'sequence') && (
              <motion.div 
                key={currentStep.type}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -20 }}
                className="w-full max-w-2xl space-y-6 md:space-y-8"
              >
                <div className="text-center space-y-2">
                  <span className={`px-3 md:px-4 py-1 rounded-full text-[8px] md:text-[10px] font-black uppercase tracking-widest border ${
                    currentStep.type === 'sorting' ? 'bg-indigo-500/20 text-indigo-400 border-indigo-500/30' : 'bg-yellow-500/20 text-yellow-400 border-yellow-500/30'
                  }`}>
                    {currentStep.type === 'sorting' ? '↕️ Sorting Exercise' : '🔢 Listen & Sequence'}
                  </span>
                  <div className="text-cream/40 font-mono text-[10px] md:text-xs">Drag and drop to reorder the items</div>
                </div>

                <div className="space-y-4">
                  <DndContext 
                    sensors={sensors}
                    collisionDetection={closestCenter}
                    onDragEnd={(event) => {
                      const { active, over } = event;
                      if (over && active.id !== over.id) {
                        setSequence((items) => {
                          const oldIndex = items.findIndex(i => i.id === active.id);
                          const newIndex = items.findIndex(i => i.id === over.id);
                          return arrayMove(items, oldIndex, newIndex);
                        });
                      }
                    }}
                  >
                    <SortableContext 
                      items={sequence.length > 0 ? sequence : currentStep.content}
                      strategy={verticalListSortingStrategy}
                    >
                      {(sequence.length > 0 ? sequence : currentStep.content).map((item: any) => (
                        <SortableItem key={item.id} id={item.id} text={item.text} />
                      ))}
                    </SortableContext>
                  </DndContext>
                </div>

                <button 
                  onClick={() => {
                    if (sequenceAnswered) {
                      nextStep();
                    } else {
                      const currentOrder = sequence.length > 0 ? sequence : currentStep.content;
                      const isCorrect = currentOrder.every((item: any, index: number) => item.order === index + 1);
                      handleAnswer(isCorrect);
                      setSequenceAnswered(true);
                    }
                  }} 
                  className={`w-full py-6 rounded-2xl font-black text-xl transition-all ${
                    sequenceAnswered ? 'bg-white/10 text-cream' : 'bg-primary text-forest gold-shadow hover:-translate-y-1'
                  }`}
                >
                  {sequenceAnswered ? 'Continue →' : 'Check Order →'}
                </button>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </div>
  );
};

export default Lesson;

export type Role = 'learner' | 'admin' | 'contributor' | 'validator' | 'educator';
export type Screen = 'home' | 'map' | 'dictionary' | 'learn' | 'profile' | 'admin' | 'contributor' | 'validator' | 'educator' | 'flashcards' | 'weavers';

export type StepType = 
  | 'vocab_drill' 
  | 'mcq' 
  | 'listen' 
  | 'match' 
  | 'sorting' 
  | 'sequence' 
  | 'family_tree' 
  | 'scenario' 
  | 'pronunciation'
  | 'sentence_building';

export interface LessonStep {
  id: string;
  type: StepType;
  title: string;
  content: any;
}

export interface Lesson {
  id: string;
  title: string;
  description: string;
  level: number;
  steps: LessonStep[];
  objectives: string[];
  discussion: {
    title: string;
    text: string;
    grammar?: string[];
    culture?: string;
  };
}

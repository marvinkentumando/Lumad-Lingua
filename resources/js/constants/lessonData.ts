export interface VocabWord {
  word: string;
  phonetic: string;
  meaning: string;
  example: string;
  context?: string;
}

export interface LessonStep {
  type: 'intro' | 'vocab_drill' | 'mcq' | 'listen' | 'match' | 'scenario' | 'fill_blank' | 'sequence' | 'pronounce' | 'family_tree' | 'sorting' | 'sentence_building';
  title: string;
  content?: any;
  instructions?: string;
}

export interface LessonContent {
  objectives: string[];
  discussion: {
    title: string;
    text: string;
    grammar?: string[];
    culture?: string;
  };
  steps: LessonStep[];
}

export const LESSON_DATA: Record<string, LessonContent> = {
  'mansaka_u1_l1': {
    objectives: [
      'Master 8 essential greeting phrases for different times of day',
      'Understand appropriate contexts for formal vs. informal greetings',
      'Recognize the cultural significance of greetings in Mansaka community'
    ],
    discussion: {
      title: 'Greetings in Mansaka',
      text: 'In Mansaka culture, greetings are never rushed. When encountering elders, younger people must stop, make eye contact, and deliver greetings with respect.',
      grammar: [
        '"Maayong" = good/nice (adjective)',
        'Time of day follows "maayong" pattern',
        'Greetings don\'t require subject pronouns in casual contexts'
      ],
      culture: 'The practice of "pagmano" (hand blessing) often accompanies morning greetings to elders.'
    },
    steps: [
      {
        type: 'vocab_drill',
        title: 'Core Vocabulary',
        content: [
          { word: 'Maayong buntag', meaning: 'Good morning', context: 'Sunrise to 10 AM', phonetic: 'mah-ah-yong boon-tag' },
          { word: 'Maayong udto', meaning: 'Good afternoon', context: '10 AM to 3 PM', phonetic: 'mah-ah-yong ood-to' },
          { word: 'Maayong hapon', meaning: 'Good afternoon', context: '3 PM to sunset', phonetic: 'mah-ah-yong ha-pon' },
          { word: 'Maayong gabii', meaning: 'Good evening', context: 'After sunset', phonetic: 'mah-ah-yong ga-bee-ee' },
          { word: 'Kumusta', meaning: 'How are you', context: 'Borrowed from Spanish', phonetic: 'koo-moos-ta' },
          { word: 'Paalam', meaning: 'Goodbye', context: 'Formal farewell', phonetic: 'pa-ah-lam' },
          { word: 'Babay', meaning: 'Bye', context: 'Casual farewell', phonetic: 'ba-bay' },
          { word: 'Salamat', meaning: 'Thank you', context: 'Universal gratitude', phonetic: 'sa-la-mat' },
        ]
      },
      {
        type: 'match',
        title: 'Time-Based Matching',
        instructions: 'Match greetings to the correct time of day.',
        content: [
          { left: 'Maayong buntag', right: 'Sunrise to 10 AM' },
          { left: 'Maayong udto', right: '10 AM to 3 PM' },
          { left: 'Maayong hapon', right: '3 PM to sunset' },
          { left: 'Maayong gabii', right: 'After sunset' },
        ]
      },
      {
        type: 'listen',
        title: 'Audio Recognition',
        instructions: 'Listen to the greeting and identify it.',
        content: [
          { word: 'Maayong buntag', correct: 'Good morning', options: ['Good morning', 'Good evening', 'Goodbye', 'How are you'] },
          { word: 'Salamat', correct: 'Thank you', options: ['Thank you', 'Please', 'Sorry', 'Hello'] },
        ]
      },
      {
        type: 'scenario',
        title: 'Scenario Selection',
        instructions: 'Choose the appropriate greeting for the situation.',
        content: [
          {
            scenario: 'You meet an elder at 8:00 AM.',
            options: ['Maayong buntag', 'Maayong gabii', 'Babay', 'Salamat'],
            correct: 'Maayong buntag'
          },
          {
            scenario: 'You are leaving a formal meeting.',
            options: ['Paalam', 'Babay', 'Kumusta', 'Maayong udto'],
            correct: 'Paalam'
          }
        ]
      },
      {
        type: 'pronounce',
        title: 'Pronunciation Practice',
        instructions: 'Record yourself saying the greeting.',
        content: [
          { word: 'Maayong buntag', phonetic: 'mah-ah-yong boon-tag' }
        ]
      }
    ]
  },
  'mansaka_u1_l2': {
    objectives: [
      'Construct complete self-introduction sentences',
      'Use possessive pronouns correctly',
      'Understand kinship-based introductions',
      'Ask basic questions about others'
    ],
    discussion: {
      title: 'Introducing Yourself',
      text: 'Traditional Mansaka introductions emphasize family lineage and ancestral connection. When meeting someone new, it\'s customary to identify your parents.',
      grammar: [
        'Basic sentence: Subject + Predicate (e.g., "Ako si Maria")',
        'Possession: "Ang akong" (my) + noun',
        'Question words: Unsa (what), Asa (where), Pila (how many/old)'
      ],
      culture: 'Kinship establishes your place within the community network.'
    },
    steps: [
      {
        type: 'listen',
        title: 'Listen & Learn',
        instructions: 'Listen to the phrases.',
        content: [
          { word: 'Ako si...', correct: 'I am...', options: ['I am...', 'You are...', 'He is...', 'She is...'] },
          { word: 'Ang akong ngalan...', correct: 'My name is...', options: ['My name is...', 'Your name is...', 'His name is...', 'Her name is...'] },
          { word: 'Gikan ako sa...', correct: 'I am from...', options: ['I am from...', 'You are from...', 'He is from...', 'She is from...'] }
        ]
      },
      {
        type: 'sequence',
        title: 'Listen & Sequence',
        instructions: 'Arrange the sentence cards in the correct order of a typical introduction.',
        content: [
          { id: '1', text: 'Maayong buntag.' },
          { id: '2', text: 'Ako si Ramon.' },
          { id: '3', text: 'Gikan ako sa Maragusan.' },
          { id: '4', text: 'Ang akong amahan si Pedro.' }
        ]
      },
      {
        type: 'fill_blank',
        title: 'Fill the Blanks',
        instructions: 'Complete the introduction template.',
        content: [
          { sentence: 'Ako ___ Maria.', answer: 'si' },
          { sentence: 'Ang ___ ngalan si Juan.', answer: 'akong' },
          { sentence: 'Gikan ___ sa Davao.', answer: 'ako' }
        ]
      },
      {
        type: 'sentence_building',
        title: 'Sentence Weaver',
        instructions: 'Arrange the words to form a correct introduction.',
        content: [
          { sentence: 'Ako si Maria gikan sa Davao.', words: ['Ako', 'si', 'Maria', 'gikan', 'sa', 'Davao'] },
          { sentence: 'Ang akong amahan si Pedro.', words: ['Ang', 'akong', 'amahan', 'si', 'Pedro'] }
        ]
      }
    ]
  },
  'mansaka_u1_l3': {
    objectives: [
      'Master polite expressions for requests and gratitude',
      'Understand gradations of politeness',
      'Learn culturally appropriate responses to gratitude',
      'Recognize the reciprocal nature of "utang na loob"'
    ],
    discussion: {
      title: 'Thank You & Please',
      text: 'The concept of "utang na loob" (debt of gratitude) is central to Mansaka social fabric. When someone helps you, you incur a moral obligation that extends beyond simple "thank you."',
      grammar: [
        'Request Structure: "Palihug + verb" = Please + action',
        'Gratitude Intensifiers: "Daghang" (many/much) + salamat',
        'Polite Softeners: "Kon mahimo lang" at beginning = if possible'
      ],
      culture: 'During harvest festivals or weddings, special gratitude expressions are used.'
    },
    steps: [
      {
        type: 'mcq',
        title: 'Politeness Quiz',
        instructions: 'Choose the correct answer.',
        content: [
          {
            question: 'What do you say when asking for a favor?',
            options: ['Salamat', 'Palihug', 'Paalam', 'Kumusta'],
            correct: 'Palihug'
          },
          {
            question: 'How do you respond to "Salamat"?',
            options: ['Salamat pod', 'Walay sapayan', 'Paalam', 'Oo'],
            correct: 'Walay sapayan'
          },
          {
            question: 'Which expression shows the MOST gratitude?',
            options: ['Salamat', 'Way problema', 'Daghang salamat', 'Oo'],
            correct: 'Daghang salamat'
          }
        ]
      },
      {
        type: 'scenario',
        title: 'Situation Cards',
        instructions: 'Choose appropriate expression for the scenario.',
        content: [
          {
            scenario: 'You are asking the price of a banana at the market.',
            options: ['Palihug, pila ang presyo sa saging?', 'Salamat, pila ang presyo sa saging?', 'Paalam, pila ang presyo sa saging?', 'Kumusta, pila ang presyo sa saging?'],
            correct: 'Palihug, pila ang presyo sa saging?'
          },
          {
            scenario: 'Someone helps you carry wood.',
            options: ['Daghang salamat!', 'Walay sapayan.', 'Palihug.', 'Pasayloa ko.'],
            correct: 'Daghang salamat!'
          }
        ]
      }
    ]
  },
  'mansaka_u1_l4': {
    objectives: [
      'Ask about someone\'s well-being in multiple ways',
      'Respond appropriately to well-being questions',
      'Understand the holistic nature of health in Mansaka culture',
      'Recognize emotional and spiritual states in language'
    ],
    discussion: {
      title: 'How Are You?',
      text: 'In Mansaka culture, well-being encompasses four interconnected dimensions: Physical, Emotional, Spiritual, and Communal. Asking "Kumusta ka?" invites discussion of all four dimensions.',
      grammar: [
        'Question Formation: "Kumusta" + subject = How is/are...',
        'State Descriptions: Adjective + "ko/ka/siya" = I am/You are/He-she is',
        'Intensity Modifiers: "Kaayo" = very, "Gamay" = a little'
      ],
      culture: 'Holistic health framework includes Lawas (Physical), Bation (Emotional), Kalag (Spiritual), and Kauban (Communal).'
    },
    steps: [
      {
        type: 'match',
        title: 'Matching Pairs',
        instructions: 'Match the questions with appropriate responses.',
        content: [
          { left: 'Kumusta ka?', right: 'Maayo ko' },
          { left: 'Maayo ba ka?', right: 'Oo, maayo' },
          { left: 'Unsa imong gibati?', right: 'Nalipay ko' },
          { left: 'Kapoy ka ba?', right: 'Oo, gamay' },
          { left: 'Sakit ka ba?', right: 'Dili, maayo ko' }
        ]
      },
      {
        type: 'listen',
        title: 'State Identification',
        instructions: 'Listen to the audio and identify the state.',
        content: [
          { word: 'Hilantan', correct: 'Feverish', options: ['Feverish', 'Headache', 'Hungry', 'Tired'] },
          { word: 'Sakit sa ulo', correct: 'Headache', options: ['Feverish', 'Headache', 'Hungry', 'Tired'] },
          { word: 'Gutom', correct: 'Hungry', options: ['Feverish', 'Headache', 'Hungry', 'Tired'] },
          { word: 'Kapoy', correct: 'Tired', options: ['Feverish', 'Headache', 'Hungry', 'Tired'] }
        ]
      }
    ]
  },
  'mansaka_u2_l1': {
    objectives: [
      'Master core family member terms',
      'Understand gender-specific kinship vocabulary',
      'Learn respectful address forms for parents',
      'Recognize the hierarchical structure of Mansaka family'
    ],
    discussion: {
      title: 'Mother, Father, Child',
      text: 'Mothers hold significant authority within the household. "Ang inahan, tulod sa balay" (The mother, pillar of the house).',
      grammar: [
        'Respect: Children NEVER call parents by first names',
        'Birth Order: Panganay (eldest), Bunsod (youngest)'
      ],
      culture: 'Traditional Mansaka families live in compounds where multiple generations share adjacent houses.'
    },
    steps: [
      {
        type: 'vocab_drill',
        title: 'Family Members',
        content: [
          { word: 'Inahan', meaning: 'Mother', context: 'Standard', phonetic: 'ee-nah-han' },
          { word: 'Amahan', meaning: 'Father', context: 'Standard', phonetic: 'ah-mah-han' },
          { word: 'Anak', meaning: 'Child', context: 'Universal', phonetic: 'ah-nak' },
          { word: 'Panganay', meaning: 'Eldest child', context: 'Birth order', phonetic: 'pah-nga-nay' },
          { word: 'Bunsod', meaning: 'Youngest child', context: 'Birth order', phonetic: 'boon-sod' },
        ]
      },
      {
        type: 'listen',
        title: 'Audio Recognition',
        instructions: 'Listen and select correct family member.',
        content: [
          { word: 'Ang akong inahan nagluto', correct: 'Mother', options: ['Mother', 'Father', 'Child', 'Eldest'] },
          { word: 'Ang akong tatay nag-uma', correct: 'Father', options: ['Mother', 'Father', 'Child', 'Eldest'] },
          { word: 'Ang akong anak nag-eskwela', correct: 'Child', options: ['Mother', 'Father', 'Child', 'Eldest'] }
        ]
      },
      {
        type: 'fill_blank',
        title: 'Fill in the Blank',
        instructions: 'Complete the sentence.',
        content: [
          { sentence: 'Ang ___ sa balay mao ang nanay.', answer: 'inahan' },
          { sentence: 'Ako ang ___ sa akong mga igsuon.', answer: 'panganay' }
        ]
      }
    ]
  },
  'mansaka_u2_l2': {
    objectives: [
      'Master sibling terminology with age and gender distinctions',
      'Learn extended family kinship terms',
      'Understand the Filipino/Mansaka kinship system complexity',
      'Navigate in-law relationships terminology'
    ],
    discussion: {
      title: 'Siblings & Extended Family',
      text: 'Extended family members have reciprocal obligations. Uncles/aunts help raise nephews/nieces, cousins share resources during hardship, and grandparents pass down traditional knowledge.',
      grammar: [
        'Sibling Terms: Igsuon (Sibling), Manghod (Younger), Maguwang (Older)',
        'In-Law Terms: Ugangan (In-law), Bayaw (Brother-in-law), Hipag (Sister-in-law)'
      ],
      culture: 'NEVER use names for elders; always use kinship terms. Example: "Tiyo Pedro" not just "Pedro".'
    },
    steps: [
      {
        type: 'listen',
        title: 'Kinship Term Recognition',
        instructions: 'Listen and identify the relationship.',
        content: [
          { word: 'Ang akong lolo nagtudlo nako...', correct: 'Grandfather', options: ['Grandfather', 'Uncle', 'Cousin', 'Younger sibling'] },
          { word: 'Ang akong tiyo gikan sa Manila...', correct: 'Uncle', options: ['Grandfather', 'Uncle', 'Cousin', 'Younger sibling'] },
          { word: 'Ang akong ig-agaw nag-eskwela...', correct: 'Cousin', options: ['Grandfather', 'Uncle', 'Cousin', 'Younger sibling'] }
        ]
      },
      {
        type: 'family_tree',
        title: 'Family Tree Mapping',
        instructions: 'Arrange family members on a visual tree.',
        content: [
          { word: 'Lolo', relation: 'Grandfather' },
          { word: 'Lola', relation: 'Grandmother' },
          { word: 'Tiyo', relation: 'Uncle' },
          { word: 'Tiya', relation: 'Aunt' },
          { word: 'Ig-agaw', relation: 'Cousin' }
        ]
      }
    ]
  },
  'mansaka_u2_l3': {
    objectives: [
      'Master hierarchical respect terminology',
      'Understand age-based and status-based honorifics',
      'Learn appropriate address forms for community leaders',
      'Navigate formal vs. informal register'
    ],
    discussion: {
      title: 'Respect & Address Terms',
      text: 'The "Pagmano" Ritual is a physical gesture of respect where a younger person takes an elder\'s hand and touches it to their forehead.',
      grammar: [
        'Elders (60+): Always use "Lolo/Lola" even for non-relatives',
        'Adults (40-60): Use "Tiyo/Tiya" or "Manong/Manang"',
        'Peers: Use first names among friends'
      ],
      culture: 'In community gatherings, speaking order follows strict protocol: Datu speaks first, then Council of Elders, then Bagani, then community members by age.'
    },
    steps: [
      {
        type: 'mcq',
        title: 'Title Identification',
        instructions: 'Choose the correct address form.',
        content: [
          {
            question: 'You meet an elderly woman at the market. How do you address her?',
            options: ['Hey, how are you?', 'Lola, maayong buntag', 'Miss, kumusta?', 'Just wave'],
            correct: 'Lola, maayong buntag'
          },
          {
            question: 'The tribal leader arrives at your home. What do you say?',
            options: ['Hi there!', 'Kumusta, boss?', 'Maayong hapon, Datu', 'Hey, sit down'],
            correct: 'Maayong hapon, Datu'
          },
          {
            question: 'Your teacher enters the classroom. How do you greet?',
            options: ['Yo, teacher!', 'Maayong buntag, Maestra', 'What\'s up?', 'Just nod'],
            correct: 'Maayong buntag, Maestra'
          }
        ]
      },
      {
        type: 'mcq',
        title: 'Cultural Protocol',
        instructions: 'Choose the correct action.',
        content: [
          {
            question: 'During "pagmano," what do you do?',
            options: ['Shake hands firmly', 'Touch elder\'s hand to your forehead', 'High-five', 'Bow deeply'],
            correct: 'Touch elder\'s hand to your forehead'
          },
          {
            question: 'An elder is speaking at a meeting. You disagree. What do you do?',
            options: ['Interrupt immediately', 'Wait for them to finish, then speak respectfully', 'Argue loudly', 'Leave the meeting'],
            correct: 'Wait for them to finish, then speak respectfully'
          }
        ]
      }
    ]
  },
  'mansaka_u2_l4': {
    objectives: [
      'Integrate all Unit 2 vocabulary and concepts',
      'Apply kinship terms in complex family scenarios',
      'Demonstrate cultural understanding of family structure',
      'Master respect protocols in family contexts'
    ],
    discussion: {
      title: 'Family & Kinship (Review)',
      text: 'This lesson reviews all the kinship and respect terms learned in Unit 2.',
      grammar: [
        'Review of all kinship terms',
        'Review of possessive forms'
      ],
      culture: 'Review of respect protocols and family hierarchy.'
    },
    steps: [
      {
        type: 'mcq',
        title: 'Vocabulary Recall',
        instructions: 'Choose the correct kinship term.',
        content: [
          {
            question: 'Your mother\'s brother is your:',
            options: ['Ig-agaw', 'Tiyo', 'Bayaw', 'Lolo'],
            correct: 'Tiyo'
          },
          {
            question: 'Your father\'s mother is your:',
            options: ['Tiya', 'Inahan', 'Lola', 'Ate'],
            correct: 'Lola'
          },
          {
            question: 'Your sister\'s husband is your:',
            options: ['Tiyo', 'Bayaw', 'Bilas', 'Igsuon'],
            correct: 'Bayaw'
          }
        ]
      },
      {
        type: 'fill_blank',
        title: 'Vocabulary Production',
        instructions: 'Fill in the blanks with correct Mansaka term.',
        content: [
          { sentence: 'My father\'s sister is my ___.', answer: 'tiya' },
          { sentence: 'I am the first-born child. I am the ___.', answer: 'panganay' },
          { sentence: 'My wife\'s mother is my ___ nga babaye.', answer: 'ugangan' }
        ]
      }
    ]
  },
  'mansaka_u3_l1': {
    objectives: [
      'Identify 20+ forest trees and plants by Mansaka names',
      'Understand traditional uses (medicine, food, construction)',
      'Learn ecological classifications (sacred, medicinal, utility)',
      'Recognize the spiritual significance of forest flora'
    ],
    discussion: {
      title: 'Trees & Plants',
      text: 'The forest is the ancestral domain. The Mansaka word "Kalasangan" means "the place of our ancestors\' dwelling." Every tree, plant, and stone has history and spiritual meaning.',
      grammar: [
        'Plant Parts: Dahon (Leaf), Gamut (Root), Sanga (Branch), Bunga (Fruit/Flower)'
      ],
      culture: 'Before harvesting sacred plants, ask permission from the diwata: "Diwata, palihog, tugotan mo ako sa pagkuha" (Spirit, please, allow me to take).'
    },
    steps: [
      {
        type: 'vocab_drill',
        title: 'Core Tree Vocabulary',
        content: [
          { word: 'Kalasangan', meaning: 'Forest', context: 'General term', phonetic: 'ka-la-sa-ngan' },
          { word: 'Kahoy', meaning: 'Tree', context: 'General term', phonetic: 'ka-hoy' },
          { word: 'Balete', meaning: 'Banyan tree', context: 'Sacred, home of spirits', phonetic: 'ba-le-te' },
          { word: 'Kawayan', meaning: 'Bamboo', context: 'House structure, tools', phonetic: 'ka-wa-yan' },
          { word: 'Sambong', meaning: 'Blumea balsamifera', context: 'Medicine for fever', phonetic: 'sam-bong' }
        ]
      },
      {
        type: 'match',
        title: 'Use Matching',
        instructions: 'Match plant to its traditional use.',
        content: [
          { left: 'Molave', right: 'Construction (strongest posts)' },
          { left: 'Sambong', right: 'Medicine (fever)' },
          { left: 'Kawayan', right: 'Tools and structure' },
          { left: 'Saging', right: 'Food (fruit)' },
          { left: 'Almaciga', right: 'Resin for torches' }
        ]
      },
      {
        type: 'listen',
        title: 'Audio Recognition',
        instructions: 'Listen to descriptions in Mansaka, identify the plant.',
        content: [
          { word: 'Kini nga tanom gigamit para sa sakit sa tiyan.', correct: 'Bayabas', options: ['Bayabas', 'Sambong', 'Lagundi', 'Akapulko'] }
        ]
      },
      {
        type: 'scenario',
        title: 'Practical Application',
        instructions: 'Given a situation, choose correct plant.',
        content: [
          {
            scenario: 'You have a fever. Which plant?',
            options: ['Sambong', 'Nipa', 'Kawayan', 'Balete'],
            correct: 'Sambong'
          },
          {
            scenario: 'Building a house, need roofing.',
            options: ['Nipa', 'Sambong', 'Balete', 'Kamote'],
            correct: 'Nipa'
          }
        ]
      }
    ]
  }
};

# 🌿 Lumad Lingua (Mansaka Language Preservation Platform)

An interactive, gamified mobile application built in Flutter dedicated to preserving, teaching, and celebrating the indigenous **Mansaka language** and cultural heritage of Mindanao, Philippines.

---

## 🚀 Key Features

### 📚 Interactive Learning Path & Gamification
- **Serpentine Curriculum Map:** Winding unit maps with stage progress rings, unlocked lesson checkpoints, and unit reward chests.
- **Interactive Drills:** Multiple choice, listening comprehension, word arrangement, word matching, and pronunciation recording challenges.
- **Heart & Stamina System:** 5-heart lesson stamina system with crystal refills and quick practice regeneration.
- **Leveling & Cultural Badges:** XP-driven level progression with ancestral rank titles ranging from *Beginning Learner 📚* to *Datu Honor Elder 👑*.

### 📖 Mansaka Dictionary & Study Bookmarks
- **Search & Category Filters:** Search Mansaka and English translations across categories (*Noun*, *Verb*, *Greeting*, *Phrase*, *General*).
- **Persistent Study Bookmarks:** Bookmark vocabulary items to study in a dedicated *Saved* filter view.
- **Slow-Motion Reference Audio:** Native speaker reference audio player with `1.0x`, `0.75x`, and `0.5x` slow-motion speed controls.

### 🎙️ Pronunciation Lab & On-Device ML
- **16-bit PCM Audio Analysis:** Parses recorded audio bytes to extract RMS energy, Zero Crossing Rates (ZCR), and 13-coefficient MFCC feature vectors.
- **Acoustic Trajectory Evaluation:** Evaluates pronunciation accuracy via Dynamic Time Warping (DTW) and Hidden Markov Model (HMM) matrix alignment.
- **Dynamic Admin Configuration:** Seamlessly switches active ML algorithms (`dtw_only`, `hmm_only`, `dtw_hmm`, `naive_bayes`, `svm`, `ensemble`) via Cloud Firestore `admin_config`.
- **Side-by-Side Re-listening:** Compare your past recorded voice attempts side-by-side with native elder reference audio.

### ⚔️ Lingua Duels PvP Arena
- **Live Matchmaking Timer:** 20-second active human listener countdown timer querying open waiting sessions in Cloud Firestore.
- **AI Bot Match Choice:** User choice modal prompting players to battle against the *AI Rival (Bot)* or search again if no human opponent joins within 20 seconds.
- **Dynamic Speed Scoring:** Speed-bonus scoring and HP damage meters.

### 💎 Crystal Shop & Customizations
- **Streak Freeze Protection (🧊):** Protects daily practice streaks if a learner misses a day due to travel or work.
- **Profile Cosmetics:** Unlockable Lumad ancestral avatar frames, tribal pattern banners, and seasonal *Royal Crimson & Gold* theme passes.
- **XP Double Boosters:** 24-hour 2x XP booster passes that double earned XP on all completed drills.

### 🏫 Educator Classrooms
- **Class Join Codes:** Enter teacher class codes (e.g. `MANSAKA101`) to link progress to an educator's roster.
- **Roster Enrollment:** Stream assigned learning units and classroom announcements.

### ⏰ Practice Reminders & Notifications
- **Scheduled Notifications:** Native OS practice reminders via `flutter_local_notifications`.
- **Custom Time Selection:** Time picker in App Settings to select custom practice times (e.g. `8:30 PM`).

### 👤 Authentication & Guest Mode
- **Firebase Auth:** Email/password login, user registration, and live password reset email dispatch.
- **Guest Exploration:** Full guest access to learning paths, dictionary, pronunciation lab, and PvP duels, with in-memory session tracking.

---

## 🛠️ Tech Stack & Dependencies

| Layer | Technology |
| :--- | :--- |
| **Framework** | Flutter SDK (Dart 3) |
| **State Management** | Riverpod (`flutter_riverpod`) |
| **Navigation** | GoRouter (`go_router`) |
| **Authentication** | Firebase Authentication (`firebase_auth`) |
| **Cloud Database** | Cloud Firestore (`cloud_firestore`) |
| **Cloud Media Storage** | Supabase Storage (`supabase_flutter`) |
| **Audio Processing** | `just_audio` & `record` |
| **Local Storage** | `shared_preferences` |
| **Native Notifications** | `flutter_local_notifications` |
| **UI & Animations** | `google_fonts`, `flutter_animate`, `confetti` |

---

## 📂 Project Structure

```
lib/
├── config/             # App routing, themes, colors, and configuration
├── data/               # Local fallback datasets (lessons, vocabulary, achievements)
├── models/             # Data models (user, lesson, activity, quest, duel, shop)
├── providers/          # Riverpod state notifiers & providers
├── repositories/       # Data repository implementations (Firebase & Mock)
├── screens/            # Application screens (home, learning, dictionary, arena, profile, shop)
├── services/           # Backend services (Firestore, Local ML, Notifications, Supabase)
├── utils/              # Helper utilities (level progression, audio helper, formatters)
└── widgets/            # Reusable UI components (buttons, cards, audio players, badges)
```

---

## ⚙️ Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.13+ or higher)
- Android Studio / VS Code with Flutter extension
- JDK 17 with Java 8+ Core Library Desugaring enabled

### Installation & Running

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/lumad_lingua.git
   cd lumad_lingua
   ```

2. **Install Flutter package dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```

---

## 📜 License
Built for Lumad cultural preservation and language heritage learning.

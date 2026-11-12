# Phase B - Backend Integration Roadmap

This document outlines the architectural plan, schema designs, and integration workflow for **Phase B** of the Lumad Lingua application.

---

## 1. Overview of Backend Architecture

```text
Flutter Mobile Client
    ├── Firebase Auth (Identity & Token issuance)
    ├── Cloud Firestore (App Data, Progress, Vocabulary, Users)
    ├── Supabase Storage (Private audio storage & reference audio)
    └── FastAPI ML Server (Speech Pronunciation Assessment & Sentiment Analysis)
```

---

## 2. Stage 15: Firebase Integration

### 2.1 Firebase Authentication
- Integrate `firebase_core` and `firebase_auth`.
- Replace `MockAuthRepository` with `FirebaseAuthRepository`.
- Maintain standard token refreshing and ID token generation for FastAPI requests.

### 2.2 Cloud Firestore Database Schema

```text
users/ {userId}
  ├── name: String
  ├── email: String
  ├── totalXp: Number
  ├── level: Number
  ├── streakDays: Number
  ├── currentUnitId: String
  └── currentLessonId: String

learning_units/ {unitId}
  ├── unitNumber: Number
  ├── title: String
  ├── description: String
  ├── category: String
  └── isUnlocked: Boolean

lessons/ {lessonId}
  ├── unitId: String
  ├── title: String
  ├── description: String
  ├── lessonOrder: Number
  └── xpReward: Number

learning_activities/ {activityId}
  ├── lessonId: String
  ├── type: String
  ├── questionText: String
  ├── options: Array<String>
  ├── correctOptionIndex: Number
  ├── matchingPairs: Array<Map>
  └── xpReward: Number

user_progress/ {userId}
  ├── lessonStars: Map<String, Number>
  ├── completedLessonIds: Array<String>
  ├── totalLessonsCompleted: Number
  └── overallMasteryPercentage: Number
```

---

## 3. Stage 16: Supabase Audio Integration

### 3.1 Audio Buckets
- `mansaka-references`: Public/Signed URLs for authoritative native speaker reference recordings.
- `learner-recordings`: Private bucket for learner voice submissions.

### 3.2 Caching Strategy
- Download reference audio on demand and cache locally using `path_provider`.
- Check file MD5 checksum or version prior to playing.

---

## 4. Stage 17: FastAPI & Machine Learning Integration

### 4.1 Pronunciation Assessment Endpoint
- **URL**: `POST /api/v1/pronunciation/evaluate`
- **Method**: Accepts WAV/M4A learner audio file and target word ID.
- **Model Pipeline**:
  1. Feature extraction using self-supervised learning (SSL) speech encoder (e.g. Wav2Vec2 / HuBERT).
  2. Dynamic Time Warping (DTW) distance calculation against native speaker reference embeddings.
  3. Phoneme-level alignment score normalization.
- **Response**:
  ```json
  {
    "score": 88.5,
    "grade": "Excellent",
    "feedback": "Good vowel length on 'masurom'."
  }
  ```

### 4.2 Sentiment Analysis Endpoint
- **URL**: `POST /api/v1/sentiment/analyze`
- **Method**: Accepts Mansaka text payload.
- **Model Pipeline**:
  1. Language Identification (Mansaka vs. Mixed vs. Non-Mansaka).
  2. NLP text preprocessing and tokenization.
  3. Ensemble inference (Naive Bayes, SVM, BiLSTM).
- **Response**:
  ```json
  {
    "text": "Madyaw na masurom sang tanan sakop sang banwa!",
    "sentiment": "positive",
    "language": "mansaka",
    "confidence": 0.94,
    "model": "BiLSTM-SVM-Ensemble"
  }
  ```

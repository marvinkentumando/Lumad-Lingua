# Phase C - Testing & Deployment Strategy

This document outlines the testing protocols, machine learning evaluation procedures, and release build workflows for **Phase C** of the Lumad Lingua project.

---

## 1. Stage 18: System Integration Testing

### 1.1 Integration Flow Verification
- Validate auth flow: Onboarding ➔ Registration ➔ Firebase Token Storage ➔ Home Screen.
- Validate learning flow: Unit selection ➔ Lesson activity session ➔ Answer scoring ➔ Firestore XP sync ➔ Reward dialog.
- Validate audio practice: Mic permission prompt ➔ Recording ➔ Supabase upload ➔ FastAPI evaluation response display.

---

## 2. Stage 19: Machine Learning Evaluation & Benchmarking

### 2.1 Pronunciation Assessment Evaluation
- Evaluate DTW + SSL speech embeddings against test recordings from native Mansaka speakers.
- Benchmark Metrics:
  - Correlation with expert native speaker human ratings (Pearson / Spearman correlation).
  - False acceptance rate (FAR) and false rejection rate (FRR) for pronunciation scoring thresholds.

### 2.2 Sentiment Analysis Evaluation
- Evaluate Naive Bayes, Support Vector Machine (SVM), and BiLSTM models on held-out Mansaka Facebook post dataset.
- Benchmark Metrics:
  - Precision, Recall, F1-Score per class (Positive, Neutral, Negative).
  - Accuracy on Mansaka language classification.

---

## 3. Stage 20: Performance Optimization & Android Deployment

### 3.1 Performance Auditing
- Verify 60 FPS animation performance across unit cards and activity transitions.
- Audit memory usage during audio recording and playback.
- Ensure zero memory leaks on screen disposal.

### 3.2 Android Release Build Command
```bash
flutter build apk --release
flutter build appbundle --release
```

### 3.3 Release Verification Checklist
- [ ] Version and build number updated in `pubspec.yaml`
- [ ] Obfuscation and tree shaking enabled
- [ ] Android permissions (`INTERNET`, `RECORD_AUDIO`) declared in `AndroidManifest.xml`
- [ ] Final release APK verified on test device

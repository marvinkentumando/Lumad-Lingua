# Implementation Plan - Dynamic Algorithm Configuration & Clean Learner UI

This plan implements dynamic algorithm switching controlled by a connected web admin panel (via Cloud Firestore) while keeping the learner UI clean, friendly, and free of technical algorithm jargon.

## User Review Required

> [!IMPORTANT]
> - Admin configurations will be stored in a Cloud Firestore document (`system_config/app_settings`).
> - Learners will see friendly scores and feedback (e.g., "Pronunciation Accuracy: 92%") instead of internal algorithm names like "DTW + HMM".

## Proposed Changes

### Configuration & Database Service
#### [NEW] [admin_config_service.dart](file:///C:/Users/Aspire-3/Desktop/lumad_lingua/lib/services/admin_config_service.dart)
- Fetches active algorithm settings from Firestore `system_config/app_settings`.
- Provides fallback defaults if offline or unconfigured.

### Local ML Engine Update
#### [MODIFY] [local_ml_service.dart](file:///C:/Users/Aspire-3/Desktop/lumad_lingua/lib/services/local_ml_service.dart)
- Supports dynamic algorithm routing based on admin settings (e.g., switching between DTW, HMM, Naive Bayes, SVM, BiLSTM, or Ensemble).

### Learner UI Cleanup
#### [MODIFY] [pronunciation_screen.dart](file:///C:/Users/Aspire-3/Desktop/lumad_lingua/lib/screens/pronunciation/pronunciation_screen.dart)
- Remove raw algorithm jargon from learner feedback dialogs.
- Display clean, encouraging learning scores and actionable tips.

## Verification Plan

### Automated Tests
- `flutter test` to ensure config parsing and local algorithm execution pass without errors.

### Manual Verification
- Update admin config in Firestore and verify the app dynamically adjusts its evaluation method.
- Check learner pronunciation result dialogs for clean, jargon-free UI.

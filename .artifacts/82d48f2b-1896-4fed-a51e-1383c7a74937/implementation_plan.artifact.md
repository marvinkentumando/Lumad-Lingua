# Progressive Multi-Step Lesson Play & Circular Progress Implementation Plan

Implement segmented, multi-step lesson progression (Multiple-Choice Drills first, concluding with Pronunciation Practice as the final stage) with circular progress indicators on Learning Path nodes.

## User Review Required

> [!IMPORTANT]
> Lessons will be structured into sequential phases: Multiple Choice Drills (Part 1 & 2) and Pronunciation Challenge (Final Part). Learning Path nodes will feature circular progress rings tracking completion.

## Proposed Changes

### Curriculum & Lesson Model
#### [MODIFY] [lesson_model.dart](file:///C:/Users/Aspire-3/Desktop/lumad_lingua/lib/models/lesson_model.dart)
- Add stage breakdown (e.g. `stagesCount`, `completedStages`) to track multi-part lesson progress.

### Learning Path Screen & Node Widget
#### [MODIFY] [learning_path_screen.dart](file:///C:/Users/Aspire-3/Desktop/lumad_lingua/lib/screens/learning/learning_path_screen.dart)
- Update lesson node rendering to display a circular progress ring representing stage completion.

### Lesson Flow & Multi-Step Runner
#### [MODIFY] [lesson_screen.dart](file:///C:/Users/Aspire-3/Desktop/lumad_lingua/lib/screens/learning/lesson_screen.dart)
- Structure lesson drills so multiple-choice questions come first, followed by the pronunciation/audio challenge as the final part.

## Verification Plan

### Automated Tests
- Run `flutter test` to verify model serialization and curriculum state.

### Manual Verification
- Verify circular progress indicators render correctly on Learning Path nodes.
- Test completing multi-stage lesson flows (multiple-choice leading to pronunciation final stage) and verify progress state updates.

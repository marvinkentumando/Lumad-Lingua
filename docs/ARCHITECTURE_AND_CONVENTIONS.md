# Architecture & Coding Conventions

This guide defines the architectural standards, directory conventions, and coding patterns for **Lumad Lingua**.

---

## 1. Layered Architecture Principles

```text
Flutter Screen (Presentation)
     │
     ▼
Riverpod Provider / Notifier (State Management)
     │
     ▼
Repository Interface (Data Layer Abstraction)
     │
     ▼
Mock Data / Firebase / FastAPI / Supabase (Data Source)
```

### Key Rules
1. **Screens**: Responsible only for UI rendering, user interaction handling, and triggering provider actions.
2. **Models**: Immutable data classes (`final` fields) with `copyWith` and `fromJson` / `toJson` methods.
3. **Repositories**: Abstract classes declaring data operations, implemented by `MockRepository` (Phase A) or `RemoteRepository` (Phase B).
4. **Providers**: Riverpod `Notifier` or `AsyncNotifier` classes managing reactive UI state.
5. **Widgets**: Reusable, atomic interface components adhering to Material 3 design system.

---

## 2. Directory Structure

- `lib/config/`: App metadata, route definitions (`routes.dart`), theme (`theme.dart`).
- `lib/data/`: Mock data generators for initial frontend execution.
- `lib/models/`: Strongly typed Dart data models.
- `lib/providers/`: Riverpod state notifiers.
- `lib/repositories/`: Abstract repositories and concrete implementations.
- `lib/screens/`: Feature screens grouped by functional area.
- `lib/utils/`: Constants (colors, spacing), validators, and formatters.
- `lib/widgets/`: Reusable components (common, learning, gamification, audio).

---

## 3. Riverpod State Management Pattern

Prefer Riverpod 3.0+ `Notifier` and `AsyncNotifier` providers:

```dart
class MyNotifier extends AsyncNotifier<MyState> {
  @override
  Future<MyState> build() async {
    return fetchInitialData();
  }

  void updateData(NewData data) {
    state = AsyncValue.data(...);
  }
}

final myProvider = AsyncNotifierProvider<MyNotifier, MyState>(() {
  return MyNotifier();
});
```

---

## 4. UI Design System Tokens

- **Primary Color**: Forest Green (`#246B45`)
- **Secondary Color**: Bright Green (`#58CC72`)
- **Accent/Tertiary Color**: Warm Yellow (`#FFC857`)
- **Background Color**: Cream White (`#FFF9ED`)
- **Typography**: Google Fonts `Plus Jakarta Sans`

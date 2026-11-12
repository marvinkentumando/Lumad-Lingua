import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/firebase_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

class AuthNotifier extends AsyncNotifier<UserModel?> {
  late final AuthRepository _repository;

  @override
  Future<UserModel?> build() async {
    _repository = ref.watch(authRepositoryProvider);
    return _repository.getCurrentUser();
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email, password);
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.register(name, email, password);
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }

  void addXp(int xp) {
    if (state.value != null) {
      final current = state.value!;
      final newXp = current.totalXp + xp;
      final newLevel = (newXp / 100).floor() + 1;
      state = AsyncValue.data(current.copyWith(
        totalXp: newXp,
        level: newLevel,
      ));
    }
  }
}

final authStateProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(() {
  return AuthNotifier();
});

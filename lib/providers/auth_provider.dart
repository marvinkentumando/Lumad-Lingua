import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/shop_item_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/firebase_auth_repository.dart';
import '../utils/level_helper.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

class AuthNotifier extends AsyncNotifier<UserModel?> {
  late final AuthRepository _repository;

  @override
  Future<UserModel?> build() async {
    _repository = ref.watch(authRepositoryProvider);
    final rawUser = await _repository.getCurrentUser();
    if (rawUser != null) {
      final verifiedUser = _verifyAndProcessStreakProtection(rawUser);
      if (verifiedUser != rawUser) {
        _repository.saveUser(verifiedUser);
      }
      return verifiedUser;
    }
    return null;
  }

  UserModel _verifyAndProcessStreakProtection(UserModel user) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (user.lastActiveDate == null) {
      return user.copyWith(lastActiveDate: today);
    }

    final lastActive = DateTime(
      user.lastActiveDate!.year,
      user.lastActiveDate!.month,
      user.lastActiveDate!.day,
    );

    final daysDifference = today.difference(lastActive).inDays;

    if (daysDifference <= 1) {
      // Streak intact or practiced today/yesterday
      return user.copyWith(lastActiveDate: today);
    } else {
      // Missed 1 or more days! Check Streak Freeze protection
      if (user.streakFreezes > 0) {
        // Auto-consume 1 Streak Freeze to preserve streak
        return user.copyWith(
          streakFreezes: user.streakFreezes - 1,
          lastActiveDate: today,
        );
      } else {
        // Streak lost -> reset to 1
        return user.copyWith(
          streakDays: 1,
          lastActiveDate: today,
        );
      }
    }
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final rawUser = await _repository.login(email, password);
      final verifiedUser = _verifyAndProcessStreakProtection(rawUser);
      await _repository.saveUser(verifiedUser);
      state = AsyncValue.data(verifiedUser);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final rawUser = await _repository.register(name, email, password);
      final verifiedUser = _verifyAndProcessStreakProtection(rawUser);
      await _repository.saveUser(verifiedUser);
      state = AsyncValue.data(verifiedUser);
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

  Future<void> updateUser(UserModel updatedUser) async {
    state = AsyncValue.data(updatedUser);
    try {
      await _repository.saveUser(updatedUser);
    } catch (_) {}
  }

  Future<void> updateCrystals(int crystals) async {
    if (state.value != null) {
      final updated = state.value!.copyWith(crystals: crystals);
      state = AsyncValue.data(updated);
      try {
        await _repository.saveUser(updated);
      } catch (_) {}
    }
  }

  void addXp(int xp) {
    if (state.value != null) {
      final current = state.value!;
      final newXp = current.totalXp + xp;
      final newLevel = LevelHelper.calculateLevel(newXp);
      state = AsyncValue.data(current.copyWith(
        totalXp: newXp,
        level: newLevel,
      ));
    }
  }

  Future<bool> buyShopItem(ShopItemModel item) async {
    final user = state.value;
    if (user == null || user.crystals < item.priceCrystals) {
      return false;
    }

    final newCrystals = user.crystals - item.priceCrystals;
    final newInventory = List<String>.from(user.inventory);
    if (!newInventory.contains(item.id)) {
      newInventory.add(item.id);
    }

    int newStreakFreezes = user.streakFreezes;
    String? newFrame = user.equippedFrame;
    String? newBanner = user.equippedBanner;

    if (item.type == ShopItemType.streakFreeze) {
      newStreakFreezes++;
    } else if (item.type == ShopItemType.avatarFrame) {
      newFrame = item.id;
    } else if (item.type == ShopItemType.profileBanner) {
      newBanner = item.id;
    }

    final updatedUser = user.copyWith(
      crystals: newCrystals,
      inventory: newInventory,
      streakFreezes: newStreakFreezes,
      equippedFrame: newFrame,
      equippedBanner: newBanner,
    );

    await updateUser(updatedUser);
    return true;
  }

  Future<void> equipFrame(String? frameId) async {
    final user = state.value;
    if (user == null) return;

    final updated = frameId == null
        ? user.copyWith(clearEquippedFrame: true)
        : user.copyWith(equippedFrame: frameId);

    await updateUser(updated);
  }

  Future<void> equipBanner(String? bannerId) async {
    final user = state.value;
    if (user == null) return;

    final updated = bannerId == null
        ? user.copyWith(clearEquippedBanner: true)
        : user.copyWith(equippedBanner: bannerId);

    await updateUser(updated);
  }

  Future<bool> useStreakFreeze() async {
    final user = state.value;
    if (user == null || user.streakFreezes <= 0) return false;

    final updated = user.copyWith(streakFreezes: user.streakFreezes - 1);
    await updateUser(updated);
    return true;
  }
}

final authStateProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(() {
  return AuthNotifier();
});

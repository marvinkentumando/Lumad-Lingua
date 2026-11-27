import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/shop_item_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/firebase_auth_repository.dart';
import '../utils/level_helper.dart';

const UserModel defaultGuestUser = UserModel(
  id: 'guest',
  name: 'Lumad Learner',
  email: 'learner@lumadlingua.com',
  totalXp: 0,
  level: 1,
  streakDays: 0,
  crystals: 150,
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

class AuthNotifier extends AsyncNotifier<UserModel?> {
  late final AuthRepository _repository;
  int? _pendingLevelUp;

  int? get pendingLevelUp => _pendingLevelUp;

  void clearPendingLevelUp() {
    _pendingLevelUp = null;
  }

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
    return defaultGuestUser;
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
      return user;
    } else {
      // Missed 1 or more days! Check Streak Freeze protection
      if (user.streakFreezes > 0) {
        // Auto-consume 1 Streak Freeze to preserve streak
        return user.copyWith(
          streakFreezes: user.streakFreezes - 1,
          lastActiveDate: today,
        );
      } else {
        // Reset streak if inactive for more than 2 days
        if (daysDifference > 2) {
          return user.copyWith(
            streakDays: 0,
            lastActiveDate: today,
          );
        }
        return user;
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

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _repository.sendPasswordResetEmail(email);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(defaultGuestUser);
  }

  Future<void> updateUser(UserModel updatedUser) async {
    state = AsyncValue.data(updatedUser);
    if (updatedUser.id != 'guest') {
      try {
        await _repository.saveUser(updatedUser);
      } catch (_) {}
    }
  }

  Future<void> updateCrystals(int crystals) async {
    final current = state.value ?? defaultGuestUser;
    final updated = current.copyWith(crystals: crystals);
    await updateUser(updated);
  }

  void addXp(int baseXp) {
    final current = state.value ?? defaultGuestUser;
    final bool isBoosterActive = current.isXpBoosterActive;
    final actualXp = isBoosterActive ? (baseXp * 2) : baseXp;
    final newXp = current.totalXp + actualXp;
    final oldLevel = current.level;
    final newLevel = LevelHelper.calculateLevel(newXp);

    if (newLevel > oldLevel) {
      _pendingLevelUp = newLevel;
      updateUser(current.copyWith(
        totalXp: newXp,
        level: newLevel,
        crystals: current.crystals + 50,
      ));
    } else {
      updateUser(current.copyWith(
        totalXp: newXp,
        level: newLevel,
      ));
    }
  }

  Future<bool> buyShopItem(ShopItemModel item) async {
    final user = state.value ?? defaultGuestUser;
    if (user.crystals < item.priceCrystals) {
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
    DateTime? newXpBoosterExpiresAt = user.xpBoosterExpiresAt;

    if (item.type == ShopItemType.streakFreeze) {
      newStreakFreezes++;
    } else if (item.type == ShopItemType.avatarFrame) {
      newFrame = item.id;
    } else if (item.type == ShopItemType.profileBanner) {
      newBanner = item.id;
    }

    if (item.id == 'xp_booster') {
      newXpBoosterExpiresAt = DateTime.now().add(const Duration(hours: 24));
    }

    final updatedUser = user.copyWith(
      crystals: newCrystals,
      inventory: newInventory,
      streakFreezes: newStreakFreezes,
      equippedFrame: newFrame,
      equippedBanner: newBanner,
      xpBoosterExpiresAt: newXpBoosterExpiresAt,
    );

    await updateUser(updatedUser);
    return true;
  }

  Future<void> equipFrame(String? frameId) async {
    final user = state.value ?? defaultGuestUser;

    final updated = frameId == null
        ? user.copyWith(clearEquippedFrame: true)
        : user.copyWith(equippedFrame: frameId);

    await updateUser(updated);
  }

  Future<void> equipBanner(String? bannerId) async {
    final user = state.value ?? defaultGuestUser;

    final updated = bannerId == null
        ? user.copyWith(clearEquippedBanner: true)
        : user.copyWith(equippedBanner: bannerId);

    await updateUser(updated);
  }

  Future<bool> useStreakFreeze() async {
    final user = state.value ?? defaultGuestUser;
    if (user.streakFreezes <= 0) return false;

    final updated = user.copyWith(streakFreezes: user.streakFreezes - 1);
    await updateUser(updated);
    return true;
  }
}

final authStateProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(() {
  return AuthNotifier();
});

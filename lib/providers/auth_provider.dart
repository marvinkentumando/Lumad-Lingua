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

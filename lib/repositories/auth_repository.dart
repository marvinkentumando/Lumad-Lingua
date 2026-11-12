import '../models/user_model.dart';
import '../data/mock_users.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
  Future<void> logout();
}

class MockAuthRepository implements AuthRepository {
  UserModel? _currentUser = mockCurrentUser;

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentUser;
  }

  @override
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = mockCurrentUser.copyWith(email: email);
    return _currentUser!;
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      totalXp: 0,
      level: 1,
      streakDays: 1,
    );
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }
}

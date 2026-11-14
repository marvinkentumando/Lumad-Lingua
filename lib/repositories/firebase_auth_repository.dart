import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      data['id'] = firebaseUser.uid;
      return UserModel.fromJson(data);
    }

    return UserModel(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'Learner',
      email: firebaseUser.email ?? '',
    );
  }

  @override
  Future<UserModel> login(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw Exception('Login failed: User null');
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      data['id'] = user.uid;
      return UserModel.fromJson(data);
    }

    final newUser = UserModel(
      id: user.uid,
      name: user.displayName ?? email.split('@').first,
      email: email,
    );
    await _firestore.collection('users').doc(user.uid).set(newUser.toJson());
    return newUser;
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw Exception('Registration failed: User null');
    }

    await user.updateDisplayName(name);

    final userModel = UserModel(
      id: user.uid,
      name: name,
      email: email,
      totalXp: 0,
      level: 1,
      streakDays: 1,
    );

    await _firestore.collection('users').doc(user.uid).set(userModel.toJson());
    return userModel;
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson(), SetOptions(merge: true));
  }
}

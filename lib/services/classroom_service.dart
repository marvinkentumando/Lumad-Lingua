import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClassroomService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Looks up a classroom by joinCode and adds the current user's UID to studentIds.
  Future<Map<String, dynamic>> joinClassroomByCode(String rawCode) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Please sign in first.');
    }

    final normalizedCode = rawCode.trim().toUpperCase();
    if (normalizedCode.isEmpty) {
      throw Exception('Enter a valid class join code.');
    }

    // 1. Find the classroom matching the educator's joinCode
    final query = await _firestore
        .collection('classrooms')
        .where('joinCode', isEqualTo: normalizedCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('No classroom found with code "$normalizedCode".');
    }

    final classDoc = query.docs.first;

    // 2. Atomically add this learner's UID to studentIds
    await classDoc.reference.update({
      'studentIds': FieldValue.arrayUnion([user.uid]),
    });

    // 3. Also store the classroom reference on users/{uid}
    await _firestore.collection('users').doc(user.uid).set({
      'classroomIds': FieldValue.arrayUnion([classDoc.id]),
    }, SetOptions(merge: true));

    return {'classId': classDoc.id, ...classDoc.data()};
  }

  /// Removes the current learner from a classroom.
  Future<void> leaveClassroom(String classId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('classrooms').doc(classId).update({
      'studentIds': FieldValue.arrayRemove([user.uid]),
    });

    await _firestore.collection('users').doc(user.uid).set({
      'classroomIds': FieldValue.arrayRemove([classId]),
    }, SetOptions(merge: true));
  }

  /// Stream the classrooms the current learner belongs to (for assignedUnitIds).
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyClassrooms() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _firestore
        .collection('classrooms')
        .where('studentIds', arrayContains: uid)
        .snapshots();
  }
}

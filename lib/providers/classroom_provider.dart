import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/classroom_service.dart';

final classroomServiceProvider = Provider<ClassroomService>((ref) {
  return ClassroomService();
});

final myClassroomsStreamProvider = StreamProvider<QuerySnapshot<Map<String, dynamic>>>((ref) {
  final service = ref.watch(classroomServiceProvider);
  return service.watchMyClassrooms();
});

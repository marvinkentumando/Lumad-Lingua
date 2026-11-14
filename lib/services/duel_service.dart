import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/duel_model.dart';

class DuelService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DuelService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  static const List<DuelQuestion> _sampleDuelQuestions = [
    DuelQuestion(
      id: 'q1',
      questionText: 'Translate to English: "Madyaw na masurom"',
      targetMansaka: 'Madyaw na masurom',
      targetEnglish: 'Good morning',
      options: ['Good morning', 'Good evening', 'Thank you', 'Welcome'],
      correctOptionIndex: 0,
    ),
    DuelQuestion(
      id: 'q2',
      questionText: 'What does "Salamat" mean in Mansaka?',
      targetMansaka: 'Salamat',
      targetEnglish: 'Thank you',
      options: ['Hello', 'Thank you', 'Goodbye', 'Friend'],
      correctOptionIndex: 1,
    ),
    DuelQuestion(
      id: 'q3',
      questionText: 'Select the Mansaka term for the number "One":',
      targetMansaka: 'Isa',
      targetEnglish: 'One',
      options: ['Duha', 'Tulo', 'Isa', 'Apat'],
      correctOptionIndex: 2,
    ),
    DuelQuestion(
      id: 'q4',
      questionText: 'Which phrase means "You\'re welcome"?',
      targetMansaka: 'Walay sapayan',
      targetEnglish: 'You\'re welcome',
      options: ['Pasayloha ako', 'Walay sapayan', 'Madyaw na maudto', 'Ako si...'],
      correctOptionIndex: 1,
    ),
    DuelQuestion(
      id: 'q5',
      questionText: 'What is the Mansaka greeting for "Good evening"?',
      targetMansaka: 'Madyaw na masawg',
      targetEnglish: 'Good evening',
      options: ['Madyaw na masawg', 'Madyaw na masurom', 'Madyaw na maudto', 'Salamat sa tanan'],
      correctOptionIndex: 0,
    ),
  ];

  /// Enters matchmaking queue or creates a new waiting session
  Future<String> findOrCreateMatch({required String userName}) async {
    final user = _auth.currentUser;
    final uid = user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';

    try {
      // 1. Look for an existing open waiting session
      final waitingQuery = await _firestore
          .collection('duel_sessions')
          .where('status', isEqualTo: 'waiting')
          .limit(1)
          .get();

      if (waitingQuery.docs.isNotEmpty) {
        final doc = waitingQuery.docs.first;
        final data = doc.data();
        if (data['player1Id'] != uid) {
          // Join as Player 2
          await doc.reference.update({
            'player2Id': uid,
            'player2Name': userName,
            'status': 'active',
          });
          return doc.id;
        }
      }

      // 2. Create a new waiting session
      final newDoc = _firestore.collection('duel_sessions').doc();
      final session = DuelSessionModel(
        id: newDoc.id,
        player1Id: uid,
        player1Name: userName,
        player1Score: 0,
        player1Hp: 100,
        player2Score: 0,
        player2Hp: 100,
        status: 'waiting',
        currentRound: 0,
        questions: _sampleDuelQuestions,
        createdAt: DateTime.now(),
      );

      await newDoc.set(session.toJson());
      return newDoc.id;
    } catch (e) {
      // Offline fallback: return a mock local session ID
      return 'local_duel_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Streams real-time updates for an active duel session
  Stream<DuelSessionModel?> watchDuelSession(String sessionId) {
    return _firestore
        .collection('duel_sessions')
        .doc(sessionId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return DuelSessionModel(
          id: sessionId,
          player1Id: _auth.currentUser?.uid ?? 'p1',
          player1Name: 'You',
          player2Id: 'bot_ai',
          player2Name: 'AI Rival (Bot)',
          status: 'active',
          questions: _sampleDuelQuestions,
        );
      }
      return DuelSessionModel.fromJson(snapshot.data()!);
    });
  }

  /// Submits an answer for the current round and calculates speed points / HP reduction
  Future<void> submitRoundAnswer({
    required String sessionId,
    required bool isPlayer1,
    required bool isCorrect,
    required int responseTimeMs,
    required int currentRound,
  }) async {
    try {
      final docRef = _firestore.collection('duel_sessions').doc(sessionId);
      final doc = await docRef.get();
      if (!doc.exists || doc.data() == null) return;

      final data = doc.data()!;
      final speedBonus = isCorrect ? ((10000 - responseTimeMs).clamp(0, 10000) ~/ 100) : 0;
      final pointsEarned = isCorrect ? (100 + speedBonus) : 0;
      final hpDamage = isCorrect ? 0 : 20;

      if (isPlayer1) {
        final newScore = (data['player1Score'] as int? ?? 0) + pointsEarned;
        final newHp = ((data['player1Hp'] as int? ?? 100) - hpDamage).clamp(0, 100);
        await docRef.update({
          'player1Score': newScore,
          'player1Hp': newHp,
          'currentRound': currentRound + 1,
        });
      } else {
        final newScore = (data['player2Score'] as int? ?? 0) + pointsEarned;
        final newHp = ((data['player2Hp'] as int? ?? 100) - hpDamage).clamp(0, 100);
        await docRef.update({
          'player2Score': newScore,
          'player2Hp': newHp,
          'currentRound': currentRound + 1,
        });
      }
    } catch (_) {}
  }

  /// Finalizes the duel session and sets the winner
  Future<void> completeMatch({required String sessionId, required String winnerId}) async {
    try {
      await _firestore.collection('duel_sessions').doc(sessionId).update({
        'status': 'completed',
        'winnerId': winnerId,
      });
    } catch (_) {}
  }
}

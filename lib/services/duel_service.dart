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

  /// Fetches dynamic questions from Firebase (learning_activities / vocabulary) with fallback to sample
  Future<List<DuelQuestion>> _fetchFirebaseQuestions() async {
    try {
      final activitiesSnapshot = await _firestore.collection('learning_activities').limit(5).get();
      if (activitiesSnapshot.docs.isNotEmpty) {
        List<DuelQuestion> questions = [];
        for (var doc in activitiesSnapshot.docs) {
          final data = doc.data();
          final options = List<String>.from(data['options'] ?? ['Option A', 'Option B', 'Option C', 'Option D']);
          final correctIdx = data['correctOptionIndex'] ?? 0;
          questions.add(DuelQuestion(
            id: doc.id,
            questionText: data['questionText'] ?? 'Translate the Mansaka term:',
            targetMansaka: options.isNotEmpty && correctIdx < options.length ? options[correctIdx] : 'Mansaka',
            targetEnglish: data['questionText'] ?? '',
            options: options,
            correctOptionIndex: correctIdx,
          ));
        }
        if (questions.isNotEmpty) return questions;
      }

      final vocabSnapshot = await _firestore.collection('vocabulary').limit(5).get();
      if (vocabSnapshot.docs.isNotEmpty) {
        List<DuelQuestion> questions = [];
        for (var doc in vocabSnapshot.docs) {
          final data = doc.data();
          final headword = data['headword'] ?? 'Salita';
          final translation = data['translation'] ?? 'Translation';

          List<String> opts = [translation, 'Alternative 1', 'Alternative 2', 'Alternative 3'];
          opts.shuffle();
          final correctIdx = opts.indexOf(translation);

          questions.add(DuelQuestion(
            id: doc.id,
            questionText: 'What is the English meaning of "$headword"?',
            targetMansaka: headword,
            targetEnglish: translation,
            options: opts,
            correctOptionIndex: correctIdx >= 0 ? correctIdx : 0,
          ));
        }
        if (questions.isNotEmpty) return questions;
      }
    } catch (_) {}
    return _sampleDuelQuestions;
  }

  /// Checks if an existing human player is waiting in a duel session
  Future<String?> findExistingHumanMatch({required String userName}) async {
    final user = _auth.currentUser;
    final uid = user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';

    try {
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
    } catch (_) {}
    return null;
  }

  /// Creates a waiting session hosted by the user while waiting for a human opponent
  Future<String> createWaitingSession({required String userName}) async {
    final user = _auth.currentUser;
    final uid = user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';

    try {
      final duelQuestions = await _fetchFirebaseQuestions();
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
        questions: duelQuestions,
        createdAt: DateTime.now(),
      );

      await newDoc.set(session.toJson());
      return newDoc.id;
    } catch (e) {
      return 'local_duel_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Cancels and deletes a waiting room if search times out or is cancelled
  Future<void> cancelWaitingSession(String sessionId) async {
    try {
      await _firestore.collection('duel_sessions').doc(sessionId).delete();
    } catch (_) {}
  }

  /// Legacy helper for fallback
  Future<String> findOrCreateMatch({required String userName}) async {
    final existingId = await findExistingHumanMatch(userName: userName);
    if (existingId != null) return existingId;
    return createWaitingSession(userName: userName);
  }

  /// Creates an instant bot match session against AI Rival Bot
  Future<String> createBotMatch({required String userName}) async {
    final user = _auth.currentUser;
    final uid = user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';

    try {
      final duelQuestions = await _fetchFirebaseQuestions();
      final newDoc = _firestore.collection('duel_sessions').doc();
      final session = DuelSessionModel(
        id: newDoc.id,
        player1Id: uid,
        player1Name: userName,
        player1Score: 0,
        player1Hp: 100,
        player2Id: 'bot_ai',
        player2Name: 'AI Rival (Bot)',
        player2Score: 0,
        player2Hp: 100,
        status: 'active',
        currentRound: 0,
        questions: duelQuestions,
        createdAt: DateTime.now(),
      );

      await newDoc.set(session.toJson());
      return newDoc.id;
    } catch (e) {
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

      final speedBonus = isCorrect ? ((10000 - responseTimeMs).clamp(0, 10000) ~/ 100) : 0;
      final pointsEarned = isCorrect ? (100 + speedBonus) : 0;
      final hpDamage = isCorrect ? 0 : 20;

      if (!doc.exists || doc.data() == null) {
        return;
      }

      final data = doc.data()!;
      final isBotMatch = data['player2Id'] == 'bot_ai';

      int p1Score = data['player1Score'] as int? ?? 0;
      int p1Hp = data['player1Hp'] as int? ?? 100;
      int p2Score = data['player2Score'] as int? ?? 0;
      int p2Hp = data['player2Hp'] as int? ?? 100;

      if (isPlayer1) {
        p1Score += pointsEarned;
        p1Hp = (p1Hp - hpDamage).clamp(0, 100);

        if (isBotMatch) {
          // Simulate dynamic AI bot response (70% accuracy)
          final botCorrect = (DateTime.now().millisecondsSinceEpoch % 10) < 7;
          final botPoints = botCorrect ? 175 : 0;
          final botDamage = botCorrect ? 0 : 20;
          p2Score += botPoints;
          p2Hp = (p2Hp - botDamage).clamp(0, 100);
        }
      } else {
        p2Score += pointsEarned;
        p2Hp = (p2Hp - hpDamage).clamp(0, 100);
      }

      await docRef.update({
        'player1Score': p1Score,
        'player1Hp': p1Hp,
        'player2Score': p2Score,
        'player2Hp': p2Hp,
        'currentRound': currentRound + 1,
      });
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

import 'dart:math';
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
      final activitiesSnapshot = await _firestore.collection('learning_activities').limit(10).get();
      if (activitiesSnapshot.docs.isNotEmpty) {
        List<DuelQuestion> questions = [];
        for (var doc in activitiesSnapshot.docs) {
          final data = doc.data();
          final rawOptions = data['options'] as List<dynamic>?;
          if (rawOptions != null && rawOptions.isNotEmpty) {
            final options = List<String>.from(rawOptions);
            final correctIdx = (data['correctOptionIndex'] as num?)?.toInt() ?? 0;
            questions.add(DuelQuestion(
              id: doc.id,
              questionText: data['questionText'] ?? 'Translate the Mansaka term:',
              targetMansaka: options.isNotEmpty && correctIdx < options.length ? options[correctIdx] : 'Mansaka',
              targetEnglish: data['questionText'] ?? '',
              options: options,
              correctOptionIndex: correctIdx.clamp(0, options.length - 1),
            ));
          }
        }
        if (questions.isNotEmpty) return questions.take(5).toList();
      }

      final vocabSnapshot = await _firestore.collection('vocabulary').limit(15).get();
      if (vocabSnapshot.docs.isNotEmpty) {
        final allDocs = vocabSnapshot.docs;
        final allTranslations = allDocs.map((d) => d.data()['translation'] as String? ?? 'Translation').toSet().toList();

        List<DuelQuestion> questions = [];
        for (var doc in allDocs) {
          final data = doc.data();
          final headword = data['headword'] ?? 'Salita';
          final translation = data['translation'] ?? 'Translation';

          final alternatives = allTranslations.where((t) => t != translation).toList()..shuffle();
          final alt1 = alternatives.isNotEmpty ? alternatives[0] : 'Good morning';
          final alt2 = alternatives.length > 1 ? alternatives[1] : 'Thank you';
          final alt3 = alternatives.length > 2 ? alternatives[2] : 'House';

          List<String> opts = [translation, alt1, alt2, alt3];
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
        if (questions.isNotEmpty) return questions.take(5).toList();
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
          .limit(10)
          .get();

      for (var doc in waitingQuery.docs) {
        final data = doc.data();
        if (data['player1Id'] != uid && data['player2Id'] == null) {
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

  /// Generates a 6-character private room code (e.g. DUEL-942) and creates a waiting session
  Future<Map<String, String>> createPrivateRoomSession({required String userName}) async {
    final user = _auth.currentUser;
    final uid = user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
    final randomNum = (100 + Random().nextInt(900)).toString();
    final code = 'DUEL-$randomNum';

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
        roomCode: code,
      );

      await newDoc.set(session.toJson());
      return {'sessionId': newDoc.id, 'roomCode': code};
    } catch (e) {
      return {'sessionId': 'local_duel_${DateTime.now().millisecondsSinceEpoch}', 'roomCode': code};
    }
  }

  /// Joins a private room using a 6-character code (e.g. DUEL-942)
  Future<String> joinRoomByCode({required String roomCode, required String userName}) async {
    final user = _auth.currentUser;
    final uid = user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
    final normalizedCode = roomCode.trim().toUpperCase();

    final query = await _firestore
        .collection('duel_sessions')
        .where('roomCode', isEqualTo: normalizedCode)
        .where('status', isEqualTo: 'waiting')
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('No open private room found with code "$normalizedCode".');
    }

    final doc = query.docs.first;
    final data = doc.data();
    if (data['player1Id'] == uid) {
      return doc.id;
    }

    await doc.reference.update({
      'player2Id': uid,
      'player2Name': userName,
      'status': 'active',
    });

    return doc.id;
  }

  /// Requests an instant rematch against the same opponent or bot
  Future<String> requestRematch({required String previousSessionId, required String userName}) async {
    try {
      final doc = await _firestore.collection('duel_sessions').doc(previousSessionId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final isBotMatch = data['player2Id'] == 'bot_ai';
        if (isBotMatch) {
          return await createBotMatch(userName: userName);
        }
      }
    } catch (_) {}
    return await createBotMatch(userName: userName);
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

  /// Finalizes the duel session and sets the winner (cleans up bot sessions to prevent clutter)
  Future<void> completeMatch({required String sessionId, required String winnerId}) async {
    try {
      final docRef = _firestore.collection('duel_sessions').doc(sessionId);
      final doc = await docRef.get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final isBotMatch = data['player2Id'] == 'bot_ai';
        if (isBotMatch) {
          await docRef.delete();
          return;
        }

        // If the match was already finalized by the first completing client, preserve the existing winner
        if (data['status'] == 'completed' && data['winnerId'] != null) {
          return;
        }
      }

      await docRef.update({
        'status': 'completed',
        'winnerId': winnerId,
      });
    } catch (_) {}
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'firestore_service.dart';
import '../utils/audio_cache_manager.dart';

class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  Database? _db;
  bool _isSyncing = false;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'lumad_offline_queue.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE offline_actions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            action_type TEXT NOT NULL,
            payload TEXT NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE cached_vocabulary (
            id TEXT PRIMARY KEY,
            mansaka TEXT NOT NULL,
            english TEXT NOT NULL,
            category TEXT,
            audio_url TEXT,
            example_mansaka TEXT,
            example_english TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE local_lesson_progress (
            lesson_id TEXT PRIMARY KEY,
            stars INTEGER NOT NULL,
            is_completed INTEGER NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS cached_vocabulary (
              id TEXT PRIMARY KEY,
              mansaka TEXT NOT NULL,
              english TEXT NOT NULL,
              category TEXT,
              audio_url TEXT,
              example_mansaka TEXT,
              example_english TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS local_lesson_progress (
              lesson_id TEXT PRIMARY KEY,
              stars INTEGER NOT NULL,
              is_completed INTEGER NOT NULL,
              timestamp INTEGER NOT NULL
            )
          ''');
        }
      },
    );
  }

  /// Initialize connectivity monitoring and auto-sync
  void initializeAutoSync() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final hasConnection = results.any((result) => result != ConnectivityResult.none);
      if (hasConnection) {
        debugPrint('🌐 Network connectivity restored. Triggering offline queue sync...');
        syncPendingActions();
      }
    });

    // Initial check on startup
    Connectivity().checkConnectivity().then((results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        syncPendingActions();
      }
    });
  }

  /// Queue an offline action (e.g., complete lesson, streak update, XP gain)
  Future<void> queueAction(String actionType, Map<String, dynamic> payload) async {
    try {
      final db = await database;
      await db.insert('offline_actions', {
        'action_type': actionType,
        'payload': jsonEncode(payload),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      debugPrint('📦 Queued offline action [$actionType] successfully.');
    } catch (e) {
      debugPrint('❌ Failed to queue offline action: $e');
    }
  }

  /// Get number of pending offline actions
  Future<int> getPendingCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM offline_actions');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      debugPrint('❌ Failed to get pending offline action count: $e');
      return 0;
    }
  }

  /// Cache vocabulary words locally for offline dictionary searching and pre-cache audio assets
  Future<void> cacheVocabulary(List<Map<String, dynamic>> words) async {
    try {
      final db = await database;
      final batch = db.batch();
      final List<String> audioUrls = [];

      for (var word in words) {
        final audioUrl = word['audioUrl'] as String?;
        if (audioUrl != null && audioUrl.trim().isNotEmpty) {
          audioUrls.add(audioUrl);
        }

        batch.insert(
          'cached_vocabulary',
          {
            'id': word['id'] ?? word['mansaka'],
            'mansaka': word['mansaka'],
            'english': word['english'],
            'category': word['category'] ?? 'General',
            'audio_url': audioUrl,
            'example_mansaka': word['exampleMansaka'],
            'example_english': word['exampleEnglish'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
      debugPrint('📚 Successfully cached ${words.length} vocabulary words locally.');

      // Pre-cache audio assets in the background
      if (audioUrls.isNotEmpty) {
        AudioCacheManager.preCacheAudioList(audioUrls);
      }
    } catch (e) {
      debugPrint('❌ Failed to cache vocabulary locally: $e');
    }
  }

  /// Retrieve cached vocabulary offline
  Future<List<Map<String, dynamic>>> getCachedVocabulary({String? category, String? query}) async {
    try {
      final db = await database;
      String whereClause = '1=1';
      List<Object?> whereArgs = [];

      if (category != null && category != 'All') {
        whereClause += ' AND category = ?';
        whereArgs.add(category);
      }

      if (query != null && query.trim().isNotEmpty) {
        whereClause += ' AND (mansaka LIKE ? OR english LIKE ?)';
        whereArgs.add('%${query.trim()}%');
        whereArgs.add('%${query.trim()}%');
      }

      final results = await db.query(
        'cached_vocabulary',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'mansaka ASC',
      );
      return results;
    } catch (e) {
      debugPrint('❌ Failed to fetch cached vocabulary: $e');
      return [];
    }
  }

  /// Cache local lesson progress
  Future<void> cacheLessonProgress(String lessonId, int stars) async {
    try {
      final db = await database;
      await db.insert(
        'local_lesson_progress',
        {
          'lesson_id': lessonId,
          'stars': stars,
          'is_completed': 1,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('⭐ Cached lesson progress locally for $lessonId ($stars stars).');
    } catch (e) {
      debugPrint('❌ Failed to cache lesson progress: $e');
    }
  }

  /// Get local lesson progress stars
  Future<int?> getLocalLessonStars(String lessonId) async {
    try {
      final db = await database;
      final results = await db.query(
        'local_lesson_progress',
        where: 'lesson_id = ?',
        whereArgs: [lessonId],
      );
      if (results.isNotEmpty) {
        return results.first['stars'] as int?;
      }
    } catch (e) {
      debugPrint('❌ Failed to get local lesson stars: $e');
    }
    return null;
  }

  /// Sync all pending offline actions to backend (Firestore / Supabase)
  Future<void> syncPendingActions() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final db = await database;
      final actions = await db.query('offline_actions', orderBy: 'timestamp ASC');

      if (actions.isEmpty) {
        _isSyncing = false;
        return;
      }

      debugPrint('🔄 Syncing ${actions.length} pending offline actions to backend...');
      final firestoreService = FirestoreService();

      for (var action in actions) {
        final id = action['id'] as int;
        final actionType = action['action_type'] as String;
        final payload = jsonDecode(action['payload'] as String) as Map<String, dynamic>;

        try {
          switch (actionType) {
            case 'complete_lesson':
              final userId = payload['userId'] as String;
              final lessonId = payload['lessonId'] as String;
              final xpEarned = (payload['xpEarned'] as int?) ?? 50;
              final starsEarned = ((payload['starsEarned'] as int?) ?? 3).clamp(1, 3);
              await firestoreService.updateLessonProgress(userId, lessonId, starsEarned);
              await firestoreService.addXp(userId, xpEarned);
              break;

            case 'update_streak':
              final userId = payload['userId'] as String;
              final streakDays = payload['streakDays'] as int;
              await firestoreService.updateStreak(userId, streakDays);
              break;

            case 'update_xp':
              final userId = payload['userId'] as String;
              final xp = payload['xp'] as int;
              await firestoreService.addXp(userId, xp);
              break;

            default:
              debugPrint('⚠️ Unknown offline action type: $actionType');
          }

          // Delete action upon successful sync
          await db.delete('offline_actions', where: 'id = ?', whereArgs: [id]);
          debugPrint('✅ Successfully synced and removed offline action ID: $id');
        } catch (e) {
          debugPrint('⚠️ Failed to sync action ID $id ($actionType): $e');
          // Stop sync loop if network drops during sync
          break;
        }
      }
    } catch (e) {
      debugPrint('❌ Error during offline queue sync: $e');
    } finally {
      _isSyncing = false;
    }
  }
}

import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/vocabulary_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'lumad_dictionary.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE vocabulary (
            id TEXT PRIMARY KEY,
            headword TEXT,
            translation TEXT,
            partOfSpeech TEXT,
            examples TEXT,
            audioUrl TEXT,
            pronunciation TEXT,
            notes TEXT
          )
        ''');
        await db.execute('CREATE INDEX idx_headword ON vocabulary(headword)');
        await db.execute('CREATE INDEX idx_translation ON vocabulary(translation)');
        await db.execute('CREATE INDEX idx_pos ON vocabulary(partOfSpeech)');
      },
    );
  }

  Future<void> insertVocabularyBatch(List<VocabularyModel> words) async {
    final db = await database;
    final batch = db.batch();
    for (final word in words) {
      batch.insert(
        'vocabulary',
        {
          'id': word.id,
          'headword': word.headword,
          'translation': word.translation,
          'partOfSpeech': word.partOfSpeech,
          'examples': jsonEncode(word.examples.map((e) => e.toJson()).toList()),
          'audioUrl': word.audioUrl,
          'pronunciation': word.pronunciation,
          'notes': word.notes,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<VocabularyModel>> getVocabularyPaged({
    int limit = 50,
    int offset = 0,
    String? searchQuery,
    String? partOfSpeech,
  }) async {
    final db = await database;
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim().toLowerCase()}%';
      whereClause += ' AND (LOWER(headword) LIKE ? OR LOWER(translation) LIKE ?)';
      whereArgs.addAll([q, q]);
    }

    if (partOfSpeech != null && partOfSpeech.trim().isNotEmpty && partOfSpeech != 'All') {
      whereClause += ' AND LOWER(partOfSpeech) = ?';
      whereArgs.add(partOfSpeech.trim().toLowerCase());
    }

    final maps = await db.query(
      'vocabulary',
      where: whereClause,
      whereArgs: whereArgs,
      limit: limit,
      offset: offset,
      orderBy: 'headword ASC',
    );

    return maps.map((map) => _mapToVocabulary(map)).toList();
  }

  Future<int> getVocabularyCount({String? searchQuery, String? partOfSpeech}) async {
    final db = await database;
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim().toLowerCase()}%';
      whereClause += ' AND (LOWER(headword) LIKE ? OR LOWER(translation) LIKE ?)';
      whereArgs.addAll([q, q]);
    }

    if (partOfSpeech != null && partOfSpeech.trim().isNotEmpty && partOfSpeech != 'All') {
      whereClause += ' AND LOWER(partOfSpeech) = ?';
      whereArgs.add(partOfSpeech.trim().toLowerCase());
    }

    final result = await db.rawQuery('SELECT COUNT(*) as count FROM vocabulary WHERE $whereClause', whereArgs);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<VocabularyModel?> getWordById(String id) async {
    final db = await database;
    final maps = await db.query('vocabulary', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return _mapToVocabulary(maps.first);
  }

  Future<List<String>> getAllPartsOfSpeech() async {
    final db = await database;
    final maps = await db.rawQuery('SELECT DISTINCT partOfSpeech FROM vocabulary WHERE partOfSpeech IS NOT NULL ORDER BY partOfSpeech ASC');
    return maps.map((m) => m['partOfSpeech'] as String? ?? '').where((s) => s.isNotEmpty).toList();
  }

  Future<void> clear() async {
    final db = await database;
    await db.delete('vocabulary');
  }

  VocabularyModel _mapToVocabulary(Map<String, dynamic> map) {
    List<VocabularyExample> parsedExamples = [];
    try {
      final dynamic exData = map['examples'];
      if (exData is String && exData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(exData);
        parsedExamples = decoded.map((e) => VocabularyExample.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    return VocabularyModel(
      id: map['id'] as String? ?? '',
      headword: map['headword'] as String? ?? '',
      translation: map['translation'] as String? ?? '',
      partOfSpeech: map['partOfSpeech'] as String? ?? 'Noun',
      examples: parsedExamples,
      audioUrl: map['audioUrl'] as String?,
      pronunciation: map['pronunciation'] as String?,
      notes: map['notes'] as String?,
    );
  }
}

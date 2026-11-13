import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAudioService {
  final SupabaseClient? _supabaseClient;

  SupabaseAudioService({SupabaseClient? supabaseClient})
      : _supabaseClient = _safeSupabaseClient(supabaseClient);

  static SupabaseClient? _safeSupabaseClient(SupabaseClient? client) {
    if (client != null) return client;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Uploads a learner voice recording to the 'learner-recordings' Supabase bucket
  /// Returns the public or signed storage URL, or null if offline/uninitialized.
  Future<String?> uploadLearnerRecording({
    required String filePath,
    required String userId,
    required String wordId,
  }) async {
    final client = _supabaseClient;
    if (client == null) {
      debugPrint('Supabase not initialized: skipping audio upload.');
      return null;
    }

    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_${wordId}_$timestamp.m4a';
      const bucketName = 'learner_attempts';

      await client.storage.from(bucketName).upload(
            fileName,
            file,
          );

      final publicUrl = client.storage.from(bucketName).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading audio to Supabase: $e');
      return null;
    }
  }

  /// Retrieves or caches a reference audio file from 'audio' bucket locally
  Future<String?> getCachedReferenceAudio(String audioFileName) async {
    final client = _supabaseClient;
    if (client == null) return null;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final localFile = File('${dir.path}/$audioFileName');

      if (await localFile.exists()) {
        return localFile.path;
      }

      const bucketName = 'audio';
      final Uint8List bytes = await client.storage.from(bucketName).download(audioFileName);
      await localFile.writeAsBytes(bytes);
      return localFile.path;
    } catch (e) {
      debugPrint('Error downloading reference audio: $e');
      return null;
    }
  }
}

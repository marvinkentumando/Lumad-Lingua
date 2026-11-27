import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'audio_helper.dart';

class AudioCacheManager {
  static const String _cacheFolderName = 'audio_cache';

  /// Gets the local cache directory path for audio files.
  static Future<Directory> _getCacheDirectory() async {
    final docDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${docDir.path}/$_cacheFolderName');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  /// Generates a unique local filename based on the audio URL or path.
  static String _generateCacheFileName(String audioUrl) {
    final uri = Uri.tryParse(audioUrl);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      final lastSegment = uri.pathSegments.last;
      if (lastSegment.endsWith('.mp3') || lastSegment.endsWith('.m4a') || lastSegment.endsWith('.wav')) {
        return lastSegment;
      }
    }
    final hash = audioUrl.hashCode.abs();
    return 'audio_$hash.mp3';
  }

  /// Retrieves the cached local file path for an audio URL/path.
  /// Downloads and caches the file if it is not already present locally.
  /// Returns null if offline and the file was not previously cached.
  static Future<String?> getOrCacheAudio(String rawAudioPath) async {
    final resolvedUrl = AudioHelper.resolveSupabaseAudioUrl(rawAudioPath);
    if (resolvedUrl == null) return null;

    try {
      final cacheDir = await _getCacheDirectory();
      final fileName = _generateCacheFileName(resolvedUrl);
      final localFile = File('${cacheDir.path}/$fileName');

      // 1. Return cached file path if already available on disk
      if (await localFile.exists() && await localFile.length() > 0) {
        debugPrint('🎧 AudioCacheManager: Cache hit for $fileName');
        return localFile.path;
      }

      // 2. Download and cache file if network is available
      debugPrint('🌐 AudioCacheManager: Cache miss. Downloading $resolvedUrl...');
      final response = await http.get(Uri.parse(resolvedUrl)).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        await localFile.writeAsBytes(response.bodyBytes);
        debugPrint('💾 AudioCacheManager: Successfully cached $fileName (${response.bodyBytes.length} bytes)');
        return localFile.path;
      }
    } catch (e) {
      debugPrint('⚠️ AudioCacheManager: Error/Offline caching audio ($rawAudioPath): $e');
    }

    // Fallback: If download failed or offline, return null
    return null;
  }

  /// Pre-caches a list of audio URLs/paths in the background (e.g. for offline sync).
  static Future<void> preCacheAudioList(List<String> audioPaths) async {
    for (final path in audioPaths) {
      await getOrCacheAudio(path);
    }
  }

  /// Clears all cached audio files to free up disk space.
  static Future<void> clearCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        debugPrint('🗑️ AudioCacheManager: Cache cleared successfully.');
      }
    } catch (e) {
      debugPrint('Error clearing audio cache: $e');
    }
  }
}

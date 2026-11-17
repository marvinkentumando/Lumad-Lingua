import 'package:just_audio/just_audio.dart';

class AudioHelper {
  static const String _supabaseBaseUrl = 'https://ovdwgowtnlujnbcyldkk.supabase.co';
  static const String _bucketName = 'audio';
  static final AudioPlayer _player = AudioPlayer();

  /// Resolves relative audio paths into public Supabase Storage URLs.
  static String? resolveSupabaseAudioUrl(String? audioPath) {
    if (audioPath == null || audioPath.trim().isEmpty) {
      return null;
    }

    final trimmed = audioPath.trim();

    // If already absolute URL
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    // Clean path: strip leading slash and leading 'audio/' prefix
    String cleanPath = trimmed;
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    if (cleanPath.startsWith('audio/')) {
      cleanPath = cleanPath.substring(6);
    }

    return '$_supabaseBaseUrl/storage/v1/object/public/$_bucketName/$cleanPath';
  }

  /// Plays audio from path or URL (supports local asset paths starting with 'assets/' and remote Supabase URLs)
  static Future<void> playAudio(String audioPath) async {
    try {
      final trimmed = audioPath.trim();
      if (trimmed.startsWith('assets/')) {
        await _player.setAsset(trimmed);
        await _player.play();
      } else {
        final url = resolveSupabaseAudioUrl(trimmed);
        if (url != null) {
          await _player.setUrl(url);
          await _player.play();
        }
      }
    } catch (_) {}
  }
}

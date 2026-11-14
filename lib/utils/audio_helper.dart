class AudioHelper {
  static const String _supabaseBaseUrl = 'https://ovdwgowtnlujnbcyldkk.supabase.co';
  static const String _bucketName = 'audio';

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
}

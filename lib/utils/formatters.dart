class AppFormatters {
  static String formatXP(int xp) {
    if (xp >= 1000) {
      return '${(xp / 1000).toStringAsFixed(1)}k XP';
    }
    return '$xp XP';
  }

  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  static String formatPercentage(double value) {
    return '${(value * 100).toInt()}%';
  }
}

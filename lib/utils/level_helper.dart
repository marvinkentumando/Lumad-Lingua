class LevelHelper {
  static int calculateLevel(int totalXp) {
    int level = 1;
    int xpForNext = 100;
    int accumulated = 0;
    while (totalXp >= accumulated + xpForNext) {
      accumulated += xpForNext;
      level++;
      xpForNext += 50;
    }
    return level;
  }

  static Map<String, int> getLevelProgress(int totalXp) {
    int level = 1;
    int xpForNext = 100;
    int accumulated = 0;
    while (totalXp >= accumulated + xpForNext) {
      accumulated += xpForNext;
      level++;
      xpForNext += 50;
    }
    int currentLevelXp = totalXp - accumulated;
    return {
      'level': level,
      'currentLevelXp': currentLevelXp,
      'xpNeededForNextLevel': xpForNext,
    };
  }

  static double getLevelProgressRatio(int totalXp) {
    final progress = getLevelProgress(totalXp);
    final current = progress['currentLevelXp'] ?? 0;
    final needed = progress['xpNeededForNextLevel'] ?? 100;
    if (needed <= 0) return 1.0;
    return (current / needed).clamp(0.0, 1.0);
  }

  static String getLevelTitle(int level) {
    if (level <= 1) return 'Beginning Learner 📚';
    if (level == 2) return 'Mansaka Explorer 🌿';
    if (level == 3) return 'Cultural Student 🗣️';
    if (level == 4) return 'Heritage Guardian 🛡️';
    if (level == 5) return 'Banwa Scholar 🏫';
    if (level == 6) return 'Speech Master 🎤';
    if (level == 7) return 'Ancestral Sage 📜';
    return 'Datu Honor Elder 👑';
  }
}

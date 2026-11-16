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
}

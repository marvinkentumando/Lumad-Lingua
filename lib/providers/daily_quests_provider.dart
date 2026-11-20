import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_quest_model.dart';
import 'auth_provider.dart';

String _todayDateKey(String userId) {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return 'lumad_daily_quests_${userId}_${now.year}-$month-$day';
}

List<DailyQuestModel> _generateDefaultQuestsForToday() {
  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;

  // Set A and Set B rotation for daily variety
  if (dayOfYear % 2 == 0) {
    return [
      const DailyQuestModel(
        id: 'q_lesson_1',
        title: 'Complete a Mansaka Lesson',
        description: 'Finish any active lesson in your learning path',
        xpReward: 50,
        crystalReward: 10,
        targetCount: 1,
        route: '/learn',
        type: QuestType.lesson,
      ),
      const DailyQuestModel(
        id: 'q_pronunciation_1',
        title: 'Pronunciation Trial',
        description: 'Record & evaluate your Mansaka pronunciation',
        xpReward: 40,
        crystalReward: 10,
        targetCount: 1,
        route: '/pronunciation',
        type: QuestType.pronunciation,
      ),
      const DailyQuestModel(
        id: 'q_duel_1',
        title: 'Lingua Duels PvP',
        description: 'Compete in a rapid-fire vocabulary duel',
        xpReward: 100,
        crystalReward: 20,
        targetCount: 1,
        route: '/arena',
        type: QuestType.duel,
      ),
    ];
  } else {
    return [
      const DailyQuestModel(
        id: 'q_dictionary_1',
        title: 'Dictionary Explorer',
        description: 'Explore at least 2 dictionary word entries',
        xpReward: 40,
        crystalReward: 10,
        targetCount: 2,
        route: '/dictionary',
        type: QuestType.dictionary,
      ),
      const DailyQuestModel(
        id: 'q_pronunciation_2',
        title: 'Voice Master',
        description: 'Record & test 2 pronunciation phrases',
        xpReward: 60,
        crystalReward: 15,
        targetCount: 2,
        route: '/pronunciation',
        type: QuestType.pronunciation,
      ),
      const DailyQuestModel(
        id: 'q_lesson_2',
        title: 'Daily Scholar',
        description: 'Finish a Mansaka interactive unit drill',
        xpReward: 50,
        crystalReward: 10,
        targetCount: 1,
        route: '/learn',
        type: QuestType.lesson,
      ),
    ];
  }
}

class DailyQuestsNotifier extends Notifier<List<DailyQuestModel>> {
  @override
  List<DailyQuestModel> build() {
    _loadState();
    return _generateDefaultQuestsForToday();
  }

  Future<void> _loadState() async {
    try {
      final user = ref.read(authStateProvider).value;
      final userId = user?.id ?? 'guest';
      final prefs = await SharedPreferences.getInstance();
      final key = _todayDateKey(userId);
      final defaultQuests = _generateDefaultQuestsForToday();
      final jsonStr = prefs.getString(key);

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        final Map<String, Map<String, dynamic>> savedData = {};
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            savedData[item['id'] as String? ?? ''] = item;
          }
        }

        final updated = defaultQuests.map((q) {
          if (savedData.containsKey(q.id)) {
            return DailyQuestModel.fromJson(q, savedData[q.id]!);
          }
          return q;
        }).toList();

        state = updated;
      } else {
        state = defaultQuests;
      }
    } catch (_) {}
  }

  Future<void> _saveState() async {
    try {
      final user = ref.read(authStateProvider).value;
      final userId = user?.id ?? 'guest';
      final prefs = await SharedPreferences.getInstance();
      final key = _todayDateKey(userId);
      final listJson = state.map((q) => q.toJson()).toList();
      await prefs.setString(key, jsonEncode(listJson));
    } catch (_) {}
  }

  void incrementProgress(QuestType type, [int amount = 1]) {
    bool changed = false;
    final updated = state.map((q) {
      if (q.type == type && !q.isClaimed && q.currentCount < q.targetCount) {
        changed = true;
        return q.copyWith(currentCount: (q.currentCount + amount).clamp(0, q.targetCount));
      }
      return q;
    }).toList();

    if (changed) {
      state = updated;
      _saveState();
    }
  }

  Future<bool> claimQuest(String questId) async {
    final index = state.indexWhere((q) => q.id == questId);
    if (index == -1) return false;

    final quest = state[index];
    if (quest.isClaimed || !quest.isCompleted) return false;

    // Grant XP and Crystals
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      final authNotifier = ref.read(authStateProvider.notifier);
      authNotifier.addXp(quest.xpReward);
      authNotifier.updateCrystals(user.crystals + quest.crystalReward);
    }

    final updated = List<DailyQuestModel>.from(state);
    updated[index] = quest.copyWith(isClaimed: true);
    state = updated;

    await _saveState();
    return true;
  }
}

final dailyQuestsProvider = NotifierProvider<DailyQuestsNotifier, List<DailyQuestModel>>(() {
  return DailyQuestsNotifier();
});

import 'package:flutter_test/flutter_test.dart';
import 'package:lumad_lingua/models/achievement_model.dart';

void main() {
  group('AchievementModel Serialization & Emoji Resolution Tests', () {
    test('AchievementModel fromJson parses correctly', () {
      final json = {
        'id': 'ach_1',
        'title': 'First Steps',
        'description': 'Complete your first lesson',
        'iconName': 'BookOpen',
        'xpRequirement': 50,
        'isUnlocked': true,
        'progressRatio': 1.0,
      };

      final achievement = AchievementModel.fromJson(json);

      expect(achievement.id, 'ach_1');
      expect(achievement.title, 'First Steps');
      expect(achievement.description, 'Complete your first lesson');
      expect(achievement.iconName, 'BookOpen');
      expect(achievement.xpRequirement, 50);
      expect(achievement.isUnlocked, true);
      expect(achievement.progressRatio, 1.0);
    });

    test('Legacy icon mapping resolves to correct emoji', () {
      const achievement = AchievementModel(
        id: 'ach_2',
        title: 'Legacy',
        description: 'Testing legacy icon map',
        iconName: 'Flame',
      );

      expect(achievement.resolvedEmoji, '🔥');
    });

    test('Custom emoji icon name resolves directly', () {
      const achievement = AchievementModel(
        id: 'ach_3',
        title: 'Custom',
        description: 'Testing custom emoji',
        iconName: '🌿',
      );

      expect(achievement.resolvedEmoji, '🌿');
    });

    test('AchievementModel toJson serializes correctly', () {
      const achievement = AchievementModel(
        id: 'ach_1',
        title: 'First Steps',
        description: 'Complete your first lesson',
        iconName: 'BookOpen',
        xpRequirement: 50,
        isUnlocked: true,
        progressRatio: 1.0,
      );

      final json = achievement.toJson();

      expect(json['id'], 'ach_1');
      expect(json['title'], 'First Steps');
      expect(json['xpRequirement'], 50);
      expect(json['isUnlocked'], true);
      expect(json['progressRatio'], 1.0);
    });
  });
}

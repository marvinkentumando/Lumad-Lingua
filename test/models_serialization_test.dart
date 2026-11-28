import 'package:flutter_test/flutter_test.dart';
import 'package:lumad_lingua/models/achievement_model.dart';
import 'package:lumad_lingua/models/route_args.dart';

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

  group('RouteArgs Strongly-Typed Navigation Tests', () {
    test('ClassroomDashboardArgs instantiates and parses map correctly', () {
      const args = ClassroomDashboardArgs(classId: 'c123', classroomData: {'name': 'Grade 5 Mansaka'});
      expect(args.classId, 'c123');
      expect(args.classroomData['name'], 'Grade 5 Mansaka');

      final fromMap = ClassroomDashboardArgs.fromMap({'classId': 'c456', 'classroomData': {'name': 'Culture Class'}});
      expect(fromMap.classId, 'c456');
      expect(fromMap.classroomData['name'], 'Culture Class');

      final fromNull = ClassroomDashboardArgs.fromMap(null);
      expect(fromNull.classId, '');
      expect(fromNull.classroomData, {});
    });

    test('DuelBattleArgs instantiates and parses map correctly', () {
      const args = DuelBattleArgs(sessionId: 's789');
      expect(args.sessionId, 's789');

      final fromMap = DuelBattleArgs.fromMap({'sessionId': 's101'});
      expect(fromMap.sessionId, 's101');

      final fromNull = DuelBattleArgs.fromMap(null);
      expect(fromNull.sessionId, '');
    });

    test('LessonResultArgs instantiates and parses map correctly', () {
      const args = LessonResultArgs(lessonId: 'l1', earnedXp: 50, stars: 3, score: 5, total: 5);
      expect(args.lessonId, 'l1');
      expect(args.earnedXp, 50);
      expect(args.stars, 3);

      final fromMap = LessonResultArgs.fromMap({'lessonId': 'l2', 'earnedXp': 40, 'stars': 2, 'score': 4, 'total': 5});
      expect(fromMap.lessonId, 'l2');
      expect(fromMap.earnedXp, 40);
      expect(fromMap.stars, 2);

      final fromNull = LessonResultArgs.fromMap(null);
      expect(fromNull.earnedXp, 30);
      expect(fromNull.stars, 3);
    });
  });
}

enum QuestType {
  lesson,
  pronunciation,
  duel,
  dictionary,
}

class DailyQuestModel {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final int crystalReward;
  final int targetCount;
  final int currentCount;
  final bool isClaimed;
  final String route;
  final QuestType type;

  const DailyQuestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.crystalReward,
    required this.targetCount,
    this.currentCount = 0,
    this.isClaimed = false,
    required this.route,
    required this.type,
  });

  bool get isCompleted => currentCount >= targetCount;
  double get progress => (currentCount / targetCount).clamp(0.0, 1.0);

  DailyQuestModel copyWith({
    int? currentCount,
    bool? isClaimed,
  }) {
    return DailyQuestModel(
      id: id,
      title: title,
      description: description,
      xpReward: xpReward,
      crystalReward: crystalReward,
      targetCount: targetCount,
      currentCount: currentCount ?? this.currentCount,
      isClaimed: isClaimed ?? this.isClaimed,
      route: route,
      type: type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currentCount': currentCount,
      'isClaimed': isClaimed,
    };
  }

  factory DailyQuestModel.fromJson(DailyQuestModel base, Map<String, dynamic> json) {
    return base.copyWith(
      currentCount: json['currentCount'] as int? ?? base.currentCount,
      isClaimed: json['isClaimed'] as bool? ?? base.isClaimed,
    );
  }
}

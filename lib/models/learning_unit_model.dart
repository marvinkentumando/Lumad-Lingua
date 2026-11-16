class LearningUnitModel {
  final String id;
  final int unitNumber;
  final String title;
  final String description;
  final String category;
  final bool isUnlocked;

  const LearningUnitModel({
    required this.id,
    required this.unitNumber,
    required this.title,
    required this.description,
    required this.category,
    this.isUnlocked = true,
  });

  LearningUnitModel copyWith({
    String? id,
    int? unitNumber,
    String? title,
    String? description,
    String? category,
    bool? isUnlocked,
  }) {
    return LearningUnitModel(
      id: id ?? this.id,
      unitNumber: unitNumber ?? this.unitNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  factory LearningUnitModel.fromJson(Map<String, dynamic> json, {String? documentId}) {
    return LearningUnitModel(
      id: documentId ?? json['id'] as String? ?? '',
      unitNumber: json['unitNumber'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      isUnlocked: json['isUnlocked'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unitNumber': unitNumber,
      'title': title,
      'description': description,
      'category': category,
      'isUnlocked': isUnlocked,
    };
  }
}

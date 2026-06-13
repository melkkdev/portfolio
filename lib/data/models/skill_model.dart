class SkillGroupModel {
  final String label;
  final List<String> skills;
  final List<String> highlights;

  const SkillGroupModel({
    required this.label,
    required this.skills,
    this.highlights = const [],
  });

  factory SkillGroupModel.fromMap(Map<String, dynamic> map) {
    return SkillGroupModel(
      label: map['label'] as String,
      skills: List<String>.from(map['skills'] as List),
      highlights: List<String>.from((map['highlights'] as List?) ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'label': label,
        'skills': skills,
        'highlights': highlights,
      };
}

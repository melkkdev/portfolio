class InfoRowModel {
  final String label;
  final String value;
  final String? url;

  const InfoRowModel({required this.label, required this.value, this.url});

  factory InfoRowModel.fromMap(Map<String, dynamic> map) {
    return InfoRowModel(
      label: map['label'] as String,
      value: map['value'] as String,
      url: map['url'] as String?,
    );
  }
}

class StatModel {
  final String value;
  final String label;

  const StatModel({required this.value, required this.label});

  factory StatModel.fromMap(Map<String, dynamic> map) {
    return StatModel(
      value: map['value'] as String,
      label: map['label'] as String,
    );
  }
}

class ProjectModel {
  final String eyebrow;
  final String title;
  final String summary;
  final List<String> imageUrls;
  final List<InfoRowModel> rows;
  final List<StatModel> stats;
  final bool isDesktop;
  final int order;

  const ProjectModel({
    required this.eyebrow,
    required this.title,
    required this.summary,
    required this.imageUrls,
    required this.rows,
    this.stats = const [],
    this.isDesktop = false,
    this.order = 0,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      eyebrow: map['eyebrow'] as String,
      title: map['title'] as String,
      summary: map['summary'] as String,
      imageUrls: List<String>.from((map['imageUrls'] as List?) ?? []),
      rows: ((map['rows'] as List?) ?? [])
          .map((r) => InfoRowModel.fromMap(r as Map<String, dynamic>))
          .toList(),
      stats: ((map['stats'] as List?) ?? [])
          .map((s) => StatModel.fromMap(s as Map<String, dynamic>))
          .toList(),
      isDesktop: (map['isDesktop'] as bool?) ?? false,
      order: (map['order'] as int?) ?? 0,
    );
  }
}

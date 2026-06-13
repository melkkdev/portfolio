const _storageBucket = 'melkk-dev.firebasestorage.app';

String buildImageUrl(String filename) {
  final path = Uri.encodeComponent('images/$filename');
  return 'https://firebasestorage.googleapis.com/v0/b/$_storageBucket/o/$path?alt=media';
}

String? _extractFilename(String url) {
  // 기존 URL 포맷: .../o/images%2Ffilename.jpg?alt=media
  final match = RegExp(r'images%2F([^?&]+)').firstMatch(url);
  if (match != null) return Uri.decodeComponent(match.group(1)!);
  // 이미 파일명이면 그대로 반환
  if (!url.startsWith('http')) return url;
  return null;
}

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

  Map<String, dynamic> toMap() => {
        'label': label,
        'value': value,
        if (url != null && url!.isNotEmpty) 'url': url,
      };
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

  Map<String, dynamic> toMap() => {'value': value, 'label': label};
}

class ProjectModel {
  final String id;
  final String eyebrow;
  final String title;
  final String summary;
  final List<String> imageFilenames;
  final List<InfoRowModel> rows;
  final List<StatModel> stats;
  /// true = 가로형 이미지 (Desktop / Tablet), false = 세로형 (Phone)
  final bool isLandscape;
  final int order;

  const ProjectModel({
    required this.id,
    required this.eyebrow,
    required this.title,
    required this.summary,
    required this.imageFilenames,
    required this.rows,
    this.stats = const [],
    this.isLandscape = false,
    this.order = 0,
  });

  List<String> get imageUrls => imageFilenames.map(buildImageUrl).toList();

  ProjectModel copyWith({int? order}) => ProjectModel(
        id: id,
        eyebrow: eyebrow,
        title: title,
        summary: summary,
        imageFilenames: imageFilenames,
        rows: rows,
        stats: stats,
        isLandscape: isLandscape,
        order: order ?? this.order,
      );

  factory ProjectModel.fromMap(Map<String, dynamic> map, {required String id}) {
    List<String> filenames;
    if (map.containsKey('imageFilenames')) {
      filenames = List<String>.from(map['imageFilenames'] as List? ?? []);
    } else {
      // 기존 imageUrls 포맷에서 파일명 추출
      final urls = List<String>.from(map['imageUrls'] as List? ?? []);
      filenames = urls.map(_extractFilename).whereType<String>().toList();
    }

    return ProjectModel(
      id: id,
      eyebrow: map['eyebrow'] as String,
      title: map['title'] as String,
      summary: map['summary'] as String,
      imageFilenames: filenames,
      rows: ((map['rows'] as List?) ?? [])
          .map((r) => InfoRowModel.fromMap(r as Map<String, dynamic>))
          .toList(),
      stats: ((map['stats'] as List?) ?? [])
          .map((s) => StatModel.fromMap(s as Map<String, dynamic>))
          .toList(),
      // isLandscape 우선, 구버전 isDesktop 필드도 마이그레이션
      isLandscape: (map['isLandscape'] as bool?) ?? (map['isDesktop'] as bool?) ?? false,
      order: (map['order'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'eyebrow': eyebrow,
        'title': title,
        'summary': summary,
        'imageFilenames': imageFilenames,
        'rows': rows.map((r) => r.toMap()).toList(),
        'stats': stats.map((s) => s.toMap()).toList(),
        'isLandscape': isLandscape,
        'order': order,
      };
}

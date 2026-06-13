import 'project_model.dart' show buildImageUrl;

String? _extractFilename(String url) {
  final match = RegExp(r'images%2F([^?&]+)').firstMatch(url);
  if (match != null) return Uri.decodeComponent(match.group(1)!);
  if (!url.startsWith('http')) return url;
  return null;
}

class ProfileModel {
  final String name;
  final String appTitle;
  final String role;
  final String tagline;
  final String careerYears;
  final String githubHandle;
  final List<String> heroImageFilenames;

  const ProfileModel({
    required this.name,
    required this.appTitle,
    required this.role,
    required this.tagline,
    required this.careerYears,
    required this.githubHandle,
    required this.heroImageFilenames,
  });

  List<String> get heroImageUrls =>
      heroImageFilenames.map(buildImageUrl).toList();

  String get githubUrl => 'https://github.com/$githubHandle';
  String get githubDisplayUrl => 'github.com/$githubHandle';

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    List<String> filenames;
    if (map.containsKey('heroImageFilenames')) {
      filenames =
          List<String>.from(map['heroImageFilenames'] as List? ?? []);
    } else {
      // 구버전 heroImageUrls → 파일명 추출
      final urls =
          List<String>.from(map['heroImageUrls'] as List? ?? []);
      filenames = urls.map(_extractFilename).whereType<String>().toList();
    }

    return ProfileModel(
      name: map['name'] as String,
      appTitle: map['appTitle'] as String,
      role: map['role'] as String,
      tagline: map['tagline'] as String,
      careerYears: map['careerYears'] as String,
      githubHandle: map['githubHandle'] as String,
      heroImageFilenames: filenames,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'appTitle': appTitle,
        'role': role,
        'tagline': tagline,
        'careerYears': careerYears,
        'githubHandle': githubHandle,
        'heroImageFilenames': heroImageFilenames,
      };
}

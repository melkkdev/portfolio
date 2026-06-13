class ProfileModel {
  final String name;
  final String appTitle;
  final String role;
  final String tagline;
  final String careerYears;
  final String githubHandle;
  final List<String> heroImageUrls;

  const ProfileModel({
    required this.name,
    required this.appTitle,
    required this.role,
    required this.tagline,
    required this.careerYears,
    required this.githubHandle,
    required this.heroImageUrls,
  });

  String get githubUrl => 'https://github.com/$githubHandle';
  String get githubDisplayUrl => 'github.com/$githubHandle';

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      name: map['name'] as String,
      appTitle: map['appTitle'] as String,
      role: map['role'] as String,
      tagline: map['tagline'] as String,
      careerYears: map['careerYears'] as String,
      githubHandle: map['githubHandle'] as String,
      heroImageUrls: List<String>.from((map['heroImageUrls'] as List?) ?? []),
    );
  }
}

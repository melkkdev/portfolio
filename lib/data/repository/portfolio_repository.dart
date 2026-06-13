import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/career_model.dart';
import '../models/profile_model.dart';
import '../models/project_model.dart';
import '../models/skill_model.dart';

class PortfolioRepository {
  static final _db = FirebaseFirestore.instance;
  static final _col = _db.collection('portfolio');
  static CollectionReference get _projectItems =>
      _col.doc('projects').collection('items');

  // ── Read ───────────────────────────────────────────────

  static Future<ProfileModel> getProfile() async {
    final doc = await _col.doc('profile').get();
    return ProfileModel.fromMap(doc.data()!);
  }

  static Future<List<String>> getIntro() async {
    final doc = await _col.doc('intro').get();
    return List<String>.from(doc.data()!['paragraphs'] as List);
  }

  static Future<List<SkillGroupModel>> getSkills() async {
    final doc = await _col.doc('skills').get();
    final list = doc.data()!['groups'] as List;
    return list
        .map((e) => SkillGroupModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<CareerModel>> getCareers() async {
    final doc = await _col.doc('careers').get();
    final list = doc.data()!['items'] as List;
    return list
        .map((e) => CareerModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<ProjectModel>> getProjects() async {
    final snap = await _projectItems.orderBy('order').get();
    return snap.docs
        .map((d) => ProjectModel.fromMap(
              d.data() as Map<String, dynamic>,
              id: d.id,
            ))
        .toList();
  }

  // ── Write ──────────────────────────────────────────────

  static Future<void> updateProfile(ProfileModel profile) =>
      _col.doc('profile').set(profile.toMap());

  static Future<void> updateIntro(List<String> paragraphs) =>
      _col.doc('intro').set({'paragraphs': paragraphs});

  static Future<void> updateCareers(List<CareerModel> careers) =>
      _col.doc('careers').set({'items': careers.map((c) => c.toMap()).toList()});

  static Future<void> updateSkills(List<SkillGroupModel> groups) =>
      _col.doc('skills').set({'groups': groups.map((g) => g.toMap()).toList()});

  static Future<void> saveProject(ProjectModel project) =>
      _projectItems.doc(project.id).set(project.toMap());

  /// 여러 프로젝트를 WriteBatch로 한 번에 저장 (order 재정렬 시 사용)
  static Future<void> saveProjects(List<ProjectModel> projects) async {
    final batch = _db.batch();
    for (final project in projects) {
      batch.set(_projectItems.doc(project.id), project.toMap());
    }
    await batch.commit();
  }

  static Future<void> deleteProject(String id) =>
      _projectItems.doc(id).delete();

  static String generateProjectId() =>
      'project_${DateTime.now().millisecondsSinceEpoch}';
}

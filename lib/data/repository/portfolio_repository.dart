import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/career_model.dart';
import '../models/profile_model.dart';
import '../models/project_model.dart';
import '../models/skill_model.dart';

class PortfolioRepository {
  static final _db = FirebaseFirestore.instance;
  static final _col = _db.collection('portfolio');

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
    return list.map((e) => SkillGroupModel.fromMap(e as Map<String, dynamic>)).toList();
  }

  static Future<List<CareerModel>> getCareers() async {
    final doc = await _col.doc('careers').get();
    final list = doc.data()!['items'] as List;
    return list.map((e) => CareerModel.fromMap(e as Map<String, dynamic>)).toList();
  }

  static Future<List<ProjectModel>> getProjects() async {
    final snap = await _col.doc('projects').collection('items')
        .orderBy('order')
        .get();
    return snap.docs
        .map((d) => ProjectModel.fromMap(d.data()))
        .toList();
  }
}

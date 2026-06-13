import 'models/career_model.dart';
import 'models/profile_model.dart';
import 'models/project_model.dart';
import 'models/skill_model.dart';
import 'repository/portfolio_repository.dart';

class PortfolioState {
  final ProfileModel profile;
  final List<String> intro;
  final List<SkillGroupModel> skills;
  final List<CareerModel> careers;
  final List<ProjectModel> projects;

  const PortfolioState({
    required this.profile,
    required this.intro,
    required this.skills,
    required this.careers,
    required this.projects,
  });

  static Future<PortfolioState> load() async {
    final results = await Future.wait([
      PortfolioRepository.getProfile(),
      PortfolioRepository.getIntro(),
      PortfolioRepository.getSkills(),
      PortfolioRepository.getCareers(),
      PortfolioRepository.getProjects(),
    ]);

    return PortfolioState(
      profile: results[0] as ProfileModel,
      intro: results[1] as List<String>,
      skills: results[2] as List<SkillGroupModel>,
      careers: results[3] as List<CareerModel>,
      projects: results[4] as List<ProjectModel>,
    );
  }
}

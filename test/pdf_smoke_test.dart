import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/pdf/portfolio_pdf_builder.dart';
import 'package:portfolio/data/models/career_model.dart';
import 'package:portfolio/data/models/profile_model.dart';
import 'package:portfolio/data/models/project_model.dart';
import 'package:portfolio/data/models/skill_model.dart';
import 'package:portfolio/data/portfolio_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'PortfolioPdfBuilder는 실제 운영 규모(프로젝트당 이미지 9장)에서도 '
    '과도한 페이지 수 없이 PDF를 생성한다',
    () async {
      final profile = const ProfileModel(
        name: '이상민',
        appTitle: '이상민 Portfolio',
        role: 'Flutter Developer',
        tagline: '사용자가 다른 어떤 앱을 하나의 코드베이스로 만듭니다',
        careerYears: '경력 3년 이상',
        githubHandle: 'melkkdev',
        heroImageFilenames: [],
      );

      final intro = List.generate(5, (i) => '소개 문단 $i 내용입니다. ' * 20);

      final skills = [
        SkillGroupModel(
          label: 'Frontend',
          skills: List.generate(12, (i) => 'Skill$i'),
          highlights: const ['Skill0', 'Skill1'],
        ),
        SkillGroupModel(
          label: 'Backend',
          skills: List.generate(10, (i) => 'BSkill$i'),
        ),
      ];

      final careers = List.generate(
        3,
        (i) => CareerModel(
          company: '회사 $i',
          period: '2021 ~ 2024',
          role: '역할 설명입니다',
          bullets: List.generate(
            6,
            (j) => '담당 업무 $j에 대한 비교적 긴 설명입니다. ' * 3,
          ),
        ),
      );

      // 실제 Firestore에 저장된 프로젝트 1건과 동일한 이미지 9장 규모로 구성.
      // 이 규모에서 과거 구현은 "more than 200 pages" 예외가 발생했었다.
      final projects = List.generate(
        4,
        (i) => ProjectModel(
          id: 'p$i',
          eyebrow: 'EYEBROW $i',
          title: '프로젝트 타이틀 $i',
          summary: '프로젝트 설명입니다. ' * 10,
          imageFilenames: List.generate(9, (j) => 'copick_collector_${j + 1}.jpg'),
          rows: List.generate(
            5,
            (k) => InfoRowModel(label: '라벨$k', value: '값 설명 $k'),
          ),
          stats: List.generate(
            3,
            (k) => StatModel(value: '${k * 10}+', label: '통계 $k'),
          ),
          isLandscape: i.isEven,
        ),
      );

      final state = PortfolioState(
        profile: profile,
        intro: intro,
        skills: skills,
        careers: careers,
        projects: projects,
      );

      final bytes = await PortfolioPdfBuilder.build(state);
      expect(bytes.length, greaterThan(1000));

      final pageCount =
          RegExp(r'/Type\s*/Page[^s]').allMatches(String.fromCharCodes(bytes)).length;
      expect(pageCount, lessThan(50));
    },
  );
}

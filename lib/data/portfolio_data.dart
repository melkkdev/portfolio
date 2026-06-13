import '../core/common/app_constants.dart';
import '../core/common/image_paths.dart';

class SkillGroupData {
  final String label;
  final List<String> skills;
  final List<String> highlights;

  const SkillGroupData({
    required this.label,
    required this.skills,
    this.highlights = const [],
  });
}

class StatData {
  final String value;
  final String label;
  const StatData({required this.value, required this.label});
}

class InfoRowData {
  final String label;
  final String value;
  final String? url;
  const InfoRowData({required this.label, required this.value, this.url});
}

class ProjectData {
  final String eyebrow;
  final String title;
  final String summary;
  final List<InfoRowData> rows;
  final List<String> images;
  final List<StatData> stats;
  final String? githubUrl;

  const ProjectData({
    required this.eyebrow,
    required this.title,
    required this.summary,
    required this.rows,
    required this.images,
    this.stats = const [],
    this.githubUrl,
  });
}

class CareerData {
  final String company;
  final String period;
  final String role;
  final List<String> bullets;

  const CareerData({
    required this.company,
    required this.period,
    required this.role,
    required this.bullets,
  });
}

class PortfolioData {
  static const List<SkillGroupData> skills = [
    SkillGroupData(
      label: '크로스플랫폼',
      skills: ['Flutter', 'Dart', 'Android', 'iOS', 'Desktop'],
      highlights: ['Flutter', 'Dart'],
    ),
    SkillGroupData(
      label: '백엔드 · 데이터',
      skills: ['Firebase', 'MySQL', 'REST API'],
      highlights: ['Firebase'],
    ),
    SkillGroupData(
      label: '연동 · 하드웨어',
      skills: ['Kakao Map SDK', 'BLE / IoT', 'Wi-Fi 설정'],
      highlights: ['Kakao Map SDK'],
    ),
    SkillGroupData(
      label: '도구 · AI',
      skills: ['Git', 'Figma', 'Claude Code', 'Codex'],
    ),
  ];

  static const List<CareerData> careers = [
    CareerData(
      company: '(주)포이엔 (4EN)',
      period: '2021.06 — 2024.11',
      role: 'IT팀 · Flutter 앱 개발 · 친환경 제조 / 폐기물 재자원화',
      bullets: [
        'CO:PICK 수거 플랫폼의 앱 개발 전반 담당 — 수거 기사용 태블릿 앱과 관리자용 데스크탑 앱을 Flutter 단일 코드베이스로 개발',
        'Firebase 백엔드 단독 구축·운영 및 MySQL 쿼리 일부 담당',
        '카카오맵 SDK 연동으로 수거 경로 안내·지난/예정 경로 시각화 구현',
        'IoT 수거 센서와의 BLE 페어링·Wi-Fi 설정·버튼 동작 매핑 기능 개발',
      ],
    ),
  ];

  static final List<ProjectData> projects = [
    ProjectData(
      eyebrow: 'CO:PICK — 수거자용 앱 (업무)',
      title: 'CO:PICK · 수거자용',
      summary: '수거 기사가 태블릿으로 당일 수거 경로를 확인하고, 카카오맵 기반 내비게이션으로 카페를 순서대로 방문하며 IoT 센서와 BLE로 수거를 처리하는 앱입니다.',
      rows: [
        InfoRowData(label: '소속 · 연계', value: '㈜포이엔(Poien) — IT팀'),
        InfoRowData(label: '업무 기간', value: '2021.06.01 ~ 2024.11.30'),
        InfoRowData(label: '플랫폼', value: 'Android 태블릿'),
        InfoRowData(
          label: '주요 기능',
          value: '수거 일정 확인 · 카카오맵 경로 안내 · 지난/예정 경로 시각화 · BLE 센서 수거 처리',
        ),
        InfoRowData(
          label: '기술 스택',
          value: 'Flutter(Dart) · Provider · Firebase · 카카오맵 SDK · BLE/IoT',
        ),
      ],
      images: ImagePaths.copickCollector,
      stats: [
        StatData(value: '300여', label: '수거 운영 카페\n(성동·화성·동탄)'),
        StatData(value: '3년 6개월', label: '단독 개발·운영'),
      ],
    ),
    ProjectData(
      eyebrow: 'CO:PICK — 관리자용 앱 (업무)',
      title: 'CO:PICK · 관리자용',
      summary: '관리자가 수거센서 상태를 실시간으로 모니터링하고 수거 기사 배차·일정을 관리하는 앱입니다.',
      rows: [
        InfoRowData(label: '소속 · 연계', value: '㈜포이엔(Poien) — IT팀'),
        InfoRowData(label: '업무 기간', value: '2021.06.01 ~ 2024.11.30'),
        InfoRowData(label: '플랫폼', value: 'Android · iOS'),
        InfoRowData(
          label: '주요 기능',
          value: '수거센서 상태 관리 · 기사 배차 · 수거 현황 모니터링',
        ),
        InfoRowData(
          label: '기술 스택',
          value: 'Flutter(Dart) · Provider · Firebase(실시간 동기화) · MySQL',
        ),
      ],
      images: ImagePaths.copickAdmin,
    ),
    ProjectData(
      eyebrow: 'CO:PICK — 데스크탑 앱 (업무)',
      title: 'CO:PICK · Desktop',
      summary: '수거량 입력·수정과 팀별 현황 집계를 처리하는 관리자용 데스크탑 앱입니다. 카페별 수거 시간·수거량을 카드 UI로 관리하며 전체 팀 집계를 한눈에 확인할 수 있습니다.',
      rows: [
        InfoRowData(label: '소속 · 연계', value: '㈜포이엔(Poien) — IT팀'),
        InfoRowData(label: '업무 기간', value: '2021.06.01 ~ 2024.11.30'),
        InfoRowData(label: '플랫폼', value: 'Windows Desktop'),
        InfoRowData(
          label: '주요 기능',
          value: '카페별 수거량 입력·수정 · 팀 필터링 · 전체 현황 집계',
        ),
        InfoRowData(
          label: '기술 스택',
          value: 'Flutter(Dart) · Provider · Firebase · MySQL',
        ),
      ],
      images: ImagePaths.copickDesktop,
      stats: [
        StatData(value: 'Android·iOS·Desktop', label: '단일 코드베이스\n멀티플랫폼'),
      ],
    ),
    ProjectData(
      eyebrow: 'AgroDoctor SPM — 토양 진단 앱 (업무)',
      title: 'AgroDoctor SPM',
      summary:
          '사용자가 소형 분광기를 블루투스로 연결해 토양을 측정하면 NPK(질소·인·칼륨)와 pH를 보여주고, 적정 수준 대비 필요 성분량과 맞춤 비료를 추천하는 앱입니다. 측정 데이터 시각화와 앱 통합을 맡아 \'AgroDoctor SPM\'으로 Google Play·iOS App Store 양대 스토어에 출시했습니다.',
      rows: [
        InfoRowData(label: '소속 · 연계', value: '㈜포이엔(Poien) — IT팀 · 회사 연구팀과 협업'),
        InfoRowData(
          label: '업무 기간',
          value: '2021.06.01 ~ 2024.11.30 재직 기간 중 (CO:PICK과 병행)',
        ),
        InfoRowData(label: '개발 인원', value: 'IT팀 소속 · 회사 연구팀과 협업'),
        InfoRowData(
          label: '주요 업무',
          value: '분광기 BLE 연동 토양 진단 앱 개발 및 Google Play·iOS App Store 출시',
        ),
        InfoRowData(
          label: '기술 스택',
          value: 'Flutter 기반 모바일 앱 · BLE(분광기 하드웨어 통신) · 측정 데이터 처리·시각화',
        ),
      ],
      images: ImagePaths.soil,
    ),
    ProjectData(
      eyebrow: 'Coupley — 커플 전용 일정관리 앱 (개인 프로젝트)',
      title: 'Coupley',
      summary:
          '한 사람이 초대 코드를 만들어 공유하면 상대가 입력해 커플로 연결되고, 캘린더·기념일·디데이가 양쪽 화면에서 실시간 동기화됩니다. CO:PICK에서 쓰던 Provider 대신 Riverpod를 처음부터 학습해 적용했고, Claude를 코드 자판기가 아닌 협업 파트너로 두고 기획·설계·개발·완성 전 사이클을 단독으로 완주했습니다.',
      rows: [
        InfoRowData(label: '소속 · 연계', value: '개인 프로젝트 (포이엔 퇴사 후 단독 수행)'),
        InfoRowData(label: '업무 기간', value: '2026.03.01 ~ 2026.06.13'),
        InfoRowData(label: '개발 인원', value: '1명 (단독)'),
        InfoRowData(label: '담당 역할', value: '기획부터 설계·개발·완성까지 전 사이클 단독'),
        InfoRowData(
          label: '주요 업무',
          value: '커플 일정관리 앱 기획·설계·개발·완성 단독 수행',
        ),
        InfoRowData(
          label: '기술 스택',
          value:
              'Flutter(Dart) · Riverpod · Firebase Firestore(실시간 동기화) · Apple·카카오 소셜 로그인 · Claude AI 협업 개발',
        ),
        InfoRowData(
          label: 'GitHub',
          value: AppConstants.coupleyGithubDisplayUrl,
          url: AppConstants.coupleyGithubUrl,
        ),
      ],
      images: ImagePaths.coupley,
      githubUrl: AppConstants.coupleyGithubUrl,
    ),
  ];
}

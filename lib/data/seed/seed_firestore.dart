import 'package:cloud_firestore/cloud_firestore.dart';

// Storage 버킷 및 이미지 URL 생성 헬퍼
const _bucket = 'melkk-dev.firebasestorage.app';

String _img(String filename) {
  final path = Uri.encodeComponent('images/$filename');
  return 'https://firebasestorage.googleapis.com/v0/b/$_bucket/o/$path?alt=media';
}

/// Firestore 초기 데이터 시드 (최초 1회 실행)
/// main.dart에서 호출 후 제거할 것
Future<void> seedFirestore() async {
  final db = FirebaseFirestore.instance;
  final col = db.collection('portfolio');

  await Future.wait([
    _seedProfile(col),
    _seedIntro(col),
    _seedSkills(col),
    _seedCareers(col),
    _seedProjects(col),
  ]);
}

Future<void> _seedProfile(CollectionReference col) => col.doc('profile').set({
  'name': '이상민',
  'appTitle': '이상민 · Flutter Developer',
  'role': 'Flutter · Mobile App Developer',
  'tagline': '사용자가 다른 여러 앱을\n하나의 코드베이스로 만듭니다',
  'careerYears': '● 경력 약 3년 6개월',
  'githubHandle': 'melkkdev',
  'heroImageUrls': [
    _img('copick_collector_1.jpg'),
    _img('copick_collector_2.jpg'),
    _img('copick_collector_3.jpg'),
  ],
});

Future<void> _seedIntro(CollectionReference col) => col.doc('intro').set({
  'paragraphs': [
    '낯선 Flutter를 독학으로 익혀 실제 제품에 곧바로 적용했고, 3년 6개월간 한 회사에서 모바일 앱을 만들며 화면을 그리는 일에서 서비스를 현장에서 돌아가게 만드는 일까지 폭을 넓혔습니다.',
    'CO:PICK에서는 수거 기사용 태블릿 앱과 관리자용 데스크탑 앱을 Flutter 단일 코드베이스로 함께 개발하고, Firebase 백엔드를 혼자 설계·운영했으며, IoT 센서 BLE 연동부터 60대 이상 고령 사용자 UX, 현장 운영까지 서비스 전 구간을 맡았습니다.',
    'AgroDoctor SPM은 Google Play와 iOS App Store 양대 스토어에 출시했고, 퇴사 후에는 개인 앱 Coupley를 기획부터 완성까지 혼자 끝냈습니다. 막히는 지점은 Claude를 협업 파트너로 붙여, 받은 코드를 제 구조에 맞게 다시 짜 넣는 방식으로 풀었습니다. Claude Code와 Codex 같은 에이전틱 코딩 도구도 사용해 봤습니다.',
  ],
});

Future<void> _seedSkills(CollectionReference col) => col.doc('skills').set({
  'groups': [
    {
      'label': '크로스플랫폼',
      'skills': ['Flutter', 'Dart', 'Android', 'iOS', 'Desktop'],
      'highlights': ['Flutter', 'Dart'],
    },
    {
      'label': '백엔드 · 데이터',
      'skills': ['Firebase', 'MySQL', 'REST API'],
      'highlights': ['Firebase'],
    },
    {
      'label': '연동 · 하드웨어',
      'skills': ['Kakao Map SDK', 'BLE / IoT', 'Wi-Fi 설정'],
      'highlights': ['Kakao Map SDK'],
    },
    {
      'label': '도구 · AI',
      'skills': ['Git', 'Figma', 'Claude Code', 'Codex'],
      'highlights': [],
    },
  ],
});

Future<void> _seedCareers(CollectionReference col) => col.doc('careers').set({
  'items': [
    {
      'company': '(주)포이엔 (4EN)',
      'period': '2021.06 — 2024.11',
      'role': 'IT팀 · Flutter 앱 개발 · 친환경 제조 / 폐기물 재자원화',
      'bullets': [
        'CO:PICK 수거 플랫폼의 앱 개발 전반 담당 — 수거 기사용 태블릿 앱과 관리자용 데스크탑 앱을 Flutter 단일 코드베이스로 개발',
        'Firebase 백엔드 단독 구축·운영 및 MySQL 쿼리 일부 담당',
        '카카오맵 SDK 연동으로 수거 경로 안내·지난/예정 경로 시각화 구현',
        'IoT 수거 센서와의 BLE 페어링·Wi-Fi 설정·버튼 동작 매핑 기능 개발',
      ],
    },
  ],
});

Future<void> _seedProjects(CollectionReference col) async {
  final items = col.doc('projects').collection('items');

  final projects = [
    {
      'order': 0,
      'eyebrow': 'CO:PICK — 수거자용 앱 (업무)',
      'title': 'CO:PICK · 수거자용',
      'summary':
          '수거 기사가 태블릿으로 당일 수거 경로를 확인하고, 카카오맵 기반 내비게이션으로 카페를 순서대로 방문하며 IoT 센서와 BLE로 수거를 처리하는 앱입니다.',
      'isDesktop': false,
      'imageUrls': List.generate(
        9,
        (i) => _img('copick_collector_${i + 1}.jpg'),
      ),
      'rows': [
        {'label': '소속 · 연계', 'value': '㈜포이엔(fouren) — IT팀'},
        {'label': '업무 기간', 'value': '2021.06.01 ~ 2024.11.30'},
        {'label': '플랫폼', 'value': 'Android 태블릿'},
        {
          'label': '주요 기능',
          'value': '수거 일정 확인 · 카카오맵 경로 안내 · 지난/예정 경로 시각화 · BLE 센서 수거 처리',
        },
        {
          'label': '기술 스택',
          'value': 'Flutter(Dart) · Provider · Firebase · 카카오맵 SDK · BLE/IoT',
        },
      ],
      'stats': [
        {'value': '300여', 'label': '수거 운영 카페\n(성동·화성·동탄)'},
        {'value': '3년 6개월', 'label': '단독 개발·운영'},
      ],
    },
    {
      'order': 1,
      'eyebrow': 'CO:PICK — 관리자용 앱 (업무)',
      'title': 'CO:PICK · 관리자용',
      'summary': '관리자가 수거센서 상태를 실시간으로 모니터링하고 수거 기사 배차·일정을 관리하는 앱입니다.',
      'isDesktop': false,
      'imageUrls': List.generate(3, (i) => _img('copick_admin_${i + 1}.jpg')),
      'rows': [
        {'label': '소속 · 연계', 'value': '㈜포이엔(fouren) — IT팀'},
        {'label': '업무 기간', 'value': '2021.06.01 ~ 2024.11.30'},
        {'label': '플랫폼', 'value': 'Android · iOS'},
        {'label': '주요 기능', 'value': '수거센서 상태 관리 · 기사 배차 · 수거 현황 모니터링'},
        {
          'label': '기술 스택',
          'value': 'Flutter(Dart) · Provider · Firebase(실시간 동기화) · MySQL',
        },
      ],
      'stats': [],
    },
    {
      'order': 2,
      'eyebrow': 'CO:PICK — 데스크탑 앱 (업무)',
      'title': 'CO:PICK · Desktop',
      'summary':
          '수거량 입력·수정과 팀별 현황 집계를 처리하는 관리자용 데스크탑 앱입니다. 카페별 수거 시간·수거량을 카드 UI로 관리하며 전체 팀 집계를 한눈에 확인할 수 있습니다.',
      'isDesktop': true,
      'imageUrls': List.generate(2, (i) => _img('copick_desktop_${i + 1}.jpg')),
      'rows': [
        {'label': '소속 · 연계', 'value': '㈜포이엔(fouren) — IT팀'},
        {'label': '업무 기간', 'value': '2021.06.01 ~ 2024.11.30'},
        {'label': '플랫폼', 'value': 'Windows Desktop'},
        {'label': '주요 기능', 'value': '카페별 수거량 입력·수정 · 팀 필터링 · 전체 현황 집계'},
        {
          'label': '기술 스택',
          'value': 'Flutter(Dart) · Provider · Firebase · MySQL',
        },
      ],
      'stats': [
        {'value': 'Android·iOS·Desktop', 'label': '단일 코드베이스\n멀티플랫폼'},
      ],
    },
    {
      'order': 3,
      'eyebrow': 'AgroDoctor SPM — 토양 진단 앱 (업무)',
      'title': 'AgroDoctor SPM',
      'summary':
          '사용자가 소형 분광기를 블루투스로 연결해 토양을 측정하면 NPK(질소·인·칼륨)와 pH를 보여주고, 적정 수준 대비 필요 성분량과 맞춤 비료를 추천하는 앱입니다.',
      'isDesktop': false,
      'imageUrls': List.generate(3, (i) => _img('soil_${i + 1}.jpg')),
      'rows': [
        {'label': '소속 · 연계', 'value': '㈜포이엔(fouren) — IT팀 · 회사 연구팀과 협업'},
        {
          'label': '업무 기간',
          'value': '2021.06.01 ~ 2024.11.30 재직 기간 중 (CO:PICK과 병행)',
        },
        {'label': '개발 인원', 'value': 'IT팀 소속 · 회사 연구팀과 협업'},
        {
          'label': '주요 업무',
          'value': '분광기 BLE 연동 토양 진단 앱 개발 및 Google Play·iOS App Store 출시',
        },
        {
          'label': '기술 스택',
          'value': 'Flutter 기반 모바일 앱 · BLE(분광기 하드웨어 통신) · 측정 데이터 처리·시각화',
        },
      ],
      'stats': [],
    },
    {
      'order': 4,
      'eyebrow': 'Coupley — 커플 전용 일정관리 앱 (개인 프로젝트)',
      'title': 'Coupley',
      'summary':
          '한 사람이 초대 코드를 만들어 공유하면 상대가 입력해 커플로 연결되고, 캘린더·기념일·디데이가 양쪽 화면에서 실시간 동기화됩니다.',
      'isDesktop': false,
      'imageUrls': List.generate(3, (i) => _img('coupley_${i + 1}.jpg')),
      'rows': [
        {'label': '소속 · 연계', 'value': '개인 프로젝트 (포이엔 퇴사 후 단독 수행)'},
        {'label': '업무 기간', 'value': '2026.03.01 ~ 2026.06.13'},
        {'label': '개발 인원', 'value': '1명 (단독)'},
        {'label': '담당 역할', 'value': '기획부터 설계·개발·완성까지 전 사이클 단독'},
        {'label': '주요 업무', 'value': '커플 일정관리 앱 기획·설계·개발·완성 단독 수행'},
        {
          'label': '기술 스택',
          'value':
              'Flutter(Dart) · Riverpod · Firebase Firestore(실시간 동기화) · Apple·카카오 소셜 로그인 · Claude AI 협업 개발',
        },
        {
          'label': 'GitHub',
          'value': 'github.com/melkkdev/coupley',
          'url': 'https://github.com/melkkdev/coupley',
        },
      ],
      'stats': [],
    },
  ];

  await Future.wait(
    projects.map((p) => items.doc('project_${p['order']}').set(p)),
  );
}

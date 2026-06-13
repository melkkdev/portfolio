import 'package:flutter/material.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/cards/surface_card.dart';
import '../../../core/design/shared/section_header.dart';
import '../../../core/theme/app_theme.dart';

const _paragraphs = [
  '낯선 Flutter를 독학으로 익혀 실제 제품에 곧바로 적용했고, 3년 6개월간 한 회사에서 모바일 앱을 만들며 화면을 그리는 일에서 서비스를 현장에서 돌아가게 만드는 일까지 폭을 넓혔습니다.',
  'CO:PICK에서는 수거 기사용 태블릿 앱과 관리자용 데스크탑 앱을 Flutter 단일 코드베이스로 함께 개발하고, Firebase 백엔드를 혼자 설계·운영했으며, IoT 센서 BLE 연동부터 60대 이상 고령 사용자 UX, 현장 운영까지 서비스 전 구간을 맡았습니다.',
  'AgroDoctor SPM은 Google Play와 iOS App Store 양대 스토어에 출시했고, 퇴사 후에는 개인 앱 Coupley를 기획부터 완성까지 혼자 끝냈습니다. 막히는 지점은 Claude를 협업 파트너로 붙여, 받은 코드를 제 구조에 맞게 다시 짜 넣는 방식으로 풀었습니다. Claude Code와 Codex 같은 에이전틱 코딩 도구도 사용해 봤습니다.',
];

class IntroSection extends StatelessWidget {
  const IntroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(num: '01', title: '소개'),
        const SizedBox(height: Spacing.lg),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _paragraphs
                .expand(
                  (text) => [
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.inkSoft,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                )
                .toList()
              ..removeLast(),
          ),
        ),
      ],
    );
  }
}

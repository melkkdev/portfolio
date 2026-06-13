import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/skill_model.dart';
import '../../../data/repository/portfolio_repository.dart';

// ── 팔레트 ─────────────────────────────────────────────────────────────────
const _kPalette = <String, List<String>>{
  'Mobile': [
    'Flutter', 'Dart', 'Android', 'iOS', 'Swift', 'Kotlin',
    'Jetpack Compose', 'SwiftUI', 'React Native',
  ],
  'Frontend': [
    'React', 'Vue.js', 'Next.js', 'TypeScript', 'JavaScript',
    'HTML/CSS', 'Tailwind CSS', 'Svelte',
  ],
  'Backend': [
    'Node.js', 'Python', 'Java', 'Spring Boot', 'Go',
    'FastAPI', 'Django', 'NestJS', 'GraphQL', 'REST API',
  ],
  'Database': [
    'Firebase', 'Firestore', 'SQLite', 'PostgreSQL',
    'MySQL', 'Redis', 'MongoDB', 'Supabase',
  ],
  'DevOps / Cloud': [
    'Docker', 'Kubernetes', 'AWS', 'GCP', 'Azure',
    'GitHub Actions', 'CI/CD', 'Linux',
  ],
  'Tools': [
    'Git', 'Figma', 'Xcode', 'Android Studio',
    'Jira', 'Notion', 'WebSocket',
  ],
};

// ── 편집 가능한 그룹 ──────────────────────────────────────────────────────
class _EditableGroup {
  final TextEditingController label;
  // 순서 유지 리스트: 일반 + 강조 모두 포함
  final List<String> skills;
  // 강조 여부
  final Set<String> highlights;
  // 직접 입력 필드
  final TextEditingController customCtrl;

  _EditableGroup.fromModel(SkillGroupModel m)
      : label = TextEditingController(text: m.label),
        skills = [...m.skills],
        highlights = {...m.highlights},
        customCtrl = TextEditingController();

  _EditableGroup.empty()
      : label = TextEditingController(),
        skills = [],
        highlights = {},
        customCtrl = TextEditingController();

  void dispose() {
    label.dispose();
    customCtrl.dispose();
  }

  SkillGroupModel toModel() => SkillGroupModel(
        label: label.text.trim(),
        skills: skills,
        highlights: highlights.toList(),
      );
}

// ── 스킬 상태 ────────────────────────────────────────────────────────────
enum _SkillState { none, normal, highlight }

// ── Dialog ───────────────────────────────────────────────────────────────
class EditSkillsDialog extends StatefulWidget {
  final List<SkillGroupModel> groups;
  final Future<void> Function() onSaved;

  const EditSkillsDialog({
    super.key,
    required this.groups,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required List<SkillGroupModel> groups,
    required Future<void> Function() onSaved,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditSkillsDialog(groups: groups, onSaved: onSaved),
    );
  }

  @override
  State<EditSkillsDialog> createState() => _EditSkillsDialogState();
}

class _EditSkillsDialogState extends State<EditSkillsDialog> {
  late List<_EditableGroup> _groups;
  int _selectedIndex = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _groups = widget.groups.map(_EditableGroup.fromModel).toList();
    if (_groups.isEmpty) _groups.add(_EditableGroup.empty());
  }

  @override
  void dispose() {
    for (final g in _groups) {
      g.dispose();
    }
    super.dispose();
  }

  _SkillState _stateOf(_EditableGroup grp, String skill) {
    if (!grp.skills.contains(skill)) return _SkillState.none;
    if (grp.highlights.contains(skill)) return _SkillState.highlight;
    return _SkillState.normal;
  }

  void _toggle(_EditableGroup grp, String skill) {
    setState(() {
      final state = _stateOf(grp, skill);
      switch (state) {
        case _SkillState.none:
          grp.skills.add(skill);
        case _SkillState.normal:
          grp.highlights.add(skill);
        case _SkillState.highlight:
          grp.skills.remove(skill);
          grp.highlights.remove(skill);
      }
    });
  }

  void _addCustomSkill(_EditableGroup grp) {
    final text = grp.customCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      if (!grp.skills.contains(text)) grp.skills.add(text);
      grp.customCtrl.clear();
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final groups = _groups
          .map((g) => g.toModel())
          .where((g) => g.label.isNotEmpty)
          .toList();
      await PortfolioRepository.updateSkills(groups);
      await widget.onSaved();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('저장 실패: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final grp = _groups[_selectedIndex];

    return AlertDialog(
      backgroundColor: AppColors.surface,
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      title: const Text(
        '기술 스택 수정',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 660,
        height: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 그룹 탭 ────────────────────────────────────────────────
            _GroupTabBar(
              groups: _groups,
              selectedIndex: _selectedIndex,
              onSelect: (i) => setState(() => _selectedIndex = i),
              onAdd: () => setState(() {
                _groups.add(_EditableGroup.empty());
                _selectedIndex = _groups.length - 1;
              }),
              onDelete: (i) => setState(() {
                _groups[i].dispose();
                _groups.removeAt(i);
                _selectedIndex = (_selectedIndex >= _groups.length
                        ? _groups.length - 1
                        : _selectedIndex)
                    .clamp(0, _groups.length - 1);
              }),
            ),
            const SizedBox(height: 12),
            // ── 그룹 라벨 ──────────────────────────────────────────────
            TextField(
              controller: grp.label,
              decoration: const InputDecoration(
                labelText: '그룹 이름 (예: Languages)',
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            // ── 선택된 기술 미리보기 ─────────────────────────────────────
            if (grp.skills.isNotEmpty) ...[
              const _SectionLabel('선택된 기술'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: grp.skills.map((s) {
                  final isH = grp.highlights.contains(s);
                  return _SkillToggleChip(
                    label: s,
                    state: isH ? _SkillState.highlight : _SkillState.normal,
                    onTap: () => _toggle(grp, s),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
            // ── 팔레트 ────────────────────────────────────────────────
            const _SectionLabel('팔레트  (탭: 없음 → 일반 → 강조 → 없음)'),
            const SizedBox(height: 6),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._kPalette.entries.map((cat) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.key,
                              style: AppTheme.mono(
                                  fontSize: 10, color: AppColors.muted),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: cat.value
                                  .map((s) => _SkillToggleChip(
                                        label: s,
                                        state: _stateOf(grp, s),
                                        onTap: () => _toggle(grp, s),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 12),
                          ],
                        )),
                    // 직접 입력
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: grp.customCtrl,
                            decoration: const InputDecoration(
                              hintText: '직접 입력 (목록에 없는 기술)',
                              isDense: true,
                            ),
                            onSubmitted: (_) => _addCustomSkill(grp),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () => _addCustomSkill(grp),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          child: const Text('추가'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            // 범례
            const _LegendDot(color: AppColors.lineSoft, label: '없음'),
            const SizedBox(width: 10),
            const _LegendDot(color: Color(0xFFD6E4DA), label: '일반'),
            const SizedBox(width: 10),
            const _LegendDot(color: AppColors.greenLight, label: '강조'),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('저장'),
            ),
          ],
        ),
      ],
    );
  }
}

// ── 그룹 탭 바 ─────────────────────────────────────────────────────────────
class _GroupTabBar extends StatelessWidget {
  final List<_EditableGroup> groups;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;
  final ValueChanged<int> onDelete;

  const _GroupTabBar({
    required this.groups,
    required this.selectedIndex,
    required this.onSelect,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...groups.asMap().entries.map((e) {
            final isSelected = e.key == selectedIndex;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Material(
                color: isSelected ? AppColors.green : AppColors.lineSoft,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => onSelect(e.key),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: e.value.label,
                          builder: (_, __, ___) => Text(
                            e.value.label.text.isEmpty
                                ? '그룹 ${e.key + 1}'
                                : e.value.label.text,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.inkSoft,
                            ),
                          ),
                        ),
                        if (groups.length > 1) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => onDelete(e.key),
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: isSelected
                                  ? Colors.white70
                                  : AppColors.muted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            tooltip: '그룹 추가',
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ── 스킬 토글 칩 ─────────────────────────────────────────────────────────
class _SkillToggleChip extends StatelessWidget {
  final String label;
  final _SkillState state;
  final VoidCallback onTap;

  const _SkillToggleChip({
    required this.label,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (bgColor, borderColor, textColor, weight) = switch (state) {
      _SkillState.none => (
          AppColors.lineSoft,
          AppColors.line,
          AppColors.muted,
          FontWeight.w500,
        ),
      _SkillState.normal => (
          const Color(0xFFD6E4DA),
          AppColors.green.withValues(alpha: 0.2),
          AppColors.greenDeep,
          FontWeight.w600,
        ),
      _SkillState.highlight => (
          AppColors.greenLight,
          AppColors.green.withValues(alpha: 0.4),
          AppColors.greenDeep,
          FontWeight.w700,
        ),
    };

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state == _SkillState.highlight) ...[
              const Icon(Icons.star_rounded,
                  size: 12, color: AppColors.greenDeep),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: weight,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 작은 헬퍼 위젯들 ────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.muted,
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: AppColors.line),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.muted)),
      ],
    );
  }
}

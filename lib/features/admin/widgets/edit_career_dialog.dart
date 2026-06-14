import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/design/shared/markup_text_field.dart';
import '../../../data/models/career_model.dart';
import '../../../data/repository/portfolio_repository.dart';

class EditCareerDialog extends StatefulWidget {
  final List<CareerModel> careers;
  final Future<void> Function() onSaved;

  const EditCareerDialog({
    super.key,
    required this.careers,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required List<CareerModel> careers,
    required Future<void> Function() onSaved,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditCareerDialog(careers: careers, onSaved: onSaved),
    );
  }

  @override
  State<EditCareerDialog> createState() => _EditCareerDialogState();
}

class _EditableCareer {
  final TextEditingController company;
  final TextEditingController period;
  final TextEditingController role;
  final List<TextEditingController> bullets;

  _EditableCareer.fromModel(CareerModel m)
      : company = TextEditingController(text: m.company),
        period = TextEditingController(text: m.period),
        role = TextEditingController(text: m.role),
        bullets = m.bullets.map((b) => TextEditingController(text: b)).toList();

  _EditableCareer.empty()
      : company = TextEditingController(),
        period = TextEditingController(),
        role = TextEditingController(),
        bullets = [TextEditingController()];

  void dispose() {
    company.dispose();
    period.dispose();
    role.dispose();
    for (final c in bullets) {
      c.dispose();
    }
  }

  CareerModel toModel() => CareerModel(
        company: company.text.trim(),
        period: period.text.trim(),
        role: role.text.trim(),
        bullets: bullets
            .map((c) => c.text.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
      );
}

class _EditCareerDialogState extends State<EditCareerDialog> {
  late List<_EditableCareer> _items;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _items = widget.careers.map(_EditableCareer.fromModel).toList();
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final careers = _items
          .map((i) => i.toModel())
          .where((c) => c.company.isNotEmpty)
          .toList();
      await PortfolioRepository.updateCareers(careers);
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
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('경력 수정', style: TextStyle(fontWeight: FontWeight.w700)),
      content: SizedBox(
        width: 580,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._items.asMap().entries.map((e) => _CareerEditor(
                    key: ValueKey(e.key),
                    career: e.value,
                    index: e.key,
                    onDelete: () => setState(() {
                      _items[e.key].dispose();
                      _items.removeAt(e.key);
                    }),
                    onUpdate: () => setState(() {}),
                  )),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () =>
                    setState(() => _items.add(_EditableCareer.empty())),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('경력 추가'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
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
    );
  }
}

class _CareerEditor extends StatelessWidget {
  final _EditableCareer career;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const _CareerEditor({
    super.key,
    required this.career,
    required this.index,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lineSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '경력 ${index + 1}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.inkSoft),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red, size: 18),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 회사 + 기간 한 줄
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: career.company,
                  decoration: const InputDecoration(
                      labelText: '회사명', isDense: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: career.period,
                  decoration: const InputDecoration(
                      labelText: '기간 (예: 2022.03 – 현재)', isDense: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MarkupTextField(
            controller: career.role,
            labelText: '직책 / 역할',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          const Text(
            '업무 내용',
            style: TextStyle(
                fontSize: 12,
                color: AppColors.muted,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          // bullets
          ...career.bullets.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8, top: 2),
                      child: CircleAvatar(
                          radius: 3, backgroundColor: AppColors.green),
                    ),
                    Expanded(
                      child: MarkupTextField(
                        controller: e.value,
                        labelText: '업무 내용 ${e.key + 1}',
                        maxLines: 3,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline,
                          color: Colors.red, size: 18),
                      onPressed: () {
                        e.value.dispose();
                        career.bullets.removeAt(e.key);
                        onUpdate();
                      },
                      padding: const EdgeInsets.only(left: 4),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              )),
          TextButton.icon(
            onPressed: () {
              career.bullets.add(TextEditingController());
              onUpdate();
            },
            icon: const Icon(Icons.add_rounded, size: 14),
            label: const Text('항목 추가', style: TextStyle(fontSize: 13)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
            ),
          ),
        ],
      ),
    );
  }
}

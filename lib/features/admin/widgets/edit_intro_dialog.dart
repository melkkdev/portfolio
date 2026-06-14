import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/design/shared/markup_text_field.dart';
import '../../../data/repository/portfolio_repository.dart';

class EditIntroDialog extends StatefulWidget {
  final List<String> paragraphs;
  final Future<void> Function() onSaved;

  const EditIntroDialog({
    super.key,
    required this.paragraphs,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required List<String> paragraphs,
    required Future<void> Function() onSaved,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditIntroDialog(paragraphs: paragraphs, onSaved: onSaved),
    );
  }

  @override
  State<EditIntroDialog> createState() => _EditIntroDialogState();
}

class _EditIntroDialogState extends State<EditIntroDialog> {
  late List<TextEditingController> _ctrls;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrls = widget.paragraphs
        .map((p) => TextEditingController(text: p))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final paragraphs =
          _ctrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
      await PortfolioRepository.updateIntro(paragraphs);
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
      title: const Text('소개 수정', style: TextStyle(fontWeight: FontWeight.w700)),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._ctrls.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MarkupTextField(
                              controller: e.value,
                              labelText: '단락 ${e.key + 1}',
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.red),
                            onPressed: () =>
                                setState(() => _ctrls.removeAt(e.key)),
                          ),
                        ],
                      ),
                    ),
                  ),
              TextButton.icon(
                onPressed: () =>
                    setState(() => _ctrls.add(TextEditingController())),
                icon: const Icon(Icons.add),
                label: const Text('단락 추가'),
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

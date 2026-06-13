import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/repository/portfolio_repository.dart';

class EditProfileDialog extends StatefulWidget {
  final ProfileModel profile;
  final Future<void> Function() onSaved;

  const EditProfileDialog({
    super.key,
    required this.profile,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required ProfileModel profile,
    required Future<void> Function() onSaved,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          EditProfileDialog(profile: profile, onSaved: onSaved),
    );
  }

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late final TextEditingController _name;
  late final TextEditingController _appTitle;
  late final TextEditingController _role;
  late final TextEditingController _tagline;
  late final TextEditingController _careerYears;
  late final TextEditingController _githubHandle;
  late List<TextEditingController> _heroUrls;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _name = TextEditingController(text: p.name);
    _appTitle = TextEditingController(text: p.appTitle);
    _role = TextEditingController(text: p.role);
    _tagline = TextEditingController(text: p.tagline);
    _careerYears = TextEditingController(text: p.careerYears);
    _githubHandle = TextEditingController(text: p.githubHandle);
    _heroUrls =
        p.heroImageUrls.map((u) => TextEditingController(text: u)).toList();
  }

  @override
  void dispose() {
    for (final c in [
      _name, _appTitle, _role, _tagline, _careerYears, _githubHandle,
      ..._heroUrls,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final updated = ProfileModel(
        name: _name.text.trim(),
        appTitle: _appTitle.text.trim(),
        role: _role.text.trim(),
        tagline: _tagline.text.trim(),
        careerYears: _careerYears.text.trim(),
        githubHandle: _githubHandle.text.trim(),
        heroImageUrls:
            _heroUrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
      );
      await PortfolioRepository.updateProfile(updated);
      await widget.onSaved();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('프로필 수정', style: TextStyle(fontWeight: FontWeight.w700)),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _field('이름', _name),
              _field('앱 타이틀', _appTitle),
              _field('역할', _role),
              _field('태그라인', _tagline, maxLines: 3),
              _field('경력', _careerYears),
              _field('GitHub 핸들 (@ 제외)', _githubHandle),
              const SizedBox(height: 16),
              const Text(
                '히어로 이미지 URL',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ..._heroUrls.asMap().entries.map(
                    (e) => Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: e.value,
                            decoration: InputDecoration(
                              labelText: 'URL ${e.key + 1}',
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.red),
                          onPressed: () => setState(
                              () => _heroUrls.removeAt(e.key)),
                        ),
                      ],
                    ),
                  ),
              TextButton.icon(
                onPressed: () =>
                    setState(() => _heroUrls.add(TextEditingController())),
                icon: const Icon(Icons.add),
                label: const Text('URL 추가'),
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

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, isDense: true),
      ),
    );
  }
}

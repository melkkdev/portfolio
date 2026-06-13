import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/models/project_model.dart' show buildImageUrl;
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
      builder: (_) => EditProfileDialog(profile: profile, onSaved: onSaved),
    );
  }

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

// ── 이미지 엔트리 (기존 파일명 or 새 파일) ──────────────────────────────
class _ImgEntry {
  final Uint8List? bytes;
  final TextEditingController filenameCtrl;

  _ImgEntry._({required this.bytes, required String filename})
      : filenameCtrl = TextEditingController(text: filename);

  factory _ImgEntry.existing(String filename) =>
      _ImgEntry._(bytes: null, filename: filename);

  factory _ImgEntry.newFile(PlatformFile file, {required String autoName}) =>
      _ImgEntry._(bytes: file.bytes, filename: autoName);

  bool get isNew => bytes != null;

  void dispose() => filenameCtrl.dispose();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late final TextEditingController _name;
  late final TextEditingController _appTitle;
  late final TextEditingController _role;
  late final TextEditingController _tagline;
  late final TextEditingController _careerYears;
  late final TextEditingController _githubHandle;
  late List<_ImgEntry> _images;

  bool _saving = false;
  String? _uploadStatus;

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
    _images = p.heroImageFilenames.map(_ImgEntry.existing).toList();
  }

  @override
  void dispose() {
    for (final c in [
      _name, _appTitle, _role, _tagline, _careerYears, _githubHandle,
    ]) {
      c.dispose();
    }
    for (final img in _images) {
      img.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result == null || !mounted) return;
    setState(() {
      final startIdx = _images.length;
      for (int i = 0; i < result.files.length; i++) {
        final file = result.files[i];
        final ext = file.extension ?? 'jpg';
        final autoName = 'profile_${startIdx + i + 1}.$ext';
        _images.add(_ImgEntry.newFile(file, autoName: autoName));
      }
    });
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _uploadStatus = null;
    });
    try {
      final newImages = _images.where((e) => e.isNew).toList();
      for (int i = 0; i < newImages.length; i++) {
        final entry = newImages[i];
        final filename = entry.filenameCtrl.text.trim();
        setState(() =>
            _uploadStatus = '업로드 중 ${i + 1}/${newImages.length}: $filename');
        final ext = filename.split('.').last.toLowerCase();
        final contentType = switch (ext) {
          'jpg' || 'jpeg' => 'image/jpeg',
          'png' => 'image/png',
          'gif' => 'image/gif',
          'webp' => 'image/webp',
          _ => 'image/jpeg',
        };
        await FirebaseStorage.instance
            .ref('images/$filename')
            .putData(entry.bytes!, SettableMetadata(contentType: contentType));
      }

      setState(() => _uploadStatus = 'Firestore 저장 중...');

      final updated = ProfileModel(
        name: _name.text.trim(),
        appTitle: _appTitle.text.trim(),
        role: _role.text.trim(),
        tagline: _tagline.text.trim(),
        careerYears: _careerYears.text.trim(),
        githubHandle: _githubHandle.text.trim(),
        heroImageFilenames: _images
            .map((e) => e.filenameCtrl.text.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
      );
      await PortfolioRepository.updateProfile(updated);
      await widget.onSaved();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _saving = false;
        _uploadStatus = null;
      });
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
      title:
          const Text('프로필 수정', style: TextStyle(fontWeight: FontWeight.w700)),
      content: SizedBox(
        width: 520,
        height: 580,
        child: _saving
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      _uploadStatus ?? '저장 중...',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
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
                    _sectionHeader('히어로 이미지'),
                    const Text(
                      '3장 권장 (왼쪽·가운데·오른쪽 폰 목업으로 표시)',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                    const SizedBox(height: 10),
                    // 이미지 썸네일 목록
                    ..._images.asMap().entries.map((e) {
                      final idx = e.key;
                      final img = e.value;
                      return _ImageRow(
                        index: idx,
                        entry: img,
                        onDelete: () => setState(() {
                          img.dispose();
                          _images.removeAt(idx);
                        }),
                        onFilenameChanged: () => setState(() {}),
                      );
                    }),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _pickFiles,
                      icon: const Icon(Icons.add_photo_alternate_rounded,
                          size: 16),
                      label: const Text('이미지 추가'),
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('저장'),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, isDense: true),
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.green,
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(child: Divider(color: AppColors.line)),
          ],
        ),
      );
}

// ── 이미지 행 위젯 ───────────────────────────────────────────────────────
class _ImageRow extends StatelessWidget {
  final int index;
  final _ImgEntry entry;
  final VoidCallback onDelete;
  final VoidCallback onFilenameChanged;

  const _ImageRow({
    required this.index,
    required this.entry,
    required this.onDelete,
    required this.onFilenameChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 썸네일
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 48,
              height: 48,
              child: entry.isNew
                  ? Image.memory(entry.bytes!, fit: BoxFit.cover)
                  : Image.network(
                      buildImageUrl(entry.filenameCtrl.text.trim()),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.lineSoft,
                        child: const Icon(Icons.image_outlined,
                            color: AppColors.muted, size: 20),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          // 파일명 필드
          Expanded(
            child: TextField(
              controller: entry.filenameCtrl,
              decoration: InputDecoration(
                labelText: '파일명 ${index + 1}',
                isDense: true,
                prefixText: entry.isNew ? '🆕 ' : '',
              ),
              onChanged: (_) => onFilenameChanged(),
            ),
          ),
          // 삭제 버튼
          IconButton(
            icon: const Icon(Icons.remove_circle_outline,
                color: Colors.red, size: 18),
            onPressed: onDelete,
            padding: const EdgeInsets.only(left: 4),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

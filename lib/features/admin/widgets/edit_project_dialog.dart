import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/project_model.dart';
import '../../../data/repository/portfolio_repository.dart';

// 기본 제공 레이블 (새 프로젝트 생성 시 미리 채워짐)
const _defaultLabels = [
  '소속 · 연계',
  '업무 기간',
  '플랫폼',
  '주요 기능',
  '기술 스택',
];

class EditProjectDialog extends StatefulWidget {
  final ProjectModel? project;
  final List<ProjectModel> allProjects;
  final Future<void> Function() onSaved;

  const EditProjectDialog({
    super.key,
    this.project,
    required this.allProjects,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    ProjectModel? project,
    required List<ProjectModel> allProjects,
    required Future<void> Function() onSaved,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditProjectDialog(
        project: project,
        allProjects: allProjects,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<EditProjectDialog> createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends State<EditProjectDialog> {
  late final TextEditingController _eyebrow;
  late final TextEditingController _title;
  late final TextEditingController _summary;
  late bool _isDesktop;

  late List<_ImageEntry> _images;
  late List<_RowEntry> _rows;
  late List<_StatEntry> _stats;

  bool _saving = false;
  String? _uploadStatus;

  int get _projectOrder =>
      widget.project?.order ?? widget.allProjects.length;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _eyebrow = TextEditingController(text: p?.eyebrow ?? '');
    _title = TextEditingController(text: p?.title ?? '');
    _summary = TextEditingController(text: p?.summary ?? '');
    _isDesktop = p?.isDesktop ?? false;

    // 이미지: 기존 파일명 목록으로 초기화
    _images = (p?.imageFilenames ?? [])
        .map((f) => _ImageEntry.existing(f))
        .toList();

    // 행: 기존 행이 있으면 그대로, 없으면 기본 레이블로 초기화
    if (p?.rows.isNotEmpty == true) {
      _rows = p!.rows
          .map((r) => _RowEntry(r.label, r.value, r.url ?? ''))
          .toList();
    } else {
      _rows = _defaultLabels.map((l) => _RowEntry(l, '', '')).toList();
    }

    _stats = (p?.stats ?? []).map((s) => _StatEntry(s.value, s.label)).toList();
  }

  @override
  void dispose() {
    _eyebrow.dispose();
    _title.dispose();
    _summary.dispose();
    for (final img in _images) {
      img.dispose();
    }
    for (final r in _rows) {
      r.dispose();
    }
    for (final s in _stats) {
      s.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result != null) {
      setState(() {
        final startIdx = _images.length;
        for (int i = 0; i < result.files.length; i++) {
          final file = result.files[i];
          final ext = file.extension ?? 'jpg';
          // 파일명 자동 생성: project_{순서}_{이미지번호}.ext
          final autoName = 'project_${_projectOrder}_${startIdx + i + 1}.$ext';
          _images.add(_ImageEntry.newFile(file, autoName: autoName));
        }
      });
    }
  }

  Future<void> _save() async {
    final emptyFilename = _images.any((e) => e.filenameCtrl.text.trim().isEmpty);
    if (emptyFilename) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지 파일명을 확인해주세요.')),
      );
      return;
    }

    setState(() {
      _saving = true;
      _uploadStatus = null;
    });

    try {
      // 신규 파일 업로드
      final newImages = _images.where((e) => e.isNew).toList();
      for (int i = 0; i < newImages.length; i++) {
        final entry = newImages[i];
        final filename = entry.filenameCtrl.text.trim();
        setState(
            () => _uploadStatus = '업로드 중 ${i + 1}/${newImages.length}: $filename');
        await FirebaseStorage.instance
            .ref('images/$filename')
            .putData(entry.bytes!, _metadata(filename));
      }

      setState(() => _uploadStatus = 'Firestore 저장 중...');

      final isNew = widget.project == null;
      final id = isNew
          ? PortfolioRepository.generateProjectId()
          : widget.project!.id;

      // 기존 프로젝트: 현재 order 유지 / 새 프로젝트: 맨 끝에 추가
      // 실제 순서 변경은 관리자 모드 종료 시 드래그 패널에서 처리
      final order = _projectOrder;

      final editedProject = ProjectModel(
        id: id,
        eyebrow: _eyebrow.text.trim(),
        title: _title.text.trim(),
        summary: _summary.text.trim(),
        isDesktop: _isDesktop,
        order: order,
        imageFilenames: _images
            .map((e) => e.filenameCtrl.text.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        rows: _rows
            .where((r) => r.value.text.trim().isNotEmpty)
            .map((r) => InfoRowModel(
                  label: r.label.text.trim(),
                  value: r.value.text.trim(),
                  url: r.url.text.trim().isEmpty ? null : r.url.text.trim(),
                ))
            .toList(),
        stats: _stats
            .where((s) => s.value.text.trim().isNotEmpty)
            .map((s) => StatModel(
                  value: s.value.text.trim(),
                  label: s.label.text.trim(),
                ))
            .toList(),
      );

      await PortfolioRepository.saveProject(editedProject);
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

  SettableMetadata _metadata(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    final contentType = switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
    return SettableMetadata(contentType: contentType);
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.project == null;
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        isNew ? '프로젝트 추가' : '프로젝트 수정',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 580,
        height: 620,
        child: _saving
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      _uploadStatus ?? '저장 중...',
                      style: const TextStyle(color: AppColors.inkSoft),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _sectionHeader('기본 정보'),
                    _field('Eyebrow (상단 레이블)', _eyebrow),
                    _field('제목', _title),
                    _field('요약', _summary, maxLines: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Desktop 앱',
                            style: TextStyle(fontSize: 13)),
                        Switch(
                          value: _isDesktop,
                          onChanged: (v) =>
                              setState(() => _isDesktop = v),
                        ),
                      ],
                    ),
                    _sectionHeader('이미지'),
                    Text(
                      '파일명 자동 생성: project_${_projectOrder}_번호.확장자  (수정 가능)',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.muted),
                    ),
                    const SizedBox(height: 8),
                    ..._images.asMap().entries.map(
                          (e) => _imageEntryCard(e.key, e.value),
                        ),
                    TextButton.icon(
                      onPressed: _pickFiles,
                      icon: const Icon(Icons.add_photo_alternate_rounded,
                          size: 18, color: AppColors.green),
                      label: const Text('파일 추가',
                          style: TextStyle(color: AppColors.green)),
                    ),
                    _sectionHeader('상세 정보 행'),
                    const Text(
                      '레이블을 비우면 포트폴리오에 "없음"으로 표기됩니다.',
                      style:
                          TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                    const SizedBox(height: 8),
                    ..._rows.asMap().entries.map(
                          (e) => _rowEntryCard(e.key, e.value),
                        ),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _rows.add(_RowEntry('', '', ''))),
                      icon: const Icon(Icons.add,
                          size: 18, color: AppColors.green),
                      label: const Text('행 추가',
                          style: TextStyle(color: AppColors.green)),
                    ),
                    _sectionHeader('통계'),
                    ..._stats.asMap().entries.map(
                          (e) => _statEntryCard(e.key, e.value),
                        ),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _stats.add(_StatEntry('', ''))),
                      icon: const Icon(Icons.add,
                          size: 18, color: AppColors.green),
                      label: const Text('통계 추가',
                          style: TextStyle(color: AppColors.green)),
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

  // ── 이미지 항목 카드 ───────────────────────────────────

  Widget _imageEntryCard(int idx, _ImageEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.bg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.isNew) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.memory(
                  entry.bytes!,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
            ] else ...[
              const Icon(Icons.image_rounded,
                  size: 40, color: AppColors.muted),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (entry.isNew)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '원본: ${entry.originalName}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  TextField(
                    controller: entry.filenameCtrl,
                    decoration: const InputDecoration(
                      labelText: '저장 파일명',
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: Colors.red, size: 20),
              onPressed: () => setState(() {
                entry.dispose();
                _images.removeAt(idx);
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── 행 항목 카드 ──────────────────────────────────────

  Widget _rowEntryCard(int idx, _RowEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.bg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '행 ${idx + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: Colors.red, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => setState(() {
                    entry.dispose();
                    _rows.removeAt(idx);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: entry.label,
              decoration: const InputDecoration(
                labelText: '레이블 (비우면 "없음")',
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: entry.value,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '값',
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: entry.url,
              decoration: const InputDecoration(
                labelText: 'URL (선택)',
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 통계 항목 카드 ────────────────────────────────────

  Widget _statEntryCard(int idx, _StatEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.bg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  TextField(
                    controller: entry.value,
                    decoration:
                        const InputDecoration(labelText: '값', isDense: true),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: entry.label,
                    decoration: const InputDecoration(
                        labelText: '레이블', isDense: true),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: Colors.red, size: 20),
              onPressed: () => setState(() {
                entry.dispose();
                _stats.removeAt(idx);
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── 공통 위젯 ──────────────────────────────────────────

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
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

  Widget _field(String label, TextEditingController ctrl,
          {int maxLines = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: ctrl,
          maxLines: maxLines,
          decoration: InputDecoration(labelText: label, isDense: true),
        ),
      );
}

// ── 데이터 클래스들 ─────────────────────────────────────

class _ImageEntry {
  final Uint8List? bytes;
  final String originalName;
  final TextEditingController filenameCtrl;

  _ImageEntry._({
    required this.bytes,
    required this.originalName,
    required String filename,
  }) : filenameCtrl = TextEditingController(text: filename);

  factory _ImageEntry.existing(String filename) =>
      _ImageEntry._(bytes: null, originalName: filename, filename: filename);

  factory _ImageEntry.newFile(PlatformFile file, {String? autoName}) =>
      _ImageEntry._(
        bytes: file.bytes,
        originalName: file.name,
        filename: autoName ?? file.name,
      );

  bool get isNew => bytes != null;

  void dispose() => filenameCtrl.dispose();
}

class _RowEntry {
  final TextEditingController label;
  final TextEditingController value;
  final TextEditingController url;

  _RowEntry(String l, String v, String u)
      : label = TextEditingController(text: l),
        value = TextEditingController(text: v),
        url = TextEditingController(text: u);

  void dispose() {
    label.dispose();
    value.dispose();
    url.dispose();
  }
}

class _StatEntry {
  final TextEditingController value;
  final TextEditingController label;

  _StatEntry(String v, String l)
      : value = TextEditingController(text: v),
        label = TextEditingController(text: l);

  void dispose() {
    value.dispose();
    label.dispose();
  }
}

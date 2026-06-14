import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MarkupTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final int maxLines;

  const MarkupTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.maxLines = 5,
  });

  @override
  State<MarkupTextField> createState() => _MarkupTextFieldState();
}

class _MarkupTextFieldState extends State<MarkupTextField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _wrap(String open, String close) {
    final ctrl = widget.controller;
    final sel = ctrl.selection;
    if (!sel.isValid) return;

    final text = ctrl.text;
    final selected = sel.textInside(text);
    final replaced = '$open$selected$close';
    final newText = text.replaceRange(sel.start, sel.end, replaced);

    ctrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: sel.start + replaced.length),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.lineSoft,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              _ToolBtn(
                tooltip: '굵게  **텍스트**',
                onTapDown: () => _wrap('**', '**'),
                child: const Text(
                  'B',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              _ToolBtn(
                tooltip: '굵게 + 초록색  [[텍스트]]',
                onTapDown: () => _wrap('[[', ']]'),
                child: const Text(
                  'B',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            labelText: widget.labelText,
            alignLabelWithHint: true,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
              borderSide: BorderSide(color: AppColors.line),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
              borderSide: BorderSide(color: AppColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(8)),
              borderSide: BorderSide(color: AppColors.green, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final Widget child;
  final String tooltip;
  final VoidCallback onTapDown;

  const _ToolBtn({
    required this.child,
    required this.tooltip,
    required this.onTapDown,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTapDown: (_) => onTapDown(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: child,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import 'styled_text.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String? url;
  final bool showDivider;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.url,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = value.isEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: isEmpty
                    ? const Text(
                        '없음',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.muted,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : url != null
                        ? GestureDetector(
                            onTap: () => launchUrl(Uri.parse(url!)),
                            child: StyledText(
                              text: value,
                              baseStyle: const TextStyle(
                                fontSize: 13,
                                color: AppColors.green,
                                fontWeight: FontWeight.w600,
                                height: 1.6,
                              ),
                            ),
                          )
                        : StyledText(
                            text: value,
                            baseStyle: const TextStyle(
                              fontSize: 13,
                              color: AppColors.inkSoft,
                              height: 1.6,
                            ),
                          ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(color: AppColors.line, height: 1),
      ],
    );
  }
}

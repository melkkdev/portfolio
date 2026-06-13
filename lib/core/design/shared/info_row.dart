import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String? url;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label.isEmpty ? '없음' : label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
                fontStyle:
                    label.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: url != null
                ? GestureDetector(
                    onTap: () => launchUrl(Uri.parse(url!)),
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.inkSoft,
                      height: 1.6,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

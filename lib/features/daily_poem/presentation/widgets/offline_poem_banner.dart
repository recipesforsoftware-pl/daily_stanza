import 'package:flutter/material.dart';
import 'package:daily_stanza/core/theme/app_colors.dart';

class OfflinePoemBanner extends StatelessWidget {
  const OfflinePoemBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.lightHighlight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_off_outlined, size: 18, color: AppColors.lightMuted),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "You're offline. Showing a previously downloaded poem.",
              style: TextStyle(
                fontSize: 13,
                color: AppColors.lightMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/colors.dart';

/// A small, quiet section label — uppercase and letter-spaced
class SectionEyebrow extends StatelessWidget {
  const SectionEyebrow({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.brandPrimaryLight,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

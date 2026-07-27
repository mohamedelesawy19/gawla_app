// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/spacing.dart';

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({super.key, this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXxl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: Theme.of(context).colorScheme.error,
            ),
            AppSpacing.verticalSpaceSm,
            Text(
              message ?? 'Something went wrong',
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceMd,
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

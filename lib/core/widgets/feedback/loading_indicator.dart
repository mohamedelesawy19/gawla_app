import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

enum LoadingIndicatorSize { small, medium, large }

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.size = LoadingIndicatorSize.medium,
    this.color,
    this.message,
    this.spacing = 8.0,
  });

  final LoadingIndicatorSize size;
  final Color? color;
  final String? message;
  final double spacing;

  double get _sizeValue {
    switch (size) {
      case LoadingIndicatorSize.small:
        return 16;
      case LoadingIndicatorSize.medium:
        return 24;
      case LoadingIndicatorSize.large:
        return 32;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final indicator = SizedBox(
      width: _sizeValue,
      height: _sizeValue,
      child: SpinKitFoldingCube(
        color: color ?? theme.colorScheme.tertiary,
        size: _sizeValue,
      ),
    );

    if (message == null) {
      return indicator;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        SizedBox(width: spacing),
        Flexible(
          child: Text(
            message!,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: _sizeValue * 0.8,
            ),
          ),
        ),
      ],
    );
  }
}

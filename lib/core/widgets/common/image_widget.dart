// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

// Core imports:
import '/core/design_system/colors.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({
    super.key,
    required this.src,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  final String src;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
    imageUrl: src,
    width: width,
    height: height,
    fit: BoxFit.cover,
    placeholder: (_, _) =>
        placeholder ??
        Shimmer(
          duration: const Duration(seconds: 2),
          interval: const Duration(milliseconds: 350),
          child: const SizedBox(),
        ),
    errorWidget: (_, _, _) =>
        errorWidget ??
        Container(
          width: width,
          height: height,
          color: AppColors.surfaceElevated,
          child: const Icon(Icons.image_not_supported_outlined, size: 20),
        ),
  );
}

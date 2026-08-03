// Flutter imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/colors.dart';
import '/core/design_system/typography.dart';
import '/core/extensions/media_query_extention.dart';
import '/core/widgets/common/glowing_icon.dart';

/// Enum to define the type of premium dialog
enum PremiumDialogType {
  /// Success dialog (green colors)
  success,

  /// Warning dialog (orange/amber colors)
  warning,

  /// Error/Delete dialog (red colors)
  error,

  /// Normal/default dialog (primary colors)
  normal,
}

/// A premium-styled dialog with decorative elements, glowing icon,
/// and smooth animations.
///
/// This dialog is designed for important notifications, support prompts,
/// or any situation where you need a visually appealing dialog.
///
/// Example usage:
/// ```dart
/// showPremiumDialog(
///   context: context,
///   icon: Icons.headset_mic_rounded,
///   title: 'Need Assistance?',
///   description: 'Contact our support team for help.',
///   primaryButtonText: 'Contact Support',
///   onPrimaryPressed: () => launchSupport(),
/// );
/// ```
class PremiumDialog extends StatelessWidget {
  const PremiumDialog({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.info_rounded,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.content,
    this.dialogType = PremiumDialogType.normal,
  });

  final String title;
  final String? description;
  final IconData icon;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final Widget? content;
  final PremiumDialogType dialogType;

  /// Get colors based on dialog type
  DialogTypeColors _getColorsForType() {
    switch (dialogType) {
      case PremiumDialogType.success:
        return DialogTypeColors(
          primaryColor: AppColors.statusSuccess,
          onPrimaryColor: AppColors.textInverse,
          gradientColors: [
            AppColors.statusSuccess,
            AppColors.statusSuccess.withAlpha(120),
          ],
        );
      case PremiumDialogType.warning:
        return DialogTypeColors(
          primaryColor: AppColors.statusWarning,
          onPrimaryColor: AppColors.textInverse,
          gradientColors: [
            AppColors.statusWarning,
            AppColors.statusWarning.withAlpha(120),
          ],
        );
      case PremiumDialogType.error:
        return DialogTypeColors(
          primaryColor: AppColors.statusError,
          onPrimaryColor: AppColors.textPrimary,
          gradientColors: [
            AppColors.statusError,
            AppColors.statusError.withAlpha(120),
          ],
        );
      case PremiumDialogType.normal:
        return DialogTypeColors(
          primaryColor: AppColors.brandPrimary,
          onPrimaryColor: AppColors.textPrimary,
          gradientColors: [
            AppColors.brandPrimary,
            AppColors.brandPrimary.withAlpha(120),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColors = _getColorsForType();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: context.width * 0.8,
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                children: [
                  // Decorative Background Elements
                  Positioned(
                    top: -60,
                    right: -60,
                    child: _DecorativeCircle(
                      size: 180,
                      color: AppColors.brandPrimary.withValues(alpha: 0.08),
                    ),
                  ),
                  Positioned(
                    bottom: -40,
                    left: -40,
                    child: _DecorativeCircle(
                      size: 140,
                      color: AppColors.brandPrimaryDark.withValues(alpha: 0.08),
                    ),
                  ),

                  // Main Content
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: (context.height - bottomInset) * 0.85,
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32.0,
                              vertical: 40.0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Glowing Icon
                                GlowingIcon(
                                  icon: icon,
                                  gradientColors: typeColors.gradientColors,
                                  height: 60,
                                  width: 60,
                                ),

                                const SizedBox(height: 24),

                                // Title
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.headlineSmall.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),

                                if (description != null || content != null) ...[
                                  const SizedBox(height: 12),
                                  if (content != null)
                                    content!
                                  else
                                    Text(
                                      description!,
                                      textAlign: TextAlign.center,
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                        height: 1.5,
                                      ),
                                    ),
                                ],

                                if (primaryButtonText != null) ...[
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (onPrimaryPressed != null) {
                                          onPrimaryPressed!();
                                        } else {
                                          Navigator.of(context).pop(true);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            typeColors.primaryColor,
                                        foregroundColor:
                                            typeColors.onPrimaryColor,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        primaryButtonText!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                if (secondaryButtonText != null) ...[
                                  const SizedBox(height: 20),
                                  InkWell(
                                    onTap: () {
                                      if (onSecondaryPressed != null) {
                                        onSecondaryPressed!();
                                      } else {
                                        Navigator.of(context).pop(false);
                                      }
                                    },
                                    child: Text(
                                      secondaryButtonText!,
                                      style: AppTypography.labelLarge.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//  HELPER CLASSES
// -----------------------------------------------------------------------------

/// Colors for a specific dialog type
class DialogTypeColors {
  const DialogTypeColors({
    required this.primaryColor,
    required this.onPrimaryColor,
    required this.gradientColors,
  });

  final Color primaryColor;
  final Color onPrimaryColor;
  final List<Color> gradientColors;
}

// -----------------------------------------------------------------------------
//  HELPER WIDGETS
// -----------------------------------------------------------------------------

/// Simple decorative circle for background visuals.
class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

// -----------------------------------------------------------------------------
//  HELPER FUNCTION TO SHOW THE DIALOG
// -----------------------------------------------------------------------------

/// Shows a premium dialog with smooth spring animation.
///
/// Returns a [Future] that resolves when the dialog is dismissed.
///
/// Example:
/// ```dart
/// showPremiumDialog(
///   context: context,
///   icon: Icons.headset_mic_rounded,
///   title: 'Need Assistance?',
///   description: 'Contact our support team.',
///   primaryButtonText: 'Contact Support',
///   secondaryButtonText: 'Maybe later',
/// );
/// ```
Future<T?> showPremiumDialog<T>({
  required BuildContext context,
  required String title,
  String? description,
  IconData icon = Icons.info_rounded,
  String? primaryButtonText,
  String? secondaryButtonText,
  VoidCallback? onPrimaryPressed,
  VoidCallback? onSecondaryPressed,
  Widget? content,
  PremiumDialogType dialogType = PremiumDialogType.normal,
  bool barrierDismissible = true,
  Duration transitionDuration = const Duration(milliseconds: 500),
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierLabel: 'Dismiss',
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    transitionDuration: transitionDuration,
    pageBuilder: (context, _, _) => PremiumDialog(
      title: title,
      description: description,
      icon: icon,
      primaryButtonText: primaryButtonText,
      secondaryButtonText: secondaryButtonText,
      onPrimaryPressed: onPrimaryPressed,
      onSecondaryPressed: onSecondaryPressed,
      content: content,
      dialogType: dialogType,
    ),
    transitionBuilder: (context, anim, secondaryAnim, child) {
      // Custom Spring Animation for entrance
      final curvedValue = Curves.elasticOut.transform(anim.value);
      return Transform.scale(
        scale: curvedValue,
        child: Opacity(opacity: anim.value, child: child),
      );
    },
  );
}

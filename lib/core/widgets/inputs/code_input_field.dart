// Package imports:
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

// Core imports:
import '/core/design_system/colors.dart';

class CodeInputField extends StatelessWidget {
  const CodeInputField({
    super.key,
    this.length = 6,
    this.controller,
    this.onChanged,
    this.onCompleted,
    this.autofocus = false,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType = TextInputType.number,
    this.smsAutofill = false,
    this.gap = 8,
    this.semanticLabel,
  }) : assert(length > 0, 'length must be greater than zero'),
       assert(gap >= 0, 'gap cannot be negative');

  /// Number of cells to render.
  final int length;

  /// Optional controller for reading, prefilling or clearing the value, and
  /// for triggering the built-in error state programmatically. If omitted,
  /// an internal controller is created and disposed for you.
  final PinInputController? controller;

  /// Called on every change to the entered value.
  final ValueChanged<String>? onChanged;

  /// Called once when all [length] cells are filled.
  final ValueChanged<String>? onCompleted;

  /// Whether to request focus as soon as the field is built.
  final bool autofocus;

  /// Whether the field accepts input. Cells render in a muted, disabled
  /// style when `false`.
  final bool enabled;

  /// Masks entered characters, e.g. for a numeric PIN rather than an OTP.
  final bool obscureText;

  /// Keyboard shown for entry. Defaults to a numeric keypad; use
  /// [TextInputType.text] for alphanumeric codes.
  final TextInputType keyboardType;

  /// Enables SMS one-time-code autofill on iOS and Android.
  final bool smsAutofill;

  /// Space between adjacent cells.
  final double gap;

  /// Accessibility label announced by screen readers. Defaults to the
  /// package's built-in description when omitted.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: PinInput(
        length: length,
        pinController: controller,
        onChanged: onChanged,
        onCompleted: onCompleted,
        autoFocus: autofocus,
        enabled: enabled,
        obscureText: obscureText,
        keyboardType: keyboardType,
        enableAutofill: smsAutofill,
        autofillHints: smsAutofill ? const [AutofillHints.oneTimeCode] : null,
        semanticLabel: semanticLabel,
        builder: (context, cells) => _OtpCellRow(cells: cells, gap: gap),
      ),
    );
  }
}

/// Lays cells out in a single row, each one [Expanded] so the row divides
/// the available width evenly and can never overflow horizontally.
class _OtpCellRow extends StatelessWidget {
  const _OtpCellRow({required this.cells, required this.gap});

  final List<PinCellData> cells;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < cells.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(child: _OtpCell(data: cells[i])),
        ],
      ],
    );
  }
}

/// A single Material 3 OTP cell.
///
/// Wrapped in [AspectRatio] so its height is derived from whatever width
/// [Expanded] gives it — no [LayoutBuilder] or manual measuring required.
class _OtpCell extends StatelessWidget {
  const _OtpCell({required this.data});

  final PinCellData data;

  static const _aspectRatio = 0.82;
  static const _borderRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final Color borderColor;
    final Color backgroundColor;
    final double borderWidth;
    if (data.isDisabled) {
      borderColor = AppColors.cardDisabled;
      borderWidth = 1;
    } else if (data.isError) {
      borderColor = AppColors.borderError;
      borderWidth = 2;
    } else if (data.isFocused) {
      borderColor = AppColors.borderSelected;
      borderWidth = 2;
    } else if (data.isFilled) {
      borderColor = AppColors.borderDefault;
      borderWidth = 1;
    } else {
      borderColor = AppColors.borderDefault;
      borderWidth = 1;
    }

    if (data.isDisabled) {
      backgroundColor = AppColors.cardDisabled.withValues(alpha: 0.2);
    } else if (data.isError) {
      backgroundColor = AppColors.borderError.withValues(alpha: 0.2);
    } else if (data.isFocused) {
      backgroundColor = AppColors.cardSelected;
    } else if (data.isFilled) {
      backgroundColor = AppColors.cardDefault.withValues(alpha: 0.2);
    } else {
      backgroundColor = AppColors.cardDefault;
    }

    final Color textColor;
    if (data.isDisabled) {
      textColor = AppColors.textDisabled;
    } else if (data.isError) {
      textColor = AppColors.textTertiary;
    } else {
      textColor = AppColors.textPrimary;
    }

    return AspectRatio(
      aspectRatio: _aspectRatio,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              data.character ?? '',
              style: textTheme.headlineSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

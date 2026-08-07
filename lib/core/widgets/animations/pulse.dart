import 'package:flutter/material.dart';

/// A reusable "breathing" opacity pulse driven by an external
/// [AnimationController].
///
/// Like `FadeSlideIn`, this widget never creates or owns its own
/// controller — the caller is responsible for it (usually created with
/// `..repeat(reverse: true)` for an infinite pulse, though any controller
/// works, including a shared one used to stagger other animations). This
/// keeps [Pulse] cheap, testable, and easy to sync with everything else on
/// screen.
///
/// Example:
/// ```dart
/// late final _controller = AnimationController(
///   vsync: this,
///   duration: const Duration(milliseconds: 900),
/// )..repeat(reverse: true);
///
/// Pulse(
///   controller: _controller,
///   minOpacity: 0.35,
///   child: const FlutterLogo(size: 24),
/// )
/// ```
class Pulse extends StatefulWidget {
  const Pulse({
    super.key,
    required this.controller,
    required this.child,
    this.curve = Curves.easeInOut,
    this.minOpacity = 0.0,
    this.maxOpacity = 1.0,
  });

  /// The controller driving this animation. Owned and disposed by the
  /// caller — this widget never disposes it.
  final AnimationController controller;

  /// The widget to pulse. Built once and reused on every tick.
  final Widget child;

  /// Easing curve applied to [controller]'s value before it's mapped onto
  /// the opacity range.
  final Curve curve;

  /// The lowest opacity reached during the pulse.
  final double minOpacity;

  /// The highest opacity reached during the pulse.
  final double maxOpacity;

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> {
  late CurvedAnimation _curvedAnimation;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _curvedAnimation = _createCurvedAnimation();
    _opacity = _createTween().animate(_curvedAnimation);
  }

  @override
  void didUpdateWidget(covariant Pulse oldWidget) {
    super.didUpdateWidget(oldWidget);

    final needsNewCurve =
        oldWidget.controller != widget.controller ||
        oldWidget.curve != widget.curve;

    if (needsNewCurve) {
      _curvedAnimation.dispose();
      _curvedAnimation = _createCurvedAnimation();
    }

    if (needsNewCurve ||
        oldWidget.minOpacity != widget.minOpacity ||
        oldWidget.maxOpacity != widget.maxOpacity) {
      _opacity = _createTween().animate(_curvedAnimation);
    }
  }

  CurvedAnimation _createCurvedAnimation() {
    return CurvedAnimation(parent: widget.controller, curve: widget.curve);
  }

  Tween<double> _createTween() {
    return Tween<double>(begin: widget.minOpacity, end: widget.maxOpacity);
  }

  @override
  void dispose() {
    // We created this CurvedAnimation, so we dispose it. widget.controller
    // is NOT disposed here — the caller owns it.
    _curvedAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}

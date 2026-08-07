import 'package:flutter/material.dart';

/// A reusable fade + slide-in transition driven by an external
/// [AnimationController].
///
/// Unlike widgets that own their own controller, [FadeSlideIn] expects the
/// controller to be created and driven by an ancestor (e.g. inside a
/// `TickerProviderStateMixin` State). This makes it trivial to stagger
/// several [FadeSlideIn] widgets off a single shared controller — just
/// give each one a different [curve] (typically an [Interval]).
///
/// Example — staggering three widgets off one controller:
/// ```dart
/// final controller = AnimationController(
///   vsync: this,
///   duration: const Duration(milliseconds: 700),
/// )..forward();
///
/// Column(
///   children: [
///     FadeSlideIn(
///       controller: controller,
///       curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
///       child: const Text('First'),
///     ),
///     FadeSlideIn(
///       controller: controller,
///       curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
///       child: const Text('Second'),
///     ),
///     FadeSlideIn(
///       controller: controller,
///       curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
///       offset: const Offset(-24, 0), // slide in from the left instead
///       child: const Text('Third'),
///     ),
///   ],
/// )
/// ```
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.controller,
    required this.child,
    this.curve = const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
    this.offset = const Offset(0, 20),
    this.fadeEnabled = true,
  });

  /// The controller driving this animation. Owned and disposed by the
  /// caller — this widget never disposes it.
  final AnimationController controller;

  /// The widget to reveal. Built once and reused on every animation tick
  /// (never rebuilt per frame).
  final Widget child;

  /// The curve mapped onto [controller]'s 0..1 timeline.
  ///
  /// Pass an [Interval] (which is itself a [Curve]) to control *when*
  /// within the controller's run this widget animates in — that's how you
  /// stagger multiple [FadeSlideIn]s off one shared controller. Pass a
  /// plain [Curve] (e.g. [Curves.easeOut]) if you don't need staggering.
  final Curve curve;

  /// Starting offset in logical pixels. The child slides from [offset]
  /// to [Offset.zero] as the animation progresses. Use a negative dx for
  /// slide-in-from-the-left, a positive dy for slide-up-from-below, etc.
  final Offset offset;

  /// Whether to fade in alongside the slide. Set to false if you only
  /// want the slide effect.
  final bool fadeEnabled;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> {
  late CurvedAnimation _animation;

  @override
  void initState() {
    super.initState();
    _animation = _createAnimation();
  }

  @override
  void didUpdateWidget(covariant FadeSlideIn oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only rebuild the CurvedAnimation when what it depends on actually
    // changes, instead of on every single rebuild.
    if (oldWidget.controller != widget.controller ||
        oldWidget.curve != widget.curve) {
      _animation.dispose();
      _animation = _createAnimation();
    }
  }

  CurvedAnimation _createAnimation() {
    return CurvedAnimation(parent: widget.controller, curve: widget.curve);
  }

  @override
  void dispose() {
    // We created this CurvedAnimation, so we're responsible for disposing it.
    // widget.controller itself is NOT disposed here — the parent owns it.
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final t = _animation.value.clamp(0.0, 1.0);

        Widget result = Transform.translate(
          offset: widget.offset * (1 - t),
          child: child,
        );

        if (widget.fadeEnabled) {
          result = Opacity(opacity: t, child: result);
        }

        return result;
      },
      child: widget.child,
    );
  }
}

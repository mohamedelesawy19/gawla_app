// Dart imports
import 'dart:math' as math;
import 'dart:ui' as ui;

// Package imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Core imports
import '/core/design_system/borders.dart';
import '/core/design_system/colors.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class NavBarItem {
  const NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badge;
}

// ─── Main Widget ─────────────────────────────────────────────────────────────

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.backgroundColor = AppColors.surfaceDefault,
    this.activeColor = AppColors.brandAccentCyan,
    this.inactiveColor = AppColors.iconMuted,
    this.indicatorColor = AppColors.cardSelected,
    this.height,
    this.margin = const EdgeInsets.fromLTRB(8, 0, 8, 8),
    this.showLabels = true,
    this.enableHaptics = true,
    this.enableBlur = true,
  }) : assert(items.length >= 2 && items.length <= 5);

  final List<NavBarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final Color backgroundColor;
  final Color activeColor;
  final Color inactiveColor;
  final Color indicatorColor;
  final double? height;
  final EdgeInsets margin;
  final bool showLabels;
  final bool enableHaptics;
  final bool enableBlur;

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final h = widget.height ?? (widget.showLabels ? 80.0 : 68.0);

    return Padding(
      padding: widget.margin,
      child: SizedBox(
        height: h,
        child: _Shell(
          color: widget.backgroundColor,
          enableBlur: widget.enableBlur,
          child: LayoutBuilder(
            builder: (_, box) {
              final itemW = box.maxWidth / widget.items.length;
              final pillW = math.min(58.0, itemW - 8);
              final pillH = math.min(56.0, h - 12);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Indicator
                  AnimatedPositionedDirectional(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    start: widget.selectedIndex * itemW + (itemW - pillW) / 2,
                    top: (h - pillH) / 2,
                    child: Container(
                      width: pillW,
                      height: pillH,
                      decoration: BoxDecoration(
                        color: widget.indicatorColor,
                        borderRadius: BorderRadius.circular(pillH / 2),
                      ),
                    ),
                  ),

                  // Items
                  Row(
                    children: List.generate(
                      widget.items.length,
                      (i) => _NavItem(
                        item: widget.items[i],
                        isSelected: i == widget.selectedIndex,
                        activeColor: widget.activeColor,
                        inactiveColor: widget.inactiveColor,
                        showLabel: widget.showLabels,
                        width: itemW,
                        onTap: () {
                          if (widget.enableHaptics) {
                            HapticFeedback.selectionClick();
                          }
                          widget.onItemSelected(i);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Shell (glassmorphic container) ──────────────────────────────────────────

class _Shell extends StatelessWidget {
  const _Shell({
    required this.color,
    required this.enableBlur,
    required this.child,
  });

  final Color color;
  final bool enableBlur;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const r = Radius.circular(40);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.white10, width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowStrong,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
          BoxShadow(color: AppColors.white10, blurRadius: 2),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.1),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(r),
          child: enableBlur
              ? BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: child,
                )
              : child,
        ),
      ),
    );
  }
}

// ─── Individual Nav Item ─────────────────────────────────────────────────────

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.showLabel,
    required this.width,
    required this.onTap,
  });

  final NavBarItem item;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final bool showLabel;
  final double width;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected ? widget.activeColor : widget.inactiveColor;

    return Semantics(
      label: widget.item.label,
      selected: widget.isSelected,
      button: true,
      child: GestureDetector(
        key: ValueKey(widget.item.label),
        onTap: () {
          if (!widget.isSelected) {
            widget.onTap();
          }
        },
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: widget.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon + badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: Tween(begin: 0.55, end: 1.0).animate(anim),
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: Icon(
                      widget.isSelected
                          ? widget.item.activeIcon
                          : widget.item.icon,
                      key: ValueKey(
                        '${widget.item.label}_${widget.isSelected}',
                      ),
                      color: color,
                      size: 28,
                    ),
                  ),
                  if ((widget.item.badge ?? 0) > 0)
                    Positioned(
                      top: -5,
                      right: -8,
                      child: _Badge(widget.item.badge!),
                    ),
                ],
              ),

              // Label
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: color,
                      letterSpacing: 0.35,
                    ),
                    child: widget.showLabel
                        ? Text(
                            widget.item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                crossFadeState: widget.showLabel
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 220),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Badge ───────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge(this.count);
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: const BoxDecoration(
        color: AppColors.badgeCountBackground,
        borderRadius: AppBorders.borderRadiusMd,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : '$count',
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.badgeCountText,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final BorderSide? borderSide;
  final double borderRadius;
  final bool enableHover;
  final Gradient? gradient;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.borderSide,
    this.borderRadius = 16,
    this.enableHover = true,
    this.gradient,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveBackground = widget.backgroundColor ?? AppColors.surface;
    final effectiveBorder = widget.borderSide ??
        BorderSide(
          color: _isHovered ? AppColors.primary.withAlpha(120) : AppColors.border,
          width: 1,
        );

    final cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      transform: _isHovered && widget.onTap != null
          ? Matrix4.translationValues(0.0, -3.0, 0.0)
          : Matrix4.identity(),
      decoration: BoxDecoration(
        color: widget.gradient == null ? effectiveBackground : null,
        gradient: widget.gradient,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.fromBorderSide(effectiveBorder),
        boxShadow: [
          BoxShadow(
            color: _isHovered && widget.onTap != null
                ? AppColors.primary.withAlpha(25)
                : Colors.black.withAlpha(10),
            blurRadius: _isHovered && widget.onTap != null ? 14 : 6,
            offset: Offset(0, _isHovered && widget.onTap != null ? 6 : 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          hoverColor: AppColors.primary.withAlpha(10),
          splashColor: AppColors.primary.withAlpha(20),
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );

    if (widget.enableHover && widget.onTap != null) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: cardContent,
      );
    }

    return cardContent;
  }
}

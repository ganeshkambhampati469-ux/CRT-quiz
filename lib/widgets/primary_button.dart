import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum ButtonVariant { primary, secondary, outline, danger }

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final IconData? icon;
  final double? width;
  final double height;
  final double borderRadius;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.width,
    this.height = 50,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    Color getBackgroundColor() {
      if (onPressed == null && !isLoading) {
        return AppColors.border;
      }
      switch (variant) {
        case ButtonVariant.primary:
          return AppColors.primary;
        case ButtonVariant.secondary:
          return AppColors.secondary;
        case ButtonVariant.danger:
          return AppColors.error;
        case ButtonVariant.outline:
          return Colors.transparent;
      }
    }

    Color getTextColor() {
      if (onPressed == null && !isLoading) {
        return AppColors.textMuted;
      }
      switch (variant) {
        case ButtonVariant.primary:
        case ButtonVariant.secondary:
        case ButtonVariant.danger:
          return Colors.white;
        case ButtonVariant.outline:
          return AppColors.primary;
      }
    }

    BorderSide getBorderSide() {
      if (variant == ButtonVariant.outline) {
        return BorderSide(
          color: onPressed == null ? AppColors.border : AppColors.primary,
          width: 1.5,
        );
      }
      return BorderSide.none;
    }

    final buttonChild = isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(getTextColor()),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: getTextColor()),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: AppTextStyles.button(color: getTextColor()),
              ),
            ],
          );

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: getBackgroundColor(),
          foregroundColor: getTextColor(),
          elevation: variant == ButtonVariant.outline ? 0 : 1,
          shadowColor: AppColors.primary.withAlpha(50),
          side: getBorderSide(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: buttonChild,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum VentureButtonType {
  primary,
  secondary,
  tertiary,
  premium,
}

class VentureButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final VentureButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double? height;

  const VentureButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = VentureButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final buttonChild = _buildButtonChild();

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: buttonChild,
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (type) {
      case VentureButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: AppTheme.white,
          disabledBackgroundColor: AppTheme.primaryBlue.withOpacity(0.5),
          disabledForegroundColor: AppTheme.white.withOpacity(0.5),
        );
      case VentureButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppTheme.mediumGrey,
          foregroundColor: AppTheme.black,
          disabledBackgroundColor: AppTheme.mediumGrey.withOpacity(0.5),
          disabledForegroundColor: AppTheme.black.withOpacity(0.5),
        );
      case VentureButtonType.tertiary:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppTheme.primaryBlue,
          disabledForegroundColor: AppTheme.primaryBlue.withOpacity(0.5),
          side: const BorderSide(color: AppTheme.primaryBlue),
        );
      case VentureButtonType.premium:
        return ElevatedButton.styleFrom(
          backgroundColor: AppTheme.premiumGold,
          foregroundColor: AppTheme.white,
          disabledBackgroundColor: AppTheme.premiumGold.withOpacity(0.5),
          disabledForegroundColor: AppTheme.white.withOpacity(0.5),
        );
    }
  }

  Widget _buildButtonChild() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}

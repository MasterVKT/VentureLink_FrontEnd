import 'package:flutter/material.dart';
import 'package:venturelink/constants/design_constants.dart';
import '../../core/theme/app_theme.dart';

enum VLButtonType { primary, secondary, tertiary, premium }

class VLButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final VLButtonType type;
  final IconData? icon;
  final bool isFullWidth;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final bool isSmall;

  const VLButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = VLButtonType.primary,
    this.icon,
    this.isFullWidth = false,
    this.isLoading = false,
    this.padding,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return _buildButton();
  }

  Widget _buildButton() {
    // Déterminer la couleur et le style en fonction du type
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    Color? overlayColor;
    EdgeInsetsGeometry buttonPadding = padding ??
        EdgeInsets.symmetric(
          horizontal: AppTheme.paddingMedium,
          vertical: isSmall ? 8.0 : 12.0,
        );
    BoxDecoration? decoration;

    switch (type) {
      case VLButtonType.primary:
        backgroundColor = AppTheme.primaryBlue;
        textColor = Colors.white;
        borderColor = Colors.transparent;
        overlayColor = Colors.white.withOpacity(0.1);
        decoration = BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
        break;
      case VLButtonType.secondary:
        backgroundColor = DesignConstants.mediumGrey.withOpacity(0.1);
        textColor = DesignConstants.darkGrey;
        borderColor = DesignConstants.mediumGrey.withOpacity(0.3);
        overlayColor = DesignConstants.mediumGrey.withOpacity(0.2);
        decoration = BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        );
        break;
      case VLButtonType.tertiary:
        backgroundColor = Colors.transparent;
        textColor = AppTheme.primaryBlue;
        borderColor = Colors.transparent;
        overlayColor = AppTheme.primaryBlue.withOpacity(0.1);
        break;
      case VLButtonType.premium:
        backgroundColor = Colors.transparent;
        textColor = AppTheme.premiumGold;
        borderColor = AppTheme.premiumGold;
        overlayColor = AppTheme.premiumGold.withOpacity(0.1);
        decoration = BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.premiumGold, AppTheme.premiumOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.premiumGold.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        );
        textColor = Colors.white;
        break;
    }

    final buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            ),
          )
        else if (icon != null) ...[
          Icon(
            icon,
            color: textColor,
            size: isSmall ? 16 : 20,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: isSmall ? 14 : 16,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    final button = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        splashColor: overlayColor,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: onPressed == null ? 0.5 : 1.0,
          child: Container(
            padding: buttonPadding,
            decoration: decoration,
            child: buttonContent,
          ),
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    } else {
      return button;
    }
  }
}

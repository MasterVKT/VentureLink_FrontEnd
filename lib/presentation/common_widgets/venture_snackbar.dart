import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum VentureSnackBarType {
  success,
  error,
  warning,
  info,
}

class VentureSnackBar extends SnackBar {
  final VentureSnackBarType type;
  @override
  final bool showCloseIcon;

  VentureSnackBar({
    super.key,
    required String message,
    this.type = VentureSnackBarType.info,
    super.duration,
    VoidCallback? onActionPressed,
    String? actionLabel,
    this.showCloseIcon = true,
  }) : super(
          content: Row(
            children: [
              Icon(
                _getIcon(type),
                color: AppTheme.white,
              ),
              const SizedBox(width: AppTheme.defaultPadding / 2),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: AppTheme.white),
                ),
              ),
            ],
          ),
          backgroundColor: _getBackgroundColor(type),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
          ),
          action: actionLabel != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: AppTheme.white,
                  onPressed: () {
                    onActionPressed?.call();
                  },
                )
              : null,
          margin: const EdgeInsets.all(AppTheme.defaultPadding),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.defaultPadding,
            vertical: AppTheme.defaultPadding / 2,
          ),
        );

  static Color _getBackgroundColor(VentureSnackBarType type) {
    switch (type) {
      case VentureSnackBarType.success:
        return AppTheme.successGreen;
      case VentureSnackBarType.error:
        return AppTheme.alertRed;
      case VentureSnackBarType.warning:
        return AppTheme.notificationYellow;
      case VentureSnackBarType.info:
        return AppTheme.primaryBlue;
    }
  }

  static IconData _getIcon(VentureSnackBarType type) {
    switch (type) {
      case VentureSnackBarType.success:
        return Icons.check_circle_outline;
      case VentureSnackBarType.error:
        return Icons.error_outline;
      case VentureSnackBarType.warning:
        return Icons.warning_amber_outlined;
      case VentureSnackBarType.info:
        return Icons.info_outline;
    }
  }
}

void showVentureSnackBar({
  required BuildContext context,
  required String message,
  VentureSnackBarType type = VentureSnackBarType.info,
  Duration duration = const Duration(seconds: 4),
  VoidCallback? onActionPressed,
  String? actionLabel,
  bool showCloseIcon = true,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    VentureSnackBar(
      message: message,
      type: type,
      duration: duration,
      onActionPressed: onActionPressed,
      actionLabel: actionLabel,
      showCloseIcon: showCloseIcon,
    ),
  );
}

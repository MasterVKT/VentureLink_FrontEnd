import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'venture_button.dart';

class VentureDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final Widget? icon;
  final Widget? content;
  final List<Widget>? actions;

  const VentureDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.icon,
    this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(height: AppTheme.defaultPadding),
            ],
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.defaultPadding / 2),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.darkGrey,
                  ),
              textAlign: TextAlign.center,
            ),
            if (content != null) ...[
              const SizedBox(height: AppTheme.defaultPadding),
              content!,
            ],
            const SizedBox(height: AppTheme.defaultPadding),
            if (actions != null)
              ...actions!
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (cancelText != null)
                    VentureButton(
                      text: cancelText!,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onCancel?.call();
                      },
                      type: VentureButtonType.secondary,
                    ),
                  if (cancelText != null && confirmText != null)
                    const SizedBox(width: AppTheme.defaultPadding / 2),
                  if (confirmText != null)
                    VentureButton(
                      text: confirmText!,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirm?.call();
                      },
                      type: isDestructive
                          ? VentureButtonType.tertiary
                          : VentureButtonType.primary,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

Future<T?> showVentureDialog<T>({
  required BuildContext context,
  required String title,
  required String message,
  String? confirmText,
  String? cancelText,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  bool isDestructive = false,
  Widget? icon,
  Widget? content,
  List<Widget>? actions,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => VentureDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
      isDestructive: isDestructive,
      icon: icon,
      content: content,
      actions: actions,
    ),
  );
}

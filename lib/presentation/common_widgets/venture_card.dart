import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class VentureCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool isLoading;
  final Widget? loadingWidget;

  const VentureCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.isLoading = false,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.all(AppTheme.defaultPadding),
      elevation: elevation ?? 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppTheme.defaultBorderRadius),
      ),
      color: backgroundColor ?? AppTheme.white,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppTheme.defaultBorderRadius),
        child: Stack(
          children: [
            Padding(
              padding: padding ?? const EdgeInsets.all(AppTheme.defaultPadding),
              child: child,
            ),
            if (isLoading)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.7),
                  borderRadius: borderRadius ??
                      BorderRadius.circular(AppTheme.defaultBorderRadius),
                ),
                child: Center(
                  child: loadingWidget ??
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryBlue,
                        ),
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

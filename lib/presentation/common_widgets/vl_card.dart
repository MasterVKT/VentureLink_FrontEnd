import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class VLCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool isPremium;
  final VoidCallback? onTap;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const VLCard({
    super.key,
    required this.child,
    this.padding,
    this.isPremium = false,
    this.onTap,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppTheme.defaultPadding),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.white,
          borderRadius: borderRadius ??
              BorderRadius.circular(AppTheme.defaultBorderRadius * 1.5),
          boxShadow: elevation != null && elevation! > 0
              ? [
                  BoxShadow(
                    color: AppTheme.black.withOpacity(0.1),
                    blurRadius: elevation!,
                    offset: Offset(0, elevation! / 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppTheme.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
          border: isPremium
              ? Border.all(
                  color: AppTheme.premiumGold,
                  width: 1.5,
                )
              : Border.all(
                  color: AppTheme.mediumGrey.withOpacity(0.1),
                  width: 1,
                ),
        ),
        child: ClipRRect(
          borderRadius: borderRadius ??
              BorderRadius.circular(AppTheme.defaultBorderRadius * 1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isPremium)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: AppTheme.defaultPadding,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.premiumGold, AppTheme.premiumOrange],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              Material(
                color: backgroundColor ?? AppTheme.white,
                child: InkWell(
                  onTap: onTap,
                  splashColor: AppTheme.primaryBlue.withOpacity(0.1),
                  highlightColor: AppTheme.lightGrey.withOpacity(0.2),
                  child: Padding(
                    padding: padding ??
                        const EdgeInsets.all(AppTheme.defaultPadding),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

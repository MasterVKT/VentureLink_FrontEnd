// lib/presentation/widgets/common/app_refresh_indicator.dart

import 'package:flutter/material.dart';
import 'package:venturelink/core/services/haptic_service.dart';

/// RefreshIndicator réutilisable avec feedback haptique intégré
/// Remplace tous les RefreshIndicator basiques dans l'app
class AppRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;

  const AppRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      // Feedback haptique au déclenchement du refresh
      onRefresh: () async {
        await HapticService.selection();
        await onRefresh();
        await HapticService.success();
      },
      color: color ?? Theme.of(context).colorScheme.primary,
      strokeWidth: 2.5,
      displacement: 60,
      child: child,
    );
  }
}

import 'package:flutter/material.dart';

/// Widget de chargement centralisé réutilisable
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final bool showSpinner;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.showSpinner = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showSpinner)
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

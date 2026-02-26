import 'package:flutter/material.dart';

/// Widget de chargement centralisé réutilisable
class LoadingStateWidget extends StatelessWidget {
  /// Message optionnel à afficher sous le spinner
  final String? message;

  /// true = chargement initial (gros spinner centré)
  /// false = chargement page suivante (petit spinner en bas de liste)
  final bool isInitialLoading;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.isInitialLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isInitialLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
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

    // Chargement de la page suivante (footer de la liste)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

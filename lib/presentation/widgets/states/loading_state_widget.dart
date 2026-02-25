import 'package:flutter/material.dart';

/// Widget affichant un état de chargement (initial ou pagination suivante)
class LoadingStateWidget extends StatelessWidget {
  /// Message optionnel à afficher sous le spinner (seulement pour chargement initial)
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
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 24),
              Text(
                message!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ] else
              const SizedBox(height: 16),
            const Text(
              'Chargement en cours...',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Chargement de la page suivante (footer de la liste)
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Affiche un état d'erreur avec icône, message, et bouton de réessai
class ErrorStateWidget extends StatelessWidget {
  /// Message principal à afficher (ex: "Pas de connexion internet")
  final String message;

  /// Fonction appelée quand on clique sur "Réessayer"
  final VoidCallback onRetry;

  /// Icône personnalisée (optionnelle)
  final IconData? icon;

  /// Sous-titre optionnel (ex: code HTTP, message technique)
  final String? subtitle;
/// Widget d'état d'erreur réutilisable
/// Affiche un message d'erreur avec un bouton pour réessayer
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.icon,
    this.subtitle,
    this.onRetry,
    this.retryLabel = 'Réessayer',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône d'erreur
              Icon(
                icon ?? Icons.error_outline_rounded,
                size: 80,
                color: colorScheme.error,
              ),
              const SizedBox(height: 24),

              // Message principal
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),

              // Sous-titre optionnel
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Bouton Réessayer
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Réessayer'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(220, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Oups !',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

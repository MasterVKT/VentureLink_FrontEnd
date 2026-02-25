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

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.icon,
    this.subtitle,
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
        ),
      ),
    );
  }
}

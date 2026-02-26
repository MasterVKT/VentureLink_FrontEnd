import 'package:flutter/material.dart';

/// Widget d'état d'erreur réutilisable
/// Affiche un message d'erreur avec un bouton pour réessayer
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? subtitle;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
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

              // Bouton Réessayer
              if (onRetry != null) ...[
                const SizedBox(height: 40),
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
            ],
          ),
        ),
      ),
    );
  }
}

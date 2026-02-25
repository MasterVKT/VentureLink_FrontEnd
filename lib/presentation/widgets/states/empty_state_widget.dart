import 'package:flutter/material.dart';

/// Widget affiché quand il n'y a aucun élément (liste vide)
class EmptyStateWidget extends StatelessWidget {
  /// Titre principal (ex: "Aucun projet trouvé")
  final String title;

  /// Description plus détaillée
  final String message;

  /// Action optionnelle (ex: bouton "Créer un projet")
  final VoidCallback? onAction;

  /// Texte du bouton d'action
  final String? actionLabel;

  /// Chemin de l'image d'illustration (doit exister dans assets)
  final String assetPath;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.onAction,
    this.actionLabel,
    this.assetPath = 'assets/images/empty_state.png',
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Image.asset(
              assetPath,
              width: size.width * 0.50.clamp(140.0, 280.0),
              height: size.width * 0.50.clamp(140.0, 280.0),
              fit: BoxFit.contain,
              // En cas d'image manquante
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.hourglass_empty_rounded,
                size: 140,
                color: theme.colorScheme.outline,
              ),
            ),

            const SizedBox(height: 32),

            // Titre
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message descriptif
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),

            // Bouton d'action optionnel
            if (onAction != null) ...[
              const SizedBox(height: 36),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(240, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionLabel ?? 'Action',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

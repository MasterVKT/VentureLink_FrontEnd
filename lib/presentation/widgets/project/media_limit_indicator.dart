import 'package:flutter/material.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/data/models/user_model.dart';

/// Widget pour afficher les limites de médias et incitations premium
class MediaLimitIndicator extends StatelessWidget {
  final UserModel user;
  final ProjectModel? project;
  final VoidCallback? onUpgradePressed;

  const MediaLimitIndicator({
    super.key,
    required this.user,
    this.project,
    this.onUpgradePressed,
  });

  int get _maxMediaCount => user.isPremium ? 3 : 1;

  int get _currentMediaCount {
    if (project == null) return 0;
    int count = 0;

    // Compter l'image principale
    if (project!.primaryImageUrl != null &&
        project!.primaryImageUrl!.isNotEmpty) {
      count++;
    }

    // Compter les autres médias (en évitant les doublons)
    if (project!.media != null) {
      for (final media in project!.media!) {
        if (media.fileUrl != null && media.fileUrl!.isNotEmpty) {
          // Vérifier que ce n'est pas un doublon avec l'image principale
          final isNotDuplicate = project!.primaryImageUrl == null ||
              !media.fileUrl!
                  .contains(project!.primaryImageUrl!.split('/').last);
          if (isNotDuplicate) {
            count++;
          }
        }
      }
    }

    return count;
  }

  bool get _canAddMedia => _currentMediaCount < _maxMediaCount;
  bool get _isAtLimit => _currentMediaCount >= _maxMediaCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: user.isPremium
            ? Colors.amber.withValues(alpha: 0.1)
            : Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: user.isPremium
              ? Colors.amber.withValues(alpha: 0.3)
              : Colors.blue.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec statut
          Row(
            children: [
              Icon(
                user.isPremium ? Icons.star : Icons.image,
                color: user.isPremium ? Colors.amber : Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                user.isPremium ? 'Compte Premium' : 'Compte Standard',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: user.isPremium ? Colors.amber[700] : Colors.blue[700],
                ),
              ),
              const Spacer(),
              if (user.isPremium)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'PREMIUM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Compteur de médias
          Row(
            children: [
              Text(
                'Médias utilisés: ',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '$_currentMediaCount/$_maxMediaCount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isAtLimit ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Barre de progression
          LinearProgressIndicator(
            value: _currentMediaCount / _maxMediaCount,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _isAtLimit
                  ? Colors.red
                  : (user.isPremium ? Colors.amber : Colors.blue),
            ),
          ),

          const SizedBox(height: 8),

          // Message informatif
          Text(
            _buildInfoMessage(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),

          // Bouton d'upgrade pour les utilisateurs non-premium
          if (!user.isPremium && onUpgradePressed != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onUpgradePressed,
                icon: const Icon(Icons.star, size: 16),
                label: const Text('Passer à Premium'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _buildInfoMessage() {
    if (user.isPremium) {
      if (_canAddMedia) {
        final remaining = _maxMediaCount - _currentMediaCount;
        return 'Vous pouvez ajouter $remaining média(s) supplémentaire(s).';
      } else {
        return 'Limite atteinte. Supprimez un média pour en ajouter un nouveau.';
      }
    } else {
      if (_canAddMedia) {
        return 'Ajoutez jusqu\'à 1 média. Passez à Premium pour 3 médias.';
      } else {
        return 'Limite atteinte. Passez à Premium pour ajouter 2 médias supplémentaires.';
      }
    }
  }
}

/// Widget compact pour afficher le nombre de médias sur une carte de projet
class MediaCountBadge extends StatelessWidget {
  final ProjectModel project;
  final bool showPremiumIndicator;

  const MediaCountBadge({
    super.key,
    required this.project,
    this.showPremiumIndicator = true,
  });

  int get _mediaCount {
    int count = 0;

    // Compter l'image principale
    if (project.primaryImageUrl != null &&
        project.primaryImageUrl!.isNotEmpty) {
      count++;
    }

    // Compter les autres médias
    if (project.media != null) {
      count += project.media!
          .where((media) => media.fileUrl != null && media.fileUrl!.isNotEmpty)
          .length;
    }

    return count;
  }

  @override
  Widget build(BuildContext context) {
    if (_mediaCount <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.photo_library,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            '$_mediaCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showPremiumIndicator && project.creator.isPremium) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.star,
              color: Colors.amber,
              size: 10,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget pour les messages d'incitation à l'upgrade premium
class PremiumUpgradePrompt extends StatelessWidget {
  final String message;
  final VoidCallback? onUpgradePressed;
  final bool isCompact;

  const PremiumUpgradePrompt({
    super.key,
    required this.message,
    this.onUpgradePressed,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.amber.withValues(alpha: 0.1),
              Colors.orange.withValues(alpha: 0.1)
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            if (onUpgradePressed != null)
              TextButton(
                onPressed: onUpgradePressed,
                child: const Text(
                  'Upgrade',
                  style: TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      );
    }

    return Card(
      color: Colors.amber.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Débloquez plus de fonctionnalités',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onUpgradePressed != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onUpgradePressed,
                  icon: const Icon(Icons.star),
                  label: const Text('Passer à Premium'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:venturelink/core/router/app_router.dart';
import 'package:venturelink/data/providers/subscription_provider.dart';

/// Utilitaires pour la gestion des fonctionnalités Premium
class PremiumUtils {
  /// Vérifie si l'utilisateur a accès à une fonctionnalité Premium
  /// Retourne true si l'utilisateur a accès, false sinon
  static bool canAccessPremiumFeature(
      BuildContext context, PremiumFeature feature) {
    final subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);

    // Si l'utilisateur a un abonnement actif, il a accès à toutes les fonctionnalités
    if (subscriptionProvider.hasActiveSubscription) {
      return true;
    }

    // Sinon, vérifier les limites de base pour chaque fonctionnalité
    switch (feature) {
      case PremiumFeature.projectCreation:
        // Les utilisateurs gratuits peuvent créer jusqu'à 2 projets
        return subscriptionProvider.projectsCreatedCount < 2;

      case PremiumFeature.investmentProposals:
        // Les utilisateurs gratuits peuvent faire jusqu'à 5 propositions d'investissement
        return subscriptionProvider.investmentProposalsCount < 5;

      case PremiumFeature.advancedSearch:
        // Les utilisateurs gratuits ont accès à la recherche de base uniquement
        return false;

      case PremiumFeature.messaging:
        // Les utilisateurs gratuits peuvent envoyer jusqu'à 10 messages par jour
        return subscriptionProvider.dailyMessagesCount < 10;

      case PremiumFeature.profileVisibility:
        // Les utilisateurs gratuits ont une visibilité limitée
        return false;

      case PremiumFeature.exportData:
        // L'exportation des données est réservée aux utilisateurs Premium
        return false;

      case PremiumFeature.prioritySupport:
        // Le support prioritaire est réservé aux utilisateurs Premium
        return false;

      default:
        return false;
    }
  }

  /// Affiche une boîte de dialogue pour promouvoir l'abonnement Premium
  /// lorsqu'un utilisateur tente d'accéder à une fonctionnalité restreinte
  static Future<bool> showPremiumUpsellDialog(
    BuildContext context,
    PremiumFeature feature,
  ) async {
    final featureDetails = _getFeatureDetails(feature);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fonctionnalité Premium'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(featureDetails.description),
            const SizedBox(height: 16),
            const Text(
              'Passez à VentureLink Premium pour accéder à toutes les fonctionnalités sans limites.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: const Text('Découvrir Premium'),
          ),
        ],
      ),
    );

    // Si l'utilisateur a cliqué sur "Découvrir Premium", naviguer vers l'écran Premium
    if (result == true) {
      context.router.push(const PremiumRoute());
      return false;
    }

    return false;
  }

  /// Vérifie l'accès à une fonctionnalité Premium et affiche une boîte de dialogue si nécessaire
  /// Retourne true si l'utilisateur a accès, false sinon
  static Future<bool> checkPremiumAccess(
    BuildContext context,
    PremiumFeature feature,
  ) async {
    final hasAccess = canAccessPremiumFeature(context, feature);

    if (!hasAccess) {
      return await showPremiumUpsellDialog(context, feature);
    }

    return true;
  }

  /// Obtient les détails d'une fonctionnalité Premium
  static _FeatureDetails _getFeatureDetails(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.projectCreation:
        return _FeatureDetails(
          title: 'Création de projets',
          description:
              'Les utilisateurs gratuits peuvent créer jusqu\'à 2 projets. Passez à Premium pour des projets illimités.',
          icon: Icons.business,
        );

      case PremiumFeature.investmentProposals:
        return _FeatureDetails(
          title: 'Propositions d\'investissement',
          description:
              'Les utilisateurs gratuits peuvent faire jusqu\'à 5 propositions d\'investissement. Premium permet des propositions illimitées.',
          icon: Icons.monetization_on,
        );

      case PremiumFeature.advancedSearch:
        return _FeatureDetails(
          title: 'Recherche avancée',
          description:
              'La recherche avancée avec filtres multiples est une fonctionnalité exclusive Premium.',
          icon: Icons.search,
        );

      case PremiumFeature.messaging:
        return _FeatureDetails(
          title: 'Messagerie',
          description:
              'Les utilisateurs gratuits peuvent envoyer jusqu\'à 10 messages par jour. Premium offre une messagerie illimitée.',
          icon: Icons.message,
        );

      case PremiumFeature.profileVisibility:
        return _FeatureDetails(
          title: 'Visibilité du profil',
          description:
              'Augmentez votre visibilité avec un profil Premium mis en avant dans les résultats de recherche.',
          icon: Icons.visibility,
        );

      case PremiumFeature.exportData:
        return _FeatureDetails(
          title: 'Exportation de données',
          description:
              'L\'exportation des données en CSV ou PDF est une fonctionnalité exclusive Premium.',
          icon: Icons.download,
        );

      case PremiumFeature.prioritySupport:
        return _FeatureDetails(
          title: 'Support prioritaire',
          description:
              'Les membres Premium bénéficient d\'une assistance prioritaire et d\'un accès à un conseiller dédié.',
          icon: Icons.support_agent,
        );

      default:
        return _FeatureDetails(
          title: 'Fonctionnalité Premium',
          description: 'Cette fonctionnalité est réservée aux membres Premium.',
          icon: Icons.star,
        );
    }
  }
}

/// Énumération des fonctionnalités Premium disponibles dans l'application
enum PremiumFeature {
  projectCreation,
  investmentProposals,
  advancedSearch,
  messaging,
  profileVisibility,
  exportData,
  prioritySupport,
}

/// Classe interne pour stocker les détails d'une fonctionnalité
class _FeatureDetails {
  final String title;
  final String description;
  final IconData icon;

  _FeatureDetails({
    required this.title,
    required this.description,
    required this.icon,
  });
}

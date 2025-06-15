import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@RoutePage()
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confidentialité'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.privacy_tip,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paramètres de confidentialité',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gérez vos préférences de confidentialité et de sécurité',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Visibilité du profil
            _buildSection(
              context,
              'Visibilité du profil',
              [
                _buildSwitchTile(
                  context,
                  'Profil public',
                  'Votre profil est visible par tous les utilisateurs',
                  Icons.public,
                  true,
                  (value) {
                    // TODO: Implémenter la logique
                  },
                ),
                _buildSwitchTile(
                  context,
                  'Afficher l\'email',
                  'Votre adresse email est visible sur votre profil',
                  Icons.email,
                  false,
                  (value) {
                    // TODO: Implémenter la logique
                  },
                ),
                _buildSwitchTile(
                  context,
                  'Afficher le téléphone',
                  'Votre numéro de téléphone est visible sur votre profil',
                  Icons.phone,
                  false,
                  (value) {
                    // TODO: Implémenter la logique
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Notifications
            _buildSection(
              context,
              'Notifications',
              [
                _buildSwitchTile(
                  context,
                  'Notifications par email',
                  'Recevoir des notifications par email',
                  Icons.mail_outline,
                  true,
                  (value) {
                    // TODO: Implémenter la logique
                  },
                ),
                _buildSwitchTile(
                  context,
                  'Notifications push',
                  'Recevoir des notifications push sur votre appareil',
                  Icons.notifications,
                  true,
                  (value) {
                    // TODO: Implémenter la logique
                  },
                ),
                _buildSwitchTile(
                  context,
                  'Notifications marketing',
                  'Recevoir des informations sur les nouveautés et offres',
                  Icons.campaign,
                  false,
                  (value) {
                    // TODO: Implémenter la logique
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Données personnelles
            _buildSection(
              context,
              'Données personnelles',
              [
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Télécharger mes données'),
                  subtitle: const Text(
                      'Obtenez une copie de vos données personnelles'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showComingSoonDialog(
                        context, 'Téléchargement des données');
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete_forever,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    'Supprimer mon compte',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  subtitle:
                      const Text('Suppression définitive de votre compte'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showDeleteAccountDialog(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Informations légales
            _buildSection(
              context,
              'Informations légales',
              [
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Politique de confidentialité'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    _showComingSoonDialog(
                        context, 'Politique de confidentialité');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.gavel),
                  title: const Text('Conditions d\'utilisation'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    _showComingSoonDialog(context, 'Conditions d\'utilisation');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cookie),
                  title: const Text('Politique des cookies'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    _showComingSoonDialog(context, 'Politique des cookies');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text('Cette fonctionnalité sera bientôt disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer définitivement votre compte ? '
          'Cette action est irréversible et toutes vos données seront perdues.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité à venir'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

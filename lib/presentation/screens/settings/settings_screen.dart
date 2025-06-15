import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/router/app_router.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/subscription_provider.dart';

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: Consumer2<AuthProvider, SubscriptionProvider>(
        builder: (context, authProvider, subscriptionProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Section Compte
              _buildSectionHeader('Compte'),
              _buildSettingsTile(
                icon: Icons.person,
                title: 'Profil',
                subtitle: 'Modifier vos informations personnelles',
                onTap: () => context.router.push(const ProfileEditRoute()),
              ),
              _buildSettingsTile(
                icon: Icons.workspace_premium,
                title: 'Abonnements',
                subtitle: subscriptionProvider.hasActiveSubscription
                    ? 'Gérer votre abonnement premium'
                    : 'Découvrir les plans premium',
                onTap: () =>
                    context.router.push(const SimpleSubscriptionRoute()),
                trailing: subscriptionProvider.hasActiveSubscription
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
              _buildSettingsTile(
                icon: Icons.star,
                title: 'Devenir Premium',
                subtitle: 'Débloquer toutes les fonctionnalités',
                onTap: () => context.router.push(const PremiumRoute()),
              ),

              const SizedBox(height: 24),

              // Section Notifications
              _buildSectionHeader('Notifications'),
              _buildSettingsTile(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Gérer vos préférences de notification',
                onTap: () => context.router.push(const NotificationsRoute()),
              ),

              const SizedBox(height: 24),

              // Section Sécurité
              _buildSectionHeader('Sécurité'),
              _buildSettingsTile(
                icon: Icons.lock,
                title: 'Mot de passe',
                subtitle: 'Changer votre mot de passe',
                onTap: () => _showChangePasswordDialog(context),
              ),
              _buildSettingsTile(
                icon: Icons.privacy_tip,
                title: 'Confidentialité',
                subtitle: 'Paramètres de confidentialité',
                onTap: () => _showPrivacySettings(context),
              ),

              const SizedBox(height: 24),

              // Section Support
              _buildSectionHeader('Support'),
              _buildSettingsTile(
                icon: Icons.help,
                title: 'Aide & Support',
                subtitle: 'Obtenir de l\'aide',
                onTap: () => _showSupport(context),
              ),
              _buildSettingsTile(
                icon: Icons.info,
                title: 'À propos',
                subtitle: 'Version de l\'application',
                onTap: () => _showAbout(context),
              ),

              const SizedBox(height: 24),

              // Déconnexion
              _buildSettingsTile(
                icon: Icons.logout,
                title: 'Déconnexion',
                subtitle: 'Se déconnecter de l\'application',
                onTap: () => _showLogoutDialog(context, authProvider),
                textColor: Colors.red,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    Color? textColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: textColor),
        title: Text(
          title,
          style: TextStyle(color: textColor),
        ),
        subtitle: Text(subtitle),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le mot de passe'),
        content: const Text('Cette fonctionnalité sera bientôt disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paramètres de confidentialité'),
        content: const Text('Cette fonctionnalité sera bientôt disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aide & Support'),
        content: const Text('Contactez-nous à support@venturelink.com'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À propos'),
        content: const Text(
            'VentureLink v1.0.0\nPlateforme de financement participatif'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();
              if (context.mounted) {
                context.router.replaceAll([const LoginRoute()]);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}

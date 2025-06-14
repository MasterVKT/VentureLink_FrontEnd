import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:venturelink/data/models/user_model.dart';
import 'package:venturelink/data/providers/auth_provider.dart';
import 'package:venturelink/data/providers/profile_provider.dart';
import 'package:venturelink/data/providers/subscription_provider.dart';
import 'package:venturelink/core/config/app_config.dart';
import 'package:venturelink/core/router/app_router.dart';
import 'package:venturelink/core/utils/image_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';

@RoutePage()
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.profile),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.router.push(const SettingsRoute()),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.router.push(const NotificationsRoute()),
          ),
        ],
      ),
      body: Consumer2<AuthProvider, SubscriptionProvider>(
        builder: (context, authProvider, subscriptionProvider, child) {
          final user = authProvider.currentUser;
          final hasActiveSubscription =
              subscriptionProvider.hasActiveSubscription;

          if (user == null) {
            return const Center(
              child: Text('Utilisateur non connecté'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await authProvider.refreshUser();
              await subscriptionProvider.loadCurrentSubscription();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConfig.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête du profil
                  _buildProfileHeader(user, hasActiveSubscription),

                  const SizedBox(height: 24),

                  // Actions rapides
                  _buildQuickActions(),

                  const SizedBox(height: 24),

                  // Informations du profil
                  if (user.profile != null) _buildProfileInfo(user.profile!),

                  const SizedBox(height: 24),

                  // Statistiques
                  _buildStatistics(user),

                  const SizedBox(height: 24),

                  // Actions du compte
                  _buildAccountActions(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user, bool isPremium) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          children: [
            // Photo de profil
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: user.profile?.profilePicture != null
                        ? CachedNetworkImageProvider(
                            user.profile!.profilePicture!)
                        : null,
                    child: user.profile?.profilePicture == null
                        ? Text(
                            user.firstName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: _changeProfilePicture,
                      iconSize: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Nom et badges
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.fullName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (user.isVerified) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ],
                if (isPremium) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  ),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // Email et type d'utilisateur
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),

            const SizedBox(height: 4),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getUserTypeLabel(user.userType),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            if (user.profile?.title != null) ...[
              const SizedBox(height: 8),
              Text(
                user.profile!.title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],

            if (user.profile?.bioShort != null) ...[
              const SizedBox(height: 12),
              Text(
                user.profile!.bioShort!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions rapides',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.edit,
                    label: 'Modifier le profil',
                    onTap: _editProfile,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.add_box_outlined,
                    label: 'Créer un projet',
                    onTap: _createProject,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Mes investissements',
                    onTap: _goToInvestments,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.share,
                    label: 'Partager profil',
                    onTap: _shareProfile,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(ProfileModel profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations du profil',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (profile.bioShort != null) ...[
              _buildInfoRow('À propos', profile.bioShort!),
              const SizedBox(height: 12),
            ],
            if (profile.website != null) ...[
              _buildInfoRow('Site web', profile.website!),
              const SizedBox(height: 12),
            ],
            if (profile.socialLinkedin != null) ...[
              _buildInfoRow('LinkedIn', profile.socialLinkedin!),
              const SizedBox(height: 12),
            ],
            if (profile.socialTwitter != null) ...[
              _buildInfoRow('Twitter', profile.socialTwitter!),
              const SizedBox(height: 12),
            ],
            if (profile.avgRating != null) ...[
              _buildInfoRow('Note moyenne',
                  '${profile.avgRating?.toStringAsFixed(1)} ⭐ (${profile.ratingCount} avis)'),
              const SizedBox(height: 12),
            ],
            _buildInfoRow('Niveau de vérification',
                _getVerificationLevel(profile.verificationLevel)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(UserModel user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Projets créés', '3'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Investissements', '7'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Connexions', '24'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Note moyenne', '4.8⭐'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compte',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.router.push(const SettingsRoute()),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Confidentialité'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _goToPrivacy,
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Aide & Support'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _goToSupport,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Déconnexion',
                  style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  String _getUserTypeLabel(String userType) {
    switch (userType) {
      case 'ENTREPRENEUR':
        return 'Entrepreneur';
      case 'INVESTOR':
        return 'Investisseur';
      case 'MENTOR':
        return 'Mentor';
      default:
        return userType;
    }
  }

  String _getVerificationLevel(String level) {
    switch (level) {
      case 'BASIC':
        return 'Basique';
      case 'VERIFIED':
        return 'Vérifié';
      case 'PREMIUM':
        return 'Premium';
      default:
        return level;
    }
  }

  void _changeProfilePicture() async {
    final profileProvider = context.read<ProfileProvider>();

    if (profileProvider.isUploadingProfilePicture) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Poignée
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Photo de profil',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _takePicture();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir dans la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            if (context
                    .read<AuthProvider>()
                    .currentUser
                    ?.profile
                    ?.profilePicture !=
                null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Supprimer la photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePicture();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _takePicture() async {
    try {
      final file = await ImageUtils.takePhotoWithCamera();
      if (file != null && mounted) {
        await _uploadProfilePicture(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _pickFromGallery() async {
    try {
      final file = await ImageUtils.pickImageFromGallery();
      if (file != null && mounted) {
        await _uploadProfilePicture(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadProfilePicture(File imageFile) async {
    final profileProvider = context.read<ProfileProvider>();
    final authProvider = context.read<AuthProvider>();

    final success = await profileProvider.uploadProfilePicture(imageFile);

    if (success && mounted) {
      // Mettre à jour l'AuthProvider avec les nouvelles données
      authProvider.updateUser(profileProvider.user!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil mise à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(profileProvider.error ?? 'Erreur lors de l\'upload'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeProfilePicture() async {
    final profileProvider = context.read<ProfileProvider>();
    final authProvider = context.read<AuthProvider>();

    final success = await profileProvider.removeProfilePicture();

    if (success && mounted) {
      // Mettre à jour l'AuthProvider avec les nouvelles données
      authProvider.updateUser(profileProvider.user!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil supprimée'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(profileProvider.error ?? 'Erreur lors de la suppression'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editProfile() {
    context.router.push(const ProfileEditRoute());
  }

  void _createProject() {
    context.router.push(const ProjectCreateRoute());
  }

  void _goToInvestments() {
    context.router.pushAndPopUntil(
      const MainRoute(),
      predicate: (route) => false,
    );
    // TODO: Naviguer vers l'onglet investissements
  }

  void _shareProfile() {
    // TODO: Implémenter le partage de profil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de partage à venir'),
      ),
    );
  }

  void _goToPrivacy() {
    // TODO: Naviguer vers les paramètres de confidentialité
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paramètres de confidentialité à venir'),
      ),
    );
  }

  void _goToSupport() {
    // TODO: Naviguer vers l'aide et le support
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Section aide & support à venir'),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<AuthProvider>().logout();
              if (mounted) {
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

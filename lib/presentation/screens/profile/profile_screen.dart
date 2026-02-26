import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:venturelink/data/models/user_model.dart';
import 'package:venturelink/data/providers/auth_provider.dart';
import 'package:venturelink/data/providers/profile_provider.dart';
import 'package:venturelink/data/providers/subscription_provider.dart';
import 'package:venturelink/data/providers/user_stats_provider.dart';
import 'package:venturelink/core/config/app_config.dart';
import 'package:venturelink/core/router/app_router.dart';
import 'package:venturelink/core/services/profile_share_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:venturelink/l10n/app_localizations.dart';

@RoutePage()
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;
  late AnimationController _photoController;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _photoController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Charger les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userStatsProvider = context.read<UserStatsProvider>();
    await userStatsProvider.loadUserStats();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 768;
    final isLargeScreen = mediaQuery.size.width > 1200;

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.profile),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.router.push(const SettingsRoute()),
            tooltip: 'Paramètres',
            iconSize: isTablet ? 28 : 24,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.router.push(const NotificationsRoute()),
            tooltip: 'Notifications',
            iconSize: isTablet ? 28 : 24,
          ),
        ],
      ),
      body: Consumer3<AuthProvider, SubscriptionProvider, UserStatsProvider>(
        builder: (context, authProvider, subscriptionProvider,
            userStatsProvider, child) {
          final user = authProvider.currentUser;
          final hasActiveSubscription =
              subscriptionProvider.hasActiveSubscription;

          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    semanticLabel: 'Utilisateur non connecté',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Utilisateur non connecté',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              _refreshController
                  .forward()
                  .then((_) => _refreshController.reset());

              await Future.wait([
                authProvider.refreshUser(),
                subscriptionProvider.loadCurrentSubscription(),
                userStatsProvider.refreshStats(),
              ]);

              if (mounted) {
                HapticFeedback.lightImpact();
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: const Text('Profil mis à jour'),
                    backgroundColor: theme.colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isLargeScreen
                  ? 32
                  : (isTablet ? 24 : AppConfig.defaultPadding)),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isLargeScreen ? 800 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête du profil avec espacement adaptatif
                      _buildProfileHeader(
                          user, hasActiveSubscription, isTablet),

                      SizedBox(height: isTablet ? 32 : 24),

                      // Actions rapides
                      _buildQuickActions(isTablet),

                      SizedBox(height: isTablet ? 32 : 24),

                      // Informations du profil
                      if (user.profile != null) ...[
                        _buildProfileInfo(user.profile!, isTablet),
                        SizedBox(height: isTablet ? 32 : 24),
                      ],

                      // Statistiques avec données réelles
                      _buildStatistics(userStatsProvider, isTablet),

                      SizedBox(height: isTablet ? 32 : 24),

                      // Actions du compte
                      _buildAccountActions(isTablet),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user, bool isPremium, bool isTablet) {
    final theme = Theme.of(context);
    final avatarRadius = isTablet ? 60.0 : 50.0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : AppConfig.defaultPadding),
        child: Column(
          children: [
            // Photo de profil avec accessibilité améliorée
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: avatarRadius,
                    backgroundImage: user.profile?.profilePicture != null
                        ? CachedNetworkImageProvider(
                            user.profile!.profilePicture!)
                        : null,
                    child: user.profile?.profilePicture == null
                        ? Text(
                            user.firstName[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: isTablet ? 36 : 32,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Material(
                    color: theme.colorScheme.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _changeProfilePicture,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 48, // Zone de touch minimum WCAG
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: AnimatedBuilder(
                          animation: _photoController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (_photoController.value * 0.1),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                                semanticLabel: 'Modifier la photo de profil',
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Nom et badges avec meilleure hiérarchie
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    user.fullName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (user.isVerified) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified,
                      color: theme.colorScheme.primary,
                      size: 20,
                      semanticLabel: 'Profil vérifié',
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
                      semanticsLabel: 'Utilisateur premium',
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // Email avec contraste amélioré
            Text(
              user.email,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 4),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getUserTypeLabel(user.userType),
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            if (user.profile?.title != null) ...[
              const SizedBox(height: 8),
              Text(
                user.profile!.title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (user.profile?.bioShort != null) ...[
              const SizedBox(height: 12),
              Text(
                user.profile!.bioShort!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isTablet) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions rapides',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isTablet ? 20 : 16),

            // Grille adaptative pour les actions
            if (isTablet)
              _buildTabletActionGrid()
            else
              _buildMobileActionGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletActionGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildActionButton(
              icon: Icons.edit,
              label: 'Modifier le profil',
              onTap: _editProfile,
            )),
            const SizedBox(width: 16),
            Expanded(
                child: _buildActionButton(
              icon: Icons.add_box_outlined,
              label: 'Créer un projet',
              onTap: _createProject,
            )),
            const SizedBox(width: 16),
            Expanded(
                child: _buildActionButton(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Mes investissements',
              onTap: _goToInvestments,
            )),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildActionButton(
              icon: Icons.workspace_premium,
              label: 'Abonnements',
              onTap: _goToSubscriptions,
            )),
            const SizedBox(width: 16),
            Expanded(
                child: _buildActionButton(
              icon: Icons.share,
              label: 'Partager profil',
              onTap: _shareProfile,
            )),
            const SizedBox(width: 16),
            Expanded(
                child: _buildActionButton(
              icon: Icons.star,
              label: 'Devenir Premium',
              onTap: _goToPremium,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileActionGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildActionButton(
              icon: Icons.edit,
              label: 'Modifier le profil',
              onTap: _editProfile,
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _buildActionButton(
              icon: Icons.add_box_outlined,
              label: 'Créer un projet',
              onTap: _createProject,
            )),
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
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _buildActionButton(
              icon: Icons.workspace_premium,
              label: 'Abonnements',
              onTap: _goToSubscriptions,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildActionButton(
              icon: Icons.share,
              label: 'Partager profil',
              onTap: _shareProfile,
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _buildActionButton(
              icon: Icons.star,
              label: 'Devenir Premium',
              onTap: _goToPremium,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                semanticLabel: label,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(ProfileModel profile, bool isTablet) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations du profil',
              style: theme.textTheme.titleLarge?.copyWith(
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
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          flex: 3,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(UserStatsProvider userStatsProvider, bool isTablet) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Statistiques',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (userStatsProvider.isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (userStatsProvider.error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.onErrorContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Erreur de chargement des statistiques',
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => userStatsProvider.refreshStats(),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Projets créés',
                        userStatsProvider.projectsCreated.toString()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('Investissements',
                        userStatsProvider.investmentsMade.toString()),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                        'Messages', userStatsProvider.messagesSent.toString()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                        'Note moyenne', '${userStatsProvider.averageRating}⭐'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions(bool isTablet) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compte',
              style: theme.textTheme.titleLarge?.copyWith(
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
              leading: Icon(
                Icons.logout,
                color: theme.colorScheme.error,
              ),
              title: Text(
                'Déconnexion',
                style: TextStyle(color: theme.colorScheme.error),
              ),
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
      case 'BOTH':
        return 'Entrepreneur & Investisseur';
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
                leading: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Supprimer la photo',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
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

  void _editProfile() async {
    final result = await context.router.push(const ProfileEditRoute());
    if (result != null && mounted) {
      // Rafraîchir les données après modification
      context.read<AuthProvider>().refreshUser();
      _photoController.forward().then((_) => _photoController.reset());
    }
  }

  void _createProject() {
    context.router.push(const ProjectCreateRoute());
  }

  void _goToInvestments() {
    // Navigation vers la liste des investissements
    context.router.push(const InvestmentListRoute());
  }

  void _goToSubscriptions() {
    context.router.push(const SimpleSubscriptionRoute());
  }

  void _shareProfile() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      HapticFeedback.mediumImpact();
      await ProfileShareService.shareProfile(context, user);
    }
  }

  void _goToPremium() {
    context.router.push(const SimpleSubscriptionRoute());
  }

  void _goToPrivacy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Page de confidentialité à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _goToSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Page d\'aide à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _logout() async {
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      HapticFeedback.heavyImpact();
      await context.read<AuthProvider>().logout();
      if (mounted) {
        context.router.replaceAll([const LoginRoute()]);
      }
    }
  }

  void _takePicture() async {
    final profileProvider = context.read<ProfileProvider>();
    final theme = Theme.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      _photoController.forward();
      final success = await profileProvider.updateProfilePictureFromCamera();

      if (mounted) {
        if (success) {
          HapticFeedback.lightImpact();
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: const Text('Photo de profil mise à jour'),
              backgroundColor: theme.colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Rafraîchir les données utilisateur
          if (mounted) {
            context.read<AuthProvider>().refreshUser();
          }
        } else if (profileProvider.error != null) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(profileProvider.error!),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      _photoController.reset();
    }
  }

  void _pickFromGallery() async {
    final profileProvider = context.read<ProfileProvider>();
    final theme = Theme.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      _photoController.forward();
      final success = await profileProvider.updateProfilePictureFromGallery();

      if (mounted) {
        if (success) {
          HapticFeedback.lightImpact();
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: const Text('Photo de profil mise à jour'),
              backgroundColor: theme.colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Rafraîchir les données utilisateur
          if (mounted) {
            context.read<AuthProvider>().refreshUser();
          }
        } else if (profileProvider.error != null) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(profileProvider.error!),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      _photoController.reset();
    }
  }

  void _removeProfilePicture() async {
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la photo'),
        content: const Text(
            'Êtes-vous sûr de vouloir supprimer votre photo de profil ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final profileProvider = context.read<ProfileProvider>();
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      try {
        final success = await profileProvider.removeProfilePicture();

        if (success && mounted) {
          HapticFeedback.lightImpact();
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: const Text('Photo de profil supprimée'),
              backgroundColor: theme.colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Rafraîchir les données utilisateur
          if (mounted) {
            context.read<AuthProvider>().refreshUser();
          }
        } else if (profileProvider.error != null && mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(profileProvider.error!),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}

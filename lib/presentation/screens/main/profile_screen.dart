import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/core/config/config_service.dart';
import 'package:venturelink/core/router/app_router.dart';
import 'package:venturelink/data/providers/auth_provider.dart';
import 'package:venturelink/data/providers/theme_provider.dart';

@RoutePage()
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Naviguer vers les paramètres
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(ConfigService.defaultPadding),
        children: [
          _buildProfileHeader(context, user),
          const SizedBox(height: ConfigService.defaultPadding),
          _buildStatistics(context),
          const SizedBox(height: ConfigService.defaultPadding),
          _buildSectionTitle(context, 'Mes projets'),
          const SizedBox(height: ConfigService.defaultSpacing),
          _buildProjectsList(context),
          const SizedBox(height: ConfigService.defaultPadding),
          _buildSectionTitle(context, 'Options du compte'),
          const SizedBox(height: ConfigService.defaultSpacing),
          _buildAccountOptions(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primary,
          backgroundImage:
              user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
          child: user?.photoUrl == null
              ? Text(
                  _getInitials(user?.firstName ?? '', user?.lastName ?? ''),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                )
              : null,
        ),
        const SizedBox(height: ConfigService.defaultSpacing),
        Text(
          user?.fullName ?? 'Utilisateur',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: ConfigService.defaultSpacing / 2),
        Text(
          user?.email ?? 'email@example.com',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
        ),
        const SizedBox(height: ConfigService.defaultSpacing),
        OutlinedButton(
          onPressed: () {
            // TODO: Naviguer vers l'édition du profil
          },
          child: const Text('Modifier le profil'),
        ),
      ],
    );
  }

  Widget _buildStatistics(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(context, '0', 'Projets'),
        _buildStatItem(context, '0', 'Contributions'),
        _buildStatItem(context, user?.profile?.viewsCount.toString() ?? '0',
            'Vues profil'),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildProjectsList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ConfigService.defaultPadding),
      child: Column(
        children: [
          Icon(
            Icons.work_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: ConfigService.defaultSpacing),
          Text(
            'Aucun projet pour le moment',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: ConfigService.defaultSpacing / 2),
          Text(
            'Créez votre premier projet pour commencer',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
          ),
          const SizedBox(height: ConfigService.defaultPadding),
          ElevatedButton.icon(
            onPressed: () {
              context.router.pushNamed('/project-create');
            },
            icon: const Icon(Icons.add),
            label: const Text('Créer un projet'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountOptions(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.account_balance_wallet_outlined),
          title: const Text('Mes Investissements'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Naviguer vers la page des investissements
            final tabsRouter = context.router.parent() as TabsRouter?;
            if (tabsRouter != null) {
              tabsRouter.setActiveIndex(
                  2); // Index de InvestmentListRoute dans MainScreen
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('Informations personnelles'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Naviguer vers les informations personnelles
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications_outlined),
          title: const Text('Notifications'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Naviguer vers les notifications
            final tabsRouter = context.router.parent() as TabsRouter?;
            if (tabsRouter != null) {
              tabsRouter.setActiveIndex(
                  4); // Index de NotificationsRoute dans MainScreen
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.security_outlined),
          title: const Text('Sécurité'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Naviguer vers les paramètres de sécurité
          },
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode_outlined),
          title: const Text('Thème'),
          trailing: Switch(
            value: context.watch<ThemeProvider>().themeMode == ThemeMode.dark,
            onChanged: (value) {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text(
            'Déconnexion',
            style: TextStyle(color: Colors.red),
          ),
          onTap: () async {
            final authProvider = context.read<AuthProvider>();
            await authProvider.logout();
            if (context.mounted) {
              context.router.replaceAll([const LoginRoute()]);
            }
          },
        ),
      ],
    );
  }

  String _getInitials(String firstName, String lastName) {
    String initials = '';
    if (firstName.isNotEmpty) {
      initials += firstName[0].toUpperCase();
    }
    if (lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
    }
    return initials;
  }
}

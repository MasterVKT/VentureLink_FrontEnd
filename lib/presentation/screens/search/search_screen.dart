import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:venturelink/constants/design_constants.dart';
import 'package:venturelink/presentation/common_widgets/vl_app_bar.dart';
import 'package:venturelink/presentation/common_widgets/vl_bottom_nav_bar.dart';
import 'package:venturelink/core/router/app_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@RoutePage()
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _currentIndex = 1; // Index 1 correspond à l'onglet de recherche

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigation vers d'autres écrans selon l'index
    switch (index) {
      case 0:
        context.router.push(const HomeRoute());
        break;
      case 1:
        // Déjà sur l'écran de recherche
        break;
      case 2:
        context.router.push(const ProjectCreateRoute());
        break;
      case 3:
        context.router.push(const NotificationsRoute());
        break;
      case 4:
        context.router.push(const ProfileRoute());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: DesignConstants.lightGrey,
      appBar: VLAppBar(
        title: appLocalizations.search,
        showLanguageButton: true,
        onProfileTap: () {
          context.router.push(const ProfileRoute());
        },
        onNotificationTap: () {
          context.router.push(const NotificationsRoute());
        },
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search,
              size: 64,
              color: DesignConstants.primaryBlue,
            ),
            const SizedBox(height: 16),
            Text(
              appLocalizations.search,
              style: const TextStyle(
                fontSize: DesignConstants.titleLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fonctionnalité à venir',
              style: TextStyle(
                fontSize: DesignConstants.bodyMedium,
                color: DesignConstants.darkGrey,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: VLBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}

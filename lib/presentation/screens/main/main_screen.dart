import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:venturelink/core/router/app_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@RoutePage()
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return AutoTabsScaffold(
      routes: const [
        HomeRoute(),
        DiscoverRoute(),
        InvestmentListRoute(),
        MessagingRoute(),
        NotificationsRoute(),
        ProfileRoute(),
      ],
      bottomNavigationBuilder: (_, tabsRouter) {
        return NavigationBar(
          selectedIndex: tabsRouter.activeIndex,
          onDestinationSelected: tabsRouter.setActiveIndex,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: appLocalizations.home,
            ),
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: const Icon(Icons.explore),
              label: appLocalizations.discover,
            ),
            const NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Investissements',
            ),
            NavigationDestination(
              icon: const Icon(Icons.message_outlined),
              selectedIcon: const Icon(Icons.message),
              label: appLocalizations.messages,
            ),
            const NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: appLocalizations.profile,
            ),
          ],
        );
      },
    );
  }
}

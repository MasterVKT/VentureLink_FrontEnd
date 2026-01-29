import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/constants/design_constants.dart';
import 'package:venturelink/data/providers/notification_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VLBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const VLBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final notificationProvider = Provider.of<NotificationProvider>(context);

    // Initialiser les notifications
    if (notificationProvider.notifications.isEmpty &&
        !notificationProvider.isLoading) {
      Future.microtask(() => notificationProvider.loadNotifications());
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: DesignConstants.white,
      selectedItemColor: DesignConstants.primaryBlue,
      unselectedItemColor: DesignConstants.darkGrey,
      elevation: 8,
      iconSize: 24,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      selectedLabelStyle: TextStyle(
        fontSize: DesignConstants.bodySmall,
        fontWeight: DesignConstants.medium,
        fontFamily: textTheme.bodyMedium?.fontFamily,
        height: 1.2,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: DesignConstants.bodySmall,
        fontWeight: DesignConstants.regular,
        fontFamily: textTheme.bodyMedium?.fontFamily,
        height: 1.2,
      ),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: appLocalizations.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.search),
          activeIcon: const Icon(Icons.search),
          label: appLocalizations.discover,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.add_circle_outline),
          activeIcon: const Icon(Icons.add_circle),
          label: appLocalizations.create,
        ),
        BottomNavigationBarItem(
          icon: notificationProvider.unreadCount > 0
              ? _buildBadgedIcon(Icons.notifications_outlined,
                  notificationProvider.unreadCount)
              : const Icon(Icons.notifications_outlined),
          activeIcon: notificationProvider.unreadCount > 0
              ? _buildBadgedIcon(
                  Icons.notifications, notificationProvider.unreadCount)
              : const Icon(Icons.notifications),
          label: appLocalizations.notifications,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: appLocalizations.profile,
        ),
      ],
    );
  }

  Widget _buildBadgedIcon(IconData icon, int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -6,
            top: -3,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: DesignConstants.errorRed,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Center(
                child: Text(
                  count > 9 ? '9+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

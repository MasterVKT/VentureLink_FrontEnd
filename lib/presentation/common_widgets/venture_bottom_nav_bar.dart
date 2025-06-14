import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class VentureBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<BottomNavigationBarItem> items;
  final ValueChanged<int> onTap;
  final bool showLabels;
  final Color? backgroundColor;
  final double elevation;

  const VentureBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.showLabels = true,
    this.backgroundColor,
    this.elevation = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.1),
            blurRadius: elevation,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        items: items,
        onTap: onTap,
        showSelectedLabels: showLabels,
        showUnselectedLabels: showLabels,
        type: BottomNavigationBarType.fixed,
        backgroundColor: backgroundColor ?? AppTheme.white,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: AppTheme.darkGrey,
        selectedLabelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
        unselectedLabelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.darkGrey,
            ),
        elevation: 0,
      ),
    );
  }
}

class VentureBottomNavBarItem extends BottomNavigationBarItem {
  const VentureBottomNavBarItem({
    required super.icon,
    required String super.label,
    Widget? activeIcon,
  }) : super(
          activeIcon: activeIcon ?? icon,
        );
}

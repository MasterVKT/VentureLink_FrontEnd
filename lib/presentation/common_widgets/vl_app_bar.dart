import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/constants/design_constants.dart';
import 'package:venturelink/core/theme/app_theme.dart';
import 'package:venturelink/data/providers/locale_provider.dart';

class VLAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool automaticallyImplyLeading;
  final bool showLogo;
  final bool centerTitle;
  final List<Widget>? actions;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final bool showLanguageButton;

  const VLAppBar({
    super.key,
    this.title,
    this.automaticallyImplyLeading = true,
    this.showLogo = false,
    this.centerTitle = false,
    this.actions,
    this.onProfileTap,
    this.onNotificationTap,
    this.showLanguageButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: AppBar(
          title: _buildTitle(context),
          centerTitle: centerTitle,
          automaticallyImplyLeading: automaticallyImplyLeading,
          backgroundColor: Colors.white,
          elevation: 0,
          actions: _buildActions(context),
          iconTheme: const IconThemeData(
            color: AppTheme.darkGrey,
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: DesignConstants.lightGrey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    if (showLogo) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [AppTheme.primaryBlue, Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(
              Icons.handshake_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'VentureLink',
            style: TextStyle(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      );
    } else if (title != null) {
      return Text(
        title!,
        style: const TextStyle(
          color: DesignConstants.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  List<Widget> _buildActions(BuildContext context) {
    final List<Widget> actionWidgets = [];

    // Bouton de langue
    if (showLanguageButton) {
      actionWidgets.add(
        _buildLanguageButton(context),
      );
    }

    // Bouton de notification
    if (onNotificationTap != null) {
      actionWidgets.add(
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            size: 24,
            color: DesignConstants.darkGrey,
          ),
          onPressed: onNotificationTap,
          tooltip: 'Notifications',
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(),
          splashRadius: 24,
        ),
      );
    }

    // Bouton de profil
    if (onProfileTap != null) {
      actionWidgets.add(
        IconButton(
          icon: const Icon(
            Icons.person_outline,
            size: 24,
            color: DesignConstants.darkGrey,
          ),
          onPressed: onProfileTap,
          tooltip: 'Profil',
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(),
          splashRadius: 24,
        ),
      );
    }

    // Autres actions
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    return actionWidgets;
  }

  Widget _buildLanguageButton(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale.languageCode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            localeProvider.toggleLocale();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentLocale.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: DesignConstants.darkGrey,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.language,
                  size: 16,
                  color: DesignConstants.darkGrey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

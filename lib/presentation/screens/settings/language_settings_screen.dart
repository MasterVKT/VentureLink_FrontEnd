import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/constants/design_constants.dart';
import 'package:venturelink/data/providers/locale_provider.dart';
import 'package:venturelink/l10n/app_localizations.dart';
import 'package:venturelink/presentation/common_widgets/vl_app_bar.dart';

/// Écran de sélection de la langue de l'application
///
/// Permet à l'utilisateur de changer la langue de l'application.
/// Les changements sont immédiatement appliqués et sauvegardés.
class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: VLAppBar(
        title: appLocalizations.language,
        automaticallyImplyLeading: true,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: DesignConstants.paddingMedium),

          // Explication du paramètre de langue
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignConstants.paddingLarge,
              vertical: DesignConstants.paddingMedium,
            ),
            child: Text(
              appLocalizations.languageDescription,
              style: const TextStyle(
                color: DesignConstants.darkGrey,
                fontSize: DesignConstants.bodyMedium,
              ),
            ),
          ),

          const Divider(),

          // Option français
          _buildLanguageOption(
            context: context,
            languageCode: 'fr',
            languageName: 'Français',
            localeProvider: localeProvider,
          ),

          const Divider(
              indent: DesignConstants.paddingLarge,
              endIndent: DesignConstants.paddingMedium),

          // Option anglais
          _buildLanguageOption(
            context: context,
            languageCode: 'en',
            languageName: 'English',
            localeProvider: localeProvider,
          ),
        ],
      ),
    );
  }

  /// Construit une option de langue avec son indicateur de sélection
  Widget _buildLanguageOption({
    required BuildContext context,
    required String languageCode,
    required String languageName,
    required LocaleProvider localeProvider,
  }) {
    final isSelected = localeProvider.isCurrentLanguage(languageCode);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: DesignConstants.paddingLarge,
        vertical: DesignConstants.paddingSmall,
      ),
      title: Text(
        languageName,
        style: TextStyle(
          fontSize: DesignConstants.bodyLarge,
          fontWeight:
              isSelected ? DesignConstants.semiBold : DesignConstants.regular,
          color:
              isSelected ? DesignConstants.primaryBlue : DesignConstants.black,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle,
              color: DesignConstants.primaryBlue, size: 24)
          : const Icon(Icons.circle_outlined,
              color: DesignConstants.mediumGrey, size: 24),
      onTap: () => localeProvider.setLocale(languageCode),
    );
  }
}

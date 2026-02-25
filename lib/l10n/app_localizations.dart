import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'VentureLink'**
  String get appTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur VentureLink'**
  String get welcomeMessage;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get login;

  /// No description provided for @register.
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get register;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginButton;

  /// No description provided for @createAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get createAccount;

  /// No description provided for @fullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPassword;

  /// No description provided for @registerButton.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get registerButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà un compte ?'**
  String get alreadyHaveAccount;

  /// No description provided for @home.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get home;

  /// No description provided for @discover.
  ///
  /// In fr, this message translates to:
  /// **'Découvrir'**
  String get discover;

  /// No description provided for @create.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get create;

  /// No description provided for @messages.
  ///
  /// In fr, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @profile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @projectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre du projet'**
  String get projectTitle;

  /// No description provided for @projectDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description du projet'**
  String get projectDescription;

  /// No description provided for @sector.
  ///
  /// In fr, this message translates to:
  /// **'Secteur'**
  String get sector;

  /// No description provided for @stage.
  ///
  /// In fr, this message translates to:
  /// **'Stade'**
  String get stage;

  /// No description provided for @fundingNeeded.
  ///
  /// In fr, this message translates to:
  /// **'Financement recherché'**
  String get fundingNeeded;

  /// No description provided for @partnersNeeded.
  ///
  /// In fr, this message translates to:
  /// **'Partenaires recherchés'**
  String get partnersNeeded;

  /// No description provided for @saveAsDraft.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer brouillon'**
  String get saveAsDraft;

  /// No description provided for @publishProject.
  ///
  /// In fr, this message translates to:
  /// **'Publier'**
  String get publishProject;

  /// No description provided for @editProfile.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get editProfile;

  /// No description provided for @myProjects.
  ///
  /// In fr, this message translates to:
  /// **'Mes projets'**
  String get myProjects;

  /// No description provided for @favorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get favorites;

  /// No description provided for @interests.
  ///
  /// In fr, this message translates to:
  /// **'Intérêts'**
  String get interests;

  /// No description provided for @activity.
  ///
  /// In fr, this message translates to:
  /// **'Activité'**
  String get activity;

  /// No description provided for @contactButton.
  ///
  /// In fr, this message translates to:
  /// **'Contacter'**
  String get contactButton;

  /// No description provided for @showInterest.
  ///
  /// In fr, this message translates to:
  /// **'Marquer l\'intérêt'**
  String get showInterest;

  /// No description provided for @addToFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter aux favoris'**
  String get addToFavorites;

  /// No description provided for @comments.
  ///
  /// In fr, this message translates to:
  /// **'Commentaires'**
  String get comments;

  /// No description provided for @writeComment.
  ///
  /// In fr, this message translates to:
  /// **'Écrire un commentaire'**
  String get writeComment;

  /// No description provided for @send.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get send;

  /// No description provided for @search.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get search;

  /// No description provided for @filters.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get filters;

  /// No description provided for @apply.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get reset;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @languageDescription.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez la langue de l\'application. Le changement sera appliqué immédiatement.'**
  String get languageDescription;

  /// No description provided for @theme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get theme;

  /// No description provided for @lightTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème clair'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème sombre'**
  String get darkTheme;

  /// No description provided for @privacySettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres de confidentialité'**
  String get privacySettings;

  /// No description provided for @notificationSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres de notification'**
  String get notificationSettings;

  /// No description provided for @changePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get changePassword;

  /// No description provided for @deleteAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte'**
  String get deleteAccount;

  /// No description provided for @help.
  ///
  /// In fr, this message translates to:
  /// **'Aide et support'**
  String get help;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logout;

  /// No description provided for @emailRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre email'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre mot de passe'**
  String get passwordRequired;

  /// No description provided for @nameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre nom'**
  String get nameRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get passwordsDoNotMatch;

  /// No description provided for @invalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir au moins 8 caractères'**
  String get passwordTooShort;

  /// No description provided for @projectTitleRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un titre pour votre projet'**
  String get projectTitleRequired;

  /// No description provided for @projectDescriptionRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer une description pour votre projet'**
  String get projectDescriptionRequired;

  /// No description provided for @sectorRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner un secteur d\'activité'**
  String get sectorRequired;

  /// No description provided for @stageRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner le stade de votre projet'**
  String get stageRequired;

  /// No description provided for @noProjects.
  ///
  /// In fr, this message translates to:
  /// **'Aucun projet trouvé'**
  String get noProjects;

  /// No description provided for @noMessages.
  ///
  /// In fr, this message translates to:
  /// **'Aucun message'**
  String get noMessages;

  /// No description provided for @noNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification'**
  String get noNotifications;

  /// No description provided for @startConversation.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer une conversation'**
  String get startConversation;

  /// No description provided for @typeMessage.
  ///
  /// In fr, this message translates to:
  /// **'Tapez votre message...'**
  String get typeMessage;

  /// No description provided for @premium.
  ///
  /// In fr, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @upgrade.
  ///
  /// In fr, this message translates to:
  /// **'Passer à Premium'**
  String get upgrade;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @viewAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get viewAll;

  /// No description provided for @readMore.
  ///
  /// In fr, this message translates to:
  /// **'Lire plus'**
  String get readMore;

  /// No description provided for @showLess.
  ///
  /// In fr, this message translates to:
  /// **'Voir moins'**
  String get showLess;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @success.
  ///
  /// In fr, this message translates to:
  /// **'Succès'**
  String get success;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @areYouSure.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr ?'**
  String get areYouSure;

  /// No description provided for @thisActionCannot.
  ///
  /// In fr, this message translates to:
  /// **'Cette action ne peut pas être annulée'**
  String get thisActionCannot;

  /// No description provided for @featuredProjects.
  ///
  /// In fr, this message translates to:
  /// **'Projets en vedette'**
  String get featuredProjects;

  /// No description provided for @recentProjects.
  ///
  /// In fr, this message translates to:
  /// **'Projets récents'**
  String get recentProjects;

  /// No description provided for @interestShown.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez exprimé votre intérêt pour ce projet'**
  String get interestShown;

  /// No description provided for @addedToFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Projet ajouté aux favoris'**
  String get addedToFavorites;

  /// No description provided for @mainMenu.
  ///
  /// In fr, this message translates to:
  /// **'Menu principal'**
  String get mainMenu;

  /// No description provided for @aboutMe.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get aboutMe;

  /// No description provided for @expertise.
  ///
  /// In fr, this message translates to:
  /// **'Domaines d\'expertise'**
  String get expertise;

  /// No description provided for @professionalExperience.
  ///
  /// In fr, this message translates to:
  /// **'Expérience professionnelle'**
  String get professionalExperience;

  /// No description provided for @education.
  ///
  /// In fr, this message translates to:
  /// **'Formation'**
  String get education;

  /// No description provided for @present.
  ///
  /// In fr, this message translates to:
  /// **'Présent'**
  String get present;

  /// No description provided for @reviews.
  ///
  /// In fr, this message translates to:
  /// **'avis'**
  String get reviews;

  /// No description provided for @projectTags.
  ///
  /// In fr, this message translates to:
  /// **'Tags'**
  String get projectTags;

  /// No description provided for @viewsCount.
  ///
  /// In fr, this message translates to:
  /// **'vues'**
  String get viewsCount;

  /// No description provided for @likesCount.
  ///
  /// In fr, this message translates to:
  /// **'j\'aime'**
  String get likesCount;

  /// No description provided for @commentsCount.
  ///
  /// In fr, this message translates to:
  /// **'commentaires'**
  String get commentsCount;

  /// No description provided for @projectDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détails du projet'**
  String get projectDetails;

  /// No description provided for @fundingAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant du financement'**
  String get fundingAmount;

  /// No description provided for @duration.
  ///
  /// In fr, this message translates to:
  /// **'Durée'**
  String get duration;

  /// No description provided for @location.
  ///
  /// In fr, this message translates to:
  /// **'Localisation'**
  String get location;

  /// No description provided for @createdBy.
  ///
  /// In fr, this message translates to:
  /// **'Créé par'**
  String get createdBy;

  /// No description provided for @similarProjects.
  ///
  /// In fr, this message translates to:
  /// **'Projets similaires'**
  String get similarProjects;

  /// No description provided for @projectActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions'**
  String get projectActions;

  /// No description provided for @markAllAsRead.
  ///
  /// In fr, this message translates to:
  /// **'Tout marquer comme lu'**
  String get markAllAsRead;

  /// No description provided for @noNotificationsDescription.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas de notifications pour le moment.'**
  String get noNotificationsDescription;

  /// No description provided for @returnHome.
  ///
  /// In fr, this message translates to:
  /// **'Retour à l\'accueil'**
  String get returnHome;

  /// No description provided for @xDaysAgo.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {days} jour(s)'**
  String xDaysAgo(String days);

  /// No description provided for @xHoursAgo.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {hours} heure(s)'**
  String xHoursAgo(String hours);

  /// No description provided for @xMinutesAgo.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {minutes} minute(s)'**
  String xMinutesAgo(String minutes);

  /// No description provided for @justNow.
  ///
  /// In fr, this message translates to:
  /// **'À l\'instant'**
  String get justNow;

  /// No description provided for @allNotificationsRead.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les notifications ont été marquées comme lues'**
  String get allNotificationsRead;

  /// No description provided for @projectDetail.
  ///
  /// In fr, this message translates to:
  /// **'Détail du projet'**
  String get projectDetail;

  /// No description provided for @projectCreator.
  ///
  /// In fr, this message translates to:
  /// **'Porteur de projet'**
  String get projectCreator;

  /// No description provided for @contact.
  ///
  /// In fr, this message translates to:
  /// **'Contacter'**
  String get contact;

  /// No description provided for @views.
  ///
  /// In fr, this message translates to:
  /// **'Vues'**
  String get views;

  /// No description provided for @interested.
  ///
  /// In fr, this message translates to:
  /// **'Intéressé'**
  String get interested;

  /// No description provided for @projectInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations du projet'**
  String get projectInfo;

  /// No description provided for @creationDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de création'**
  String get creationDate;

  /// No description provided for @description.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @partnersAndSkills.
  ///
  /// In fr, this message translates to:
  /// **'Partenaires et compétences recherchés'**
  String get partnersAndSkills;

  /// No description provided for @partnerTypes.
  ///
  /// In fr, this message translates to:
  /// **'Types de partenaires'**
  String get partnerTypes;

  /// No description provided for @requiredSkills.
  ///
  /// In fr, this message translates to:
  /// **'Compétences recherchées'**
  String get requiredSkills;

  /// No description provided for @tags.
  ///
  /// In fr, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @actions.
  ///
  /// In fr, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @favorite.
  ///
  /// In fr, this message translates to:
  /// **'Favori'**
  String get favorite;

  /// No description provided for @commentPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un commentaire...'**
  String get commentPlaceholder;

  /// No description provided for @publish.
  ///
  /// In fr, this message translates to:
  /// **'Publier'**
  String get publish;

  /// No description provided for @noComments.
  ///
  /// In fr, this message translates to:
  /// **'Aucun commentaire pour le moment'**
  String get noComments;

  /// No description provided for @projectInterestShown.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez exprimé votre intérêt pour ce projet'**
  String get projectInterestShown;

  /// No description provided for @projectInterestRemoved.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez retiré votre intérêt pour ce projet'**
  String get projectInterestRemoved;

  /// No description provided for @projectAddedToFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Projet ajouté aux favoris'**
  String get projectAddedToFavorites;

  /// No description provided for @projectRemovedFromFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Projet retiré des favoris'**
  String get projectRemovedFromFavorites;

  /// No description provided for @ideaStage.
  ///
  /// In fr, this message translates to:
  /// **'Idée'**
  String get ideaStage;

  /// No description provided for @prototypeStage.
  ///
  /// In fr, this message translates to:
  /// **'Prototype'**
  String get prototypeStage;

  /// No description provided for @developmentStage.
  ///
  /// In fr, this message translates to:
  /// **'Développement'**
  String get developmentStage;

  /// No description provided for @growthStage.
  ///
  /// In fr, this message translates to:
  /// **'Croissance'**
  String get growthStage;

  /// No description provided for @investorPartner.
  ///
  /// In fr, this message translates to:
  /// **'Investisseur'**
  String get investorPartner;

  /// No description provided for @associatePartner.
  ///
  /// In fr, this message translates to:
  /// **'Associé'**
  String get associatePartner;

  /// No description provided for @mentorPartner.
  ///
  /// In fr, this message translates to:
  /// **'Mentor'**
  String get mentorPartner;

  /// No description provided for @welcomeToApp.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur\n{appName}'**
  String welcomeToApp(String appName);

  /// No description provided for @emailHint.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre email'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre mot de passe'**
  String get passwordHint;

  /// No description provided for @rememberMe.
  ///
  /// In fr, this message translates to:
  /// **'Se souvenir de moi'**
  String get rememberMe;

  /// No description provided for @loginButtonText.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginButtonText;

  /// No description provided for @continueWith.
  ///
  /// In fr, this message translates to:
  /// **'Ou continuer avec'**
  String get continueWith;

  /// No description provided for @googleLogin.
  ///
  /// In fr, this message translates to:
  /// **'Google'**
  String get googleLogin;

  /// No description provided for @appleLogin.
  ///
  /// In fr, this message translates to:
  /// **'Apple'**
  String get appleLogin;

  /// No description provided for @passwordVisibility.
  ///
  /// In fr, this message translates to:
  /// **'Afficher/masquer le mot de passe'**
  String get passwordVisibility;

  /// No description provided for @enterEmail.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre email'**
  String get enterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un email valide'**
  String get enterValidEmail;

  /// No description provided for @enterPassword.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre mot de passe'**
  String get enterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir au moins {length} caractères'**
  String passwordMinLength(int length);

  /// No description provided for @registration.
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get registration;

  /// No description provided for @createYourAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre compte'**
  String get createYourAccount;

  /// No description provided for @joinCommunity.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez la communauté VentureLink'**
  String get joinCommunity;

  /// No description provided for @firstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get lastName;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPasswordLabel;

  /// No description provided for @enterFirstName.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre prénom'**
  String get enterFirstName;

  /// No description provided for @enterLastName.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre nom'**
  String get enterLastName;

  /// No description provided for @enterConfirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez confirmer votre mot de passe'**
  String get enterConfirmPassword;

  /// No description provided for @agreeToTerms.
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte les '**
  String get agreeToTerms;

  /// No description provided for @termsOfUse.
  ///
  /// In fr, this message translates to:
  /// **'conditions d\'utilisation'**
  String get termsOfUse;

  /// No description provided for @and.
  ///
  /// In fr, this message translates to:
  /// **' et la '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'politique de confidentialité'**
  String get privacyPolicy;

  /// No description provided for @or.
  ///
  /// In fr, this message translates to:
  /// **'ou'**
  String get or;

  /// No description provided for @signUpWithGoogle.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire avec Google'**
  String get signUpWithGoogle;

  /// No description provided for @signUpWithApple.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire avec Apple'**
  String get signUpWithApple;

  /// No description provided for @newProject.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau'**
  String get newProject;

  /// No description provided for @notifNewInterest.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel intérêt'**
  String get notifNewInterest;

  /// No description provided for @notifNewMessage.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau message'**
  String get notifNewMessage;

  /// No description provided for @notifNewComment.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau commentaire'**
  String get notifNewComment;

  /// No description provided for @notifSystemUpdate.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour du système'**
  String get notifSystemUpdate;

  /// No description provided for @notifInterestMessage.
  ///
  /// In fr, this message translates to:
  /// **'{userName} a exprimé son intérêt pour votre projet \"{projectName}\"'**
  String notifInterestMessage(String userName, String projectName);

  /// No description provided for @notifMessageReceived.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez reçu un nouveau message de {userName}'**
  String notifMessageReceived(String userName);

  /// No description provided for @notifCommentMessage.
  ///
  /// In fr, this message translates to:
  /// **'{userName} a commenté votre projet \"{projectName}\"'**
  String notifCommentMessage(String userName, String projectName);

  /// No description provided for @notifSystemUpdateMessage.
  ///
  /// In fr, this message translates to:
  /// **'Découvrez les nouvelles fonctionnalités de VentureLink dans notre dernière mise à jour !'**
  String get notifSystemUpdateMessage;

  /// No description provided for @deleteNotification.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la notification'**
  String get deleteNotification;

  /// No description provided for @markAllRead.
  ///
  /// In fr, this message translates to:
  /// **'Tout marquer comme lu'**
  String get markAllRead;

  /// No description provided for @clearAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout effacer'**
  String get clearAll;

  /// No description provided for @all.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get all;

  /// No description provided for @unread.
  ///
  /// In fr, this message translates to:
  /// **'Non lus'**
  String get unread;

  /// No description provided for @errorLoadingNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement des notifications'**
  String get errorLoadingNotifications;

  /// No description provided for @noUnreadNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification non lue'**
  String get noUnreadNotifications;

  /// No description provided for @searchNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher dans les notifications'**
  String get searchNotifications;

  /// No description provided for @investments.
  ///
  /// In fr, this message translates to:
  /// **'Investissements'**
  String get investments;

  /// No description provided for @projects.
  ///
  /// In fr, this message translates to:
  /// **'Projets'**
  String get projects;

  /// No description provided for @system.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get system;

  /// No description provided for @sort.
  ///
  /// In fr, this message translates to:
  /// **'Trier'**
  String get sort;

  /// No description provided for @sortBy.
  ///
  /// In fr, this message translates to:
  /// **'Trier par'**
  String get sortBy;

  /// No description provided for @newest.
  ///
  /// In fr, this message translates to:
  /// **'Plus récents'**
  String get newest;

  /// No description provided for @oldest.
  ///
  /// In fr, this message translates to:
  /// **'Plus anciens'**
  String get oldest;

  /// No description provided for @important.
  ///
  /// In fr, this message translates to:
  /// **'Important'**
  String get important;

  /// No description provided for @clearAllNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Effacer toutes les notifications'**
  String get clearAllNotifications;

  /// No description provided for @clearAllNotificationsConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir supprimer toutes les notifications ? Cette action est irréversible.'**
  String get clearAllNotificationsConfirm;

  /// No description provided for @clear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get clear;

  /// No description provided for @deliveryChannels.
  ///
  /// In fr, this message translates to:
  /// **'Canaux de notification'**
  String get deliveryChannels;

  /// No description provided for @pushNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications push'**
  String get pushNotifications;

  /// No description provided for @emailNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications par email'**
  String get emailNotifications;

  /// No description provided for @notificationTypes.
  ///
  /// In fr, this message translates to:
  /// **'Types de notifications'**
  String get notificationTypes;

  /// No description provided for @projectUpdates.
  ///
  /// In fr, this message translates to:
  /// **'Mises à jour de projets'**
  String get projectUpdates;

  /// No description provided for @systemNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications système'**
  String get systemNotifications;

  /// No description provided for @settingsSaved.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres enregistrés'**
  String get settingsSaved;

  /// No description provided for @markAsRead.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme lu'**
  String get markAsRead;

  /// No description provided for @minutesAgo.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {minutes} min'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {hours}h'**
  String hoursAgo(int hours);

  /// No description provided for @daysAgo.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {days} jours'**
  String daysAgo(int days);

  /// No description provided for @yesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get yesterday;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

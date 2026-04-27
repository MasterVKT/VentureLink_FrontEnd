import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venturelink/core/config/config_service.dart';
import 'package:venturelink/core/di/service_locator.dart';
import 'package:venturelink/core/localization/localization_service.dart';
import 'package:venturelink/core/navigation/navigation_service.dart';
import 'package:venturelink/core/router/app_router.dart';
import 'package:venturelink/core/theme/app_theme.dart';
import 'package:venturelink/core/utils/logger.dart';
import 'package:venturelink/data/providers/content_provider.dart';
import 'package:venturelink/data/providers/auth_provider.dart';
import 'package:venturelink/data/providers/notification_provider.dart';
import 'package:venturelink/data/providers/subscription_provider.dart';
import 'package:venturelink/data/providers/simple_subscription_provider.dart';
import 'package:venturelink/data/providers/theme_provider.dart';

import 'package:venturelink/data/providers/locale_provider.dart';
import 'package:venturelink/services/firebase_check_service.dart';
import 'package:venturelink/services/firebase_crashlytics_service.dart';
import 'package:venturelink/data/providers/project_provider.dart';
import 'package:venturelink/data/providers/messaging_provider.dart';
import 'package:venturelink/data/providers/investment_provider.dart';
import 'package:venturelink/data/providers/profile_provider.dart';
import 'package:venturelink/data/providers/matching_provider.dart';
import 'package:venturelink/data/providers/user_stats_provider.dart';
import 'package:venturelink/data/providers/discover_provider.dart';
import 'package:venturelink/data/services/api_service.dart';
import 'package:venturelink/data/services/auth_service.dart';
import 'package:venturelink/data/services/messaging_api_service.dart';
import 'package:venturelink/data/services/websocket_service.dart';
import 'package:venturelink/data/services/discover_api_service.dart';
import 'package:venturelink/domain/services/i_api_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Handler pour les messages en arrière-plan
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Assurer que Firebase est initialisé avant de traiter le message
  await Firebase.initializeApp();
  // Initialiser le logger pour les messages en arrière-plan
  AppLogger.init();
  AppLogger.info("Notification reçue en arrière-plan: ${message.messageId}");
}

void main() async {
  // Initialiser le service de logging en premier
  AppLogger.init();

  // Capturer les erreurs non gérées
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    AppLogger.error(
        'FlutterError: ${details.exception}', details.exception, details.stack);
  };

  WidgetsFlutterBinding.ensureInitialized();

  // Forcer l'orientation portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurer Firebase Messaging pour les messages en arrière-plan
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialiser Firebase avec le service de vérification
  try {
    await FirebaseCheckService.ensureFirebaseInitialized();
    await FirebaseCheckService.validateAuthentication();

    // Initialiser Crashlytics pour le monitoring des crashes
    await FirebaseCrashlyticsService().initialize();
    AppLogger.info('Firebase initialisé avec succès');
  } catch (e) {
    AppLogger.error('Erreur lors de l\'initialisation de Firebase: $e');
    // Continuer l'exécution même en cas d'erreur Firebase
  }

  // Initialiser les services
  await setupServiceLocator();

  // S'assurer que l'AuthProvider est bien initialisé avant utilisation
  final authProvider = serviceLocator<AuthProvider>();

  final prefs = await SharedPreferences.getInstance();
  final localizationService = LocalizationService(prefs);
  final navigationService = NavigationService();
  final appRouter = AppRouter();

  // Initialiser les services API
  final apiService = ApiService();
  final authService = AuthService();
  final messagingApiService = MessagingApiService(apiService);
  final webSocketService = WebSocketService(authService);

  // S'assurer que tous les services sont initialisés
  AppLogger.info('Tous les services sont initialisés');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(
          create: (_) => serviceLocator<ThemeProvider>(),
        ),
        ChangeNotifierProvider.value(
          value: authProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProjectProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MessagingProvider(
            messagingApiService,
            webSocketService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => InvestmentProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => serviceLocator<ProfileProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => serviceLocator<SubscriptionProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => serviceLocator<SimpleSubscriptionProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => serviceLocator<MatchingProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => serviceLocator<UserStatsProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => ContentProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DiscoverProvider(DiscoverApiService(apiService as IApiService)),
        ),
      ],
      child: MyApp(
        localizationService: localizationService,
        navigationService: navigationService,
        appRouter: appRouter,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final LocalizationService localizationService;
  final NavigationService navigationService;
  final AppRouter appRouter;

  const MyApp({
    super.key,
    required this.localizationService,
    required this.navigationService,
    required this.appRouter,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp.router(
          title: ConfigService.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          routerDelegate: appRouter.delegate(),
          routeInformationParser: appRouter.defaultRouteParser(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('fr'), Locale('en')],
          locale: localeProvider.locale,
          localeResolutionCallback:
              localizationService.localeResolutionCallback,
        );
      },
    );
  }
}

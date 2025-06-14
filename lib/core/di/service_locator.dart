import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:venturelink/data/providers/theme_provider.dart';

import '../router/app_router.dart';
import 'package:venturelink/data/providers/auth_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/api_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/base_api_service.dart';
import '../../data/services/subscription_api_service.dart';
import '../../data/services/user_api_service.dart';
import '../../data/services/payment_api_service.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../data/providers/subscription_provider.dart';
import '../../data/providers/profile_provider.dart';
import '../../data/providers/payment_provider.dart';
import '../../data/providers/matching_provider.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/services/i_api_service.dart';
import '../../domain/services/i_storage_service.dart';
import '../../data/services/user_preferences_service.dart';
import 'package:venturelink/data/providers/analytics_provider.dart';
import 'package:venturelink/data/services/analytics_api_service.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Services
  final prefs = await SharedPreferences.getInstance();
  serviceLocator.registerSingleton<SharedPreferences>(prefs);

  serviceLocator.registerLazySingleton<IStorageService>(
    () => StorageService(
      serviceLocator<SharedPreferences>(),
      const FlutterSecureStorage(),
    ),
  );

  serviceLocator.registerLazySingleton<IApiService>(
    () => ApiService(),
  );

  // Enregistrer l'instance Dio
  serviceLocator.registerLazySingleton<Dio>(
    () => BaseApiService.createDio(),
  );

  // Services API avec Retrofit
  serviceLocator.registerLazySingleton<SubscriptionApiService>(
    () => SubscriptionApiService(serviceLocator<Dio>()),
  );

  serviceLocator.registerLazySingleton<UserApiService>(
    () => UserApiService(serviceLocator<Dio>()),
  );

  serviceLocator.registerLazySingleton<PaymentApiService>(
    () => PaymentApiService(serviceLocator<Dio>()),
  );

  serviceLocator.registerLazySingleton<UserPreferencesService>(
    () => UserPreferencesService(serviceLocator<SharedPreferences>()),
  );

  serviceLocator.registerLazySingleton(
      () => AnalyticsApiService(serviceLocator<ApiService>()));

  // Repositories
  serviceLocator.registerLazySingleton<IAuthRepository>(
    () => AuthRepository(
      apiService: serviceLocator<IApiService>(),
      storageService: serviceLocator<IStorageService>(),
    ),
  );

  // Repository pour les abonnements
  serviceLocator.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepository(
      subscriptionService: serviceLocator<SubscriptionApiService>(),
      paymentService: serviceLocator<PaymentApiService>(),
      prefs: serviceLocator<SharedPreferences>(),
    ),
  );

  // Providers
  serviceLocator.registerLazySingleton<AuthProvider>(
    () => AuthProvider(),
  );

  serviceLocator.registerFactory<ThemeProvider>(
    () => ThemeProvider(),
  );

  serviceLocator.registerFactory<SubscriptionProvider>(
    () => SubscriptionProvider(
      repository: serviceLocator<SubscriptionRepository>(),
    ),
  );

  serviceLocator.registerFactory<ProfileProvider>(
    () => ProfileProvider(serviceLocator<UserApiService>()),
  );

  serviceLocator.registerFactory<PaymentProvider>(
    () => PaymentProvider(serviceLocator<PaymentApiService>()),
  );

  serviceLocator.registerFactory<MatchingProvider>(
    () => MatchingProvider(serviceLocator<IApiService>()),
  );

  serviceLocator.registerLazySingleton(
      () => AnalyticsProvider(serviceLocator<AnalyticsApiService>()));

  // Router
  serviceLocator.registerSingleton<AppRouter>(
    AppRouter(),
  );
}

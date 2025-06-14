# 🚀 **PLAN D'IMPLÉMENTATION FRONTEND FLUTTER PHASE 5 - VERSION FINALE**

> **ÉTAT :** Plan complet basé sur le backend 100% harmonisé et fonctionnel
> **DERNIÈRE MISE À JOUR :** Après harmonisation complète des modèles paiements/abonnements

---

## **📋 APERÇU GÉNÉRAL**

Ce plan d'implémentation présente la roadmap complète pour développer le frontend Flutter VentureLink Phase 5 en parfaite harmonie avec le backend Django REST API 100% fonctionnel.

### **🎯 Objectifs**

- ✅ **Intégration complète** avec le backend harmonisé
- ✅ **Interface utilisateur moderne** et intuitive
- ✅ **Paiements My-CoolPay** intégrés
- ✅ **Multi-devises** (EUR, XAF, USD)
- ✅ **Notifications FCM** temps réel
- ✅ **Messagerie WebSocket** instantanée
- ✅ **Matching IA** intelligent

---

## **🏗️ ARCHITECTURE FRONTEND**

### **📱 Stack Technique**

```
Flutter 3.16+ / Dart 3.2+
├── 🎨 UI/UX: Material Design 3
├── 🔄 État: Provider + ChangeNotifier
├── 🌐 API: Dio + Retrofit
├── 💾 Cache: Hive + SharedPreferences
├── 🔔 Notifications: Firebase Messaging
├── 💬 WebSocket: web_socket_channel
├── 🎯 Navigation: GoRouter
├── 🌍 I18n: flutter_localizations
└── 🧪 Tests: flutter_test + mockito
```

### **📁 Structure Projet**

```
lib/
├── config/
│   ├── app_config.dart              # Configuration globale
│   ├── api_endpoints.dart           # URLs API backend
│   ├── constants.dart               # Constantes app
│   ├── theme.dart                   # Thème Material Design 3
│   └── routes.dart                  # Configuration GoRouter
├── core/
│   ├── errors/                      # Gestion erreurs
│   ├── network/                     # Configuration réseau
│   ├── utils/                       # Utilitaires
│   └── validators/                  # Validateurs formulaires
├── data/
│   ├── models/                      # Modèles de données
│   ├── repositories/                # Repositories pattern
│   ├── services/                    # Services API
│   └── local/                       # Stockage local
├── domain/
│   ├── entities/                    # Entités métier
│   ├── repositories/                # Interfaces repositories
│   └── usecases/                    # Cas d'usage
├── presentation/
│   ├── providers/                   # Providers état
│   ├── screens/                     # Écrans application
│   ├── widgets/                     # Widgets réutilisables
│   └── common/                      # Composants communs
└── main.dart                        # Point d'entrée
```

---

## **📊 MODÈLES DE DONNÉES FLUTTER**

### **👤 Modèle Utilisateur**

```dart
// lib/data/models/user_model.dart
class UserModel {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final UserType userType;
  final bool isPremium;
  final String preferredCurrency;
  final String preferredLanguage;
  final String? phoneNumber;
  final String? avatar;
  final String? bio;
  final String? location;
  final String? website;
  final String? linkedin;
  final DateTime dateJoined;
  final DateTime lastActive;
  final UserSubscriptionModel? subscription;
  final UserStatsModel? stats;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.userType,
    required this.isPremium,
    required this.preferredCurrency,
    required this.preferredLanguage,
    this.phoneNumber,
    this.avatar,
    this.bio,
    this.location,
    this.website,
    this.linkedin,
    required this.dateJoined,
    required this.lastActive,
    this.subscription,
    this.stats,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      userType: UserType.values.firstWhere(
        (e) => e.name == json['user_type'],
      ),
      isPremium: json['is_premium'],
      preferredCurrency: json['preferred_currency'],
      preferredLanguage: json['preferred_language'],
      phoneNumber: json['phone_number'],
      avatar: json['avatar'],
      bio: json['bio'],
      location: json['location'],
      website: json['website'],
      linkedin: json['linkedin'],
      dateJoined: DateTime.parse(json['date_joined']),
      lastActive: DateTime.parse(json['last_active']),
      subscription: json['subscription'] != null
          ? UserSubscriptionModel.fromJson(json['subscription'])
          : null,
      stats: json['stats'] != null
          ? UserStatsModel.fromJson(json['stats'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'user_type': userType.name,
      'is_premium': isPremium,
      'preferred_currency': preferredCurrency,
      'preferred_language': preferredLanguage,
      'phone_number': phoneNumber,
      'avatar': avatar,
      'bio': bio,
      'location': location,
      'website': website,
      'linkedin': linkedin,
      'date_joined': dateJoined.toIso8601String(),
      'last_active': lastActive.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
  
  String get displayName => fullName.trim().isEmpty ? username : fullName;
}

enum UserType { ENTREPRENEUR, INVESTOR, BOTH }

class UserStatsModel {
  final int projectsCount;
  final int investmentsCount;
  final int messagesCount;

  const UserStatsModel({
    required this.projectsCount,
    required this.investmentsCount,
    required this.messagesCount,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      projectsCount: json['projects_count'],
      investmentsCount: json['investments_count'],
      messagesCount: json['messages_count'],
    );
  }
}
```

### **💳 Modèle Plan d'Abonnement**

```dart
// lib/data/models/subscription_plan_model.dart
class SubscriptionPlanModel {
  final String id;
  final String name;
  final String description;
  final double priceEur;
  final double priceXaf;
  final double priceUsd;
  final String formattedPriceEur;
  final String formattedPriceXaf;
  final String formattedPriceUsd;
  final int durationDays;
  final int durationMonths;
  final List<String> features;
  final int maxProjects;
  final int maxInvestments;
  final int maxMessages;
  final bool isUnlimitedProjects;
  final bool isUnlimitedInvestments;
  final bool isUnlimitedMessages;
  final bool aiMatching;
  final bool prioritySupport;
  final bool advancedAnalytics;
  final bool customBranding;
  final bool isActive;
  final bool isPopular;
  final bool isFree;
  final int trialDays;
  final int sortOrder;

  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.priceEur,
    required this.priceXaf,
    required this.priceUsd,
    required this.formattedPriceEur,
    required this.formattedPriceXaf,
    required this.formattedPriceUsd,
    required this.durationDays,
    required this.durationMonths,
    required this.features,
    required this.maxProjects,
    required this.maxInvestments,
    required this.maxMessages,
    required this.isUnlimitedProjects,
    required this.isUnlimitedInvestments,
    required this.isUnlimitedMessages,
    required this.aiMatching,
    required this.prioritySupport,
    required this.advancedAnalytics,
    required this.customBranding,
    required this.isActive,
    required this.isPopular,
    required this.isFree,
    required this.trialDays,
    required this.sortOrder,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      priceEur: double.parse(json['price_eur']),
      priceXaf: double.parse(json['price_xaf']),
      priceUsd: double.parse(json['price_usd']),
      formattedPriceEur: json['formatted_price_eur'],
      formattedPriceXaf: json['formatted_price_xaf'],
      formattedPriceUsd: json['formatted_price_usd'],
      durationDays: json['duration_days'],
      durationMonths: json['duration_months'],
      features: List<String>.from(json['features']),
      maxProjects: json['max_projects'],
      maxInvestments: json['max_investments'],
      maxMessages: json['max_messages'],
      isUnlimitedProjects: json['is_unlimited_projects'],
      isUnlimitedInvestments: json['is_unlimited_investments'],
      isUnlimitedMessages: json['is_unlimited_messages'],
      aiMatching: json['ai_matching'],
      prioritySupport: json['priority_support'],
      advancedAnalytics: json['advanced_analytics'],
      customBranding: json['custom_branding'],
      isActive: json['is_active'],
      isPopular: json['is_popular'],
      isFree: json['is_free'],
      trialDays: json['trial_days'],
      sortOrder: json['sort_order'],
    );
  }

  String getFormattedPrice(String currency) {
    switch (currency.toUpperCase()) {
      case 'EUR':
        return formattedPriceEur;
      case 'XAF':
        return formattedPriceXaf;
      case 'USD':
        return formattedPriceUsd;
      default:
        return formattedPriceEur;
    }
  }

  double getPriceForCurrency(String currency) {
    switch (currency.toUpperCase()) {
      case 'EUR':
        return priceEur;
      case 'XAF':
        return priceXaf;
      case 'USD':
        return priceUsd;
      default:
        return priceEur;
    }
  }

  bool get isYearly => durationDays >= 365;
  bool get isMonthly => durationDays <= 31;
}
```

### **📅 Modèle Abonnement Utilisateur**

```dart
// lib/data/models/user_subscription_model.dart
class UserSubscriptionModel {
  final String id;
  final String userId;
  final SubscriptionPlanModel plan;
  final SubscriptionStatus status;
  final String statusDisplay;
  final DateTime startedAt;
  final DateTime expiresAt;
  final DateTime? trialEndsAt;
  final DateTime? cancelledAt;
  final DateTime? suspendedAt;
  final bool autoRenew;
  final DateTime? nextBillingDate;
  final String billingCurrency;
  final DateTime? lastPaymentDate;
  final double? lastPaymentAmount;
  final bool isActive;
  final bool isInTrial;
  final bool isExpired;
  final int daysRemaining;
  final int trialDaysRemaining;
  final String currentPeriodPrice;
  final String formattedCurrentPrice;

  const UserSubscriptionModel({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    required this.statusDisplay,
    required this.startedAt,
    required this.expiresAt,
    this.trialEndsAt,
    this.cancelledAt,
    this.suspendedAt,
    required this.autoRenew,
    this.nextBillingDate,
    required this.billingCurrency,
    this.lastPaymentDate,
    this.lastPaymentAmount,
    required this.isActive,
    required this.isInTrial,
    required this.isExpired,
    required this.daysRemaining,
    required this.trialDaysRemaining,
    required this.currentPeriodPrice,
    required this.formattedCurrentPrice,
  });

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionModel(
      id: json['id'],
      userId: json['user'],
      plan: SubscriptionPlanModel.fromJson(json['plan']),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      statusDisplay: json['status_display'],
      startedAt: DateTime.parse(json['started_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      trialEndsAt: json['trial_ends_at'] != null
          ? DateTime.parse(json['trial_ends_at'])
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      suspendedAt: json['suspended_at'] != null
          ? DateTime.parse(json['suspended_at'])
          : null,
      autoRenew: json['auto_renew'],
      nextBillingDate: json['next_billing_date'] != null
          ? DateTime.parse(json['next_billing_date'])
          : null,
      billingCurrency: json['billing_currency'],
      lastPaymentDate: json['last_payment_date'] != null
          ? DateTime.parse(json['last_payment_date'])
          : null,
      lastPaymentAmount: json['last_payment_amount'] != null
          ? double.parse(json['last_payment_amount'])
          : null,
      isActive: json['is_active'],
      isInTrial: json['is_in_trial'],
      isExpired: json['is_expired'],
      daysRemaining: json['days_remaining'],
      trialDaysRemaining: json['trial_days_remaining'],
      currentPeriodPrice: json['current_period_price'],
      formattedCurrentPrice: json['formatted_current_price'],
    );
  }
}

enum SubscriptionStatus {
  ACTIVE,
  PENDING,
  EXPIRED,
  CANCELLED,
  TRIAL,
  SUSPENDED,
}
```

### **💰 Modèle Paiement**

```dart
// lib/data/models/payment_model.dart
class PaymentModel {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final String description;
  final PaymentType paymentType;
  final PaymentStatus status;
  final String paymentMethod;
  final String? externalReference;
  final String? externalCheckoutUrl;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isTest;

  const PaymentModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.description,
    required this.paymentType,
    required this.status,
    required this.paymentMethod,
    this.externalReference,
    this.externalCheckoutUrl,
    required this.createdAt,
    this.completedAt,
    required this.isTest,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      userId: json['user'],
      amount: double.parse(json['amount']),
      currency: json['currency'],
      description: json['description'],
      paymentType: PaymentType.values.firstWhere(
        (e) => e.name == json['payment_type'],
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      paymentMethod: json['payment_method'],
      externalReference: json['external_reference'],
      externalCheckoutUrl: json['external_checkout_url'],
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      isTest: json['is_test'],
    );
  }
}

enum PaymentType { SUBSCRIPTION, ONE_TIME, REFUND }

enum PaymentStatus {
  PENDING,
  PROCESSING,
  COMPLETED,
  FAILED,
  CANCELLED,
  REFUNDED,
}
```

---

## **🔧 SERVICES ET REPOSITORIES**

### **🌐 Service API Principal**

```dart
// lib/data/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // Authentification
  @POST('/api/v1/auth/register/')
  Future<AuthResponse> register(@Body() RegisterRequest request);

  @POST('/api/v1/auth/login/')
  Future<AuthResponse> login(@Body() LoginRequest request);

  @POST('/api/v1/auth/firebase/')
  Future<AuthResponse> firebaseAuth(@Body() FirebaseAuthRequest request);

  @POST('/api/v1/auth/refresh/')
  Future<TokenResponse> refreshToken(@Body() RefreshTokenRequest request);

  // Plans d'abonnement
  @GET('/api/v1/payments/plans/')
  Future<PaginatedResponse<SubscriptionPlanModel>> getPlans();

  // Abonnement utilisateur
  @GET('/api/v1/payments/subscription/')
  Future<UserSubscriptionModel> getCurrentSubscription();

  @POST('/api/v1/payments/subscription/')
  Future<PaymentResponse> createSubscriptionPayment(
    @Body() CreateSubscriptionPaymentRequest request,
  );

  @POST('/api/v1/payments/subscription/cancel/')
  Future<void> cancelSubscription(@Body() CancelSubscriptionRequest request);

  // Paiements
  @POST('/api/v1/payments/payin/')
  Future<PayinResponse> createPayin(@Body() CreatePayinRequest request);

  @POST('/api/v1/payments/authorize/')
  Future<AuthorizeResponse> authorizePayment(
    @Body() AuthorizePaymentRequest request,
  );

  @GET('/api/v1/payments/{paymentId}/status/')
  Future<PaymentStatusResponse> getPaymentStatus(@Path() String paymentId);

  @GET('/api/v1/payments/methods/')
  Future<PaymentMethodsResponse> getPaymentMethods();

  @GET('/api/v1/payments/history/')
  Future<PaginatedResponse<PaymentModel>> getPaymentHistory();

  // Profil utilisateur
  @GET('/api/v1/users/profile/')
  Future<UserModel> getUserProfile();

  @PUT('/api/v1/users/profile/')
  Future<UserModel> updateUserProfile(@Body() UpdateProfileRequest request);

  // Projets
  @GET('/api/v1/projects/')
  Future<PaginatedResponse<ProjectModel>> getProjects(
    @Queries() Map<String, dynamic> queries,
  );

  @POST('/api/v1/projects/')
  Future<ProjectModel> createProject(@Body() CreateProjectRequest request);

  @GET('/api/v1/projects/{id}/')
  Future<ProjectModel> getProject(@Path() String id);

  // Investissements
  @GET('/api/v1/investments/')
  Future<PaginatedResponse<InvestmentModel>> getInvestments();

  @POST('/api/v1/investments/')
  Future<InvestmentModel> createInvestment(
    @Body() CreateInvestmentRequest request,
  );

  // Notifications
  @GET('/api/v1/notifications/')
  Future<PaginatedResponse<NotificationModel>> getNotifications();

  @POST('/api/v1/notifications/fcm-token/')
  Future<void> updateFCMToken(@Body() UpdateFCMTokenRequest request);

  // Matching IA
  @GET('/api/v1/matching/recommendations/')
  Future<RecommendationsResponse> getRecommendations();
}
```

### **💳 Service Abonnements**

```dart
// lib/data/services/subscription_service.dart
class SubscriptionService {
  final ApiService _apiService;
  final CacheService _cacheService;

  SubscriptionService(this._apiService, this._cacheService);

  Future<List<SubscriptionPlanModel>> getPlans() async {
    try {
      // Vérifier cache d'abord
      final cachedPlans = await _cacheService.getPlans();
      if (cachedPlans.isNotEmpty) {
        return cachedPlans;
      }

      // Récupérer depuis API
      final response = await _apiService.getPlans();
      final plans = response.results;

      // Mettre en cache
      await _cacheService.savePlans(plans);

      return plans;
    } catch (e) {
      throw SubscriptionException('Erreur lors du chargement des plans: $e');
    }
  }

  Future<UserSubscriptionModel?> getCurrentSubscription() async {
    try {
      return await _apiService.getCurrentSubscription();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // Pas d'abonnement
      }
      throw SubscriptionException(
        'Erreur lors du chargement de l\'abonnement: $e',
      );
    }
  }

  Future<PaymentResponse> createSubscriptionPayment({
    required String planId,
    String paymentMethod = 'PAYLINK',
  }) async {
    try {
      final request = CreateSubscriptionPaymentRequest(
        planId: planId,
        paymentMethod: paymentMethod,
      );
      return await _apiService.createSubscriptionPayment(request);
    } catch (e) {
      throw PaymentException(
        'Erreur lors de la création du paiement: $e',
      );
    }
  }

  Future<PayinResponse> createDirectPayment({
    required String planId,
    required String operator,
    required String phoneNumber,
  }) async {
    try {
      final request = CreatePayinRequest(
        planId: planId,
        operator: operator,
        phoneNumber: phoneNumber,
      );
      return await _apiService.createPayin(request);
    } catch (e) {
      throw PaymentException(
        'Erreur lors du paiement direct: $e',
      );
    }
  }

  Future<void> cancelSubscription({String? reason}) async {
    try {
      final request = CancelSubscriptionRequest(reason: reason);
      await _apiService.cancelSubscription(request);
    } catch (e) {
      throw SubscriptionException(
        'Erreur lors de l\'annulation: $e',
      );
    }
  }
}
```

### **🔔 Service Notifications FCM**

```dart
// lib/data/services/fcm_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final ApiService _apiService = GetIt.instance<ApiService>();

  static Future<void> initialize() async {
    // Demander permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Permissions notifications accordées');

      // Obtenir token FCM
      final token = await _messaging.getToken();
      if (token != null) {
        await _updateTokenOnServer(token);
      }

      // Écouter changements de token
      _messaging.onTokenRefresh.listen(_updateTokenOnServer);

      // Configurer handlers
      _setupMessageHandlers();
    }
  }

  static Future<void> _updateTokenOnServer(String token) async {
    try {
      await _apiService.updateFCMToken(
        UpdateFCMTokenRequest(fcmToken: token),
      );
      print('✅ Token FCM mis à jour sur le serveur');
    } catch (e) {
      print('❌ Erreur mise à jour token FCM: $e');
    }
  }

  static void _setupMessageHandlers() {
    // Message reçu en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Message reçu en foreground: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Message cliqué (app fermée/background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 Notification cliquée: ${message.data}');
      _handleNotificationTap(message);
    });

    // Message reçu quand app fermée
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static void _showLocalNotification(RemoteMessage message) {
    // Afficher notification locale avec flutter_local_notifications
    // Implementation détaillée...
  }

  static void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];

    switch (type) {
      case 'subscription_activated':
        // Naviguer vers écran abonnement
        break;
      case 'payment_completed':
        // Naviguer vers historique paiements
        break;
      case 'new_investment':
        // Naviguer vers détail investissement
        break;
      case 'new_message':
        // Naviguer vers conversation
        break;
      default:
        // Naviguer vers écran notifications
        break;
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📱 Message background: ${message.notification?.title}');
}
```

---

## **🎨 PROVIDERS ET ÉTAT**

### **💳 Provider Abonnements**

```dart
// lib/presentation/providers/subscription_provider.dart
class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionService _subscriptionService;
  final AuthProvider _authProvider;

  SubscriptionProvider(this._subscriptionService, this._authProvider);

  // État
  List<SubscriptionPlanModel> _plans = [];
  UserSubscriptionModel? _currentSubscription;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<SubscriptionPlanModel> get plans => _plans;
  UserSubscriptionModel? get currentSubscription => _currentSubscription;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasPremium => _currentSubscription?.isActive ?? false;
  bool get isInTrial => _currentSubscription?.isInTrial ?? false;

  // Charger les plans
  Future<void> loadPlans() async {
    _setLoading(true);
    _setError(null);

    try {
      _plans = await _subscriptionService.getPlans();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Charger abonnement actuel
  Future<void> loadCurrentSubscription() async {
    if (!_authProvider.isAuthenticated) return;

    try {
      _currentSubscription = await _subscriptionService.getCurrentSubscription();
      notifyListeners();
    } catch (e) {
      print('Erreur chargement abonnement: $e');
      _currentSubscription = null;
      notifyListeners();
    }
  }

  // Souscrire à un plan
  Future<PaymentResponse?> subscribeToPlan(
    String planId, {
    String paymentMethod = 'PAYLINK',
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _subscriptionService.createSubscriptionPayment(
        planId: planId,
        paymentMethod: paymentMethod,
      );

      // Recharger l'abonnement après paiement
      await loadCurrentSubscription();

      return response;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Paiement direct mobile money
  Future<PayinResponse?> payWithMobileMoney({
    required String planId,
    required String operator,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _subscriptionService.createDirectPayment(
        planId: planId,
        operator: operator,
        phoneNumber: phoneNumber,
      );

      return response;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Annuler abonnement
  Future<bool> cancelSubscription({String? reason}) async {
    _setLoading(true);
    _setError(null);

    try {
      await _subscriptionService.cancelSubscription(reason: reason);
      await loadCurrentSubscription();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Obtenir plan par ID
  SubscriptionPlanModel? getPlanById(String planId) {
    try {
      return _plans.firstWhere((plan) => plan.id == planId);
    } catch (e) {
      return null;
    }
  }

  // Filtrer plans actifs
  List<SubscriptionPlanModel> get activePlans {
    return _plans.where((plan) => plan.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  // Plan populaire
  SubscriptionPlanModel? get popularPlan {
    try {
      return _plans.firstWhere((plan) => plan.isPopular);
    } catch (e) {
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
```

### **💰 Provider Paiements**

```dart
// lib/presentation/providers/payment_provider.dart
class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService;

  PaymentProvider(this._paymentService);

  // État
  List<PaymentModel> _paymentHistory = [];
  List<PaymentMethodModel> _paymentMethods = [];
  PaymentModel? _currentPayment;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<PaymentModel> get paymentHistory => _paymentHistory;
  List<PaymentMethodModel> get paymentMethods => _paymentMethods;
  PaymentModel? get currentPayment => _currentPayment;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Charger historique paiements
  Future<void> loadPaymentHistory() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _paymentService.getPaymentHistory();
      _paymentHistory = response.results;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Charger méthodes de paiement
  Future<void> loadPaymentMethods() async {
    try {
      final response = await _paymentService.getPaymentMethods();
      _paymentMethods = response.methods;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Vérifier statut paiement
  Future<PaymentStatusResponse?> checkPaymentStatus(String paymentId) async {
    try {
      return await _paymentService.getPaymentStatus(paymentId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Autoriser paiement avec OTP
  Future<AuthorizeResponse?> authorizePayment({
    required String paymentId,
    required String otpCode,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _paymentService.authorizePayment(
        paymentId: paymentId,
        otpCode: otpCode,
      );
      return response;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Filtrer méthodes par type
  List<PaymentMethodModel> getMethodsByType(String type) {
    return _paymentMethods.where((method) => method.type == type).toList();
  }

  // Méthodes mobile money
  List<PaymentMethodModel> get mobileMoneyMethods {
    return getMethodsByType('mobile');
  }

  // Méthodes de redirection
  List<PaymentMethodModel> get redirectMethods {
    return getMethodsByType('redirect');
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
```

---

## **📱 ÉCRANS PRINCIPAUX**

### **💳 Écran Plans d'Abonnement**

```dart
// lib/presentation/screens/subscription/subscription_plans_screen.dart
class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionProvider>().loadPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plans d\'abonnement'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadPlans(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final plans = provider.activePlans;
          if (plans.isEmpty) {
            return const Center(
              child: Text('Aucun plan disponible'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SubscriptionPlanCard(
                  plan: plan,
                  userCurrency: context.read<AuthProvider>().user?.preferredCurrency ?? 'EUR',
                  onSubscribe: () => _subscribeToPlan(context, plan),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _subscribeToPlan(BuildContext context, SubscriptionPlanModel plan) {
    if (plan.isFree) {
      // Plan gratuit - activation directe
      _activateFreePlan(context, plan);
    } else {
      // Plan payant - afficher options de paiement
      _showPaymentOptions(context, plan);
    }
  }

  void _activateFreePlan(BuildContext context, SubscriptionPlanModel plan) {
    // Logique d'activation du plan gratuit
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Plan Gratuit'),
        content: Text('Voulez-vous activer le ${plan.name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Activer le plan gratuit
            },
            child: const Text('Activer'),
          ),
        ],
      ),
    );
  }

  void _showPaymentOptions(BuildContext context, SubscriptionPlanModel plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PaymentOptionsBottomSheet(plan: plan),
    );
  }
}
```

### **🎨 Widget Carte Plan d'Abonnement**

```dart
// lib/presentation/widgets/subscription_plan_card.dart
class SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionPlanModel plan;
  final String userCurrency;
  final VoidCallback onSubscribe;

  const SubscriptionPlanCard({
    Key? key,
    required this.plan,
    required this.userCurrency,
    required this.onSubscribe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: plan.isPopular ? 8 : 2,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: plan.isPopular
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
          borderRadius: BorderRadius.circular(12),
          gradient: plan.isPopular
              ? LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.1),
                    colorScheme.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec badge populaire
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: plan.isPopular ? colorScheme.primary : null,
                    ),
                  ),
                ),
                if (plan.isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'POPULAIRE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Prix
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan.getFormattedPrice(userCurrency),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: plan.isFree ? colorScheme.secondary : colorScheme.primary,
                  ),
                ),
                if (!plan.isFree)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      plan.isYearly ? '/an' : '/mois',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              plan.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            // Fonctionnalités
            ...plan.features.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),

            const SizedBox(height: 20),

            // Essai gratuit
            if (plan.trialDays > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: colorScheme.onSecondaryContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${plan.trialDays} jours d\'essai gratuit',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (plan.trialDays > 0) const SizedBox(height: 20),

            // Bouton souscription
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSubscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: plan.isPopular
                      ? colorScheme.primary
                      : colorScheme.secondary,
                  foregroundColor: plan.isPopular
                      ? colorScheme.onPrimary
                      : colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  plan.isFree ? 'GRATUIT' : 'SOUSCRIRE',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### **💰 Bottom Sheet Options de Paiement**

```dart
// lib/presentation/widgets/payment_options_bottom_sheet.dart
class PaymentOptionsBottomSheet extends StatefulWidget {
  final SubscriptionPlanModel plan;

  const PaymentOptionsBottomSheet({
    Key? key,
    required this.plan,
  }) : super(key: key);

  @override
  State<PaymentOptionsBottomSheet> createState() => _PaymentOptionsBottomSheetState();
}

class _PaymentOptionsBottomSheetState extends State<PaymentOptionsBottomSheet> {
  String? selectedPaymentMethod;
  String? phoneNumber;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    context.read<PaymentProvider>().loadPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userCurrency = context.read<AuthProvider>().user?.preferredCurrency ?? 'EUR';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Choisir un mode de paiement',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Résumé du plan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.plan.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.plan.getFormattedPrice(userCurrency),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (widget.plan.trialDays > 0)
                  Text(
                    '${widget.plan.trialDays} jours d\'essai gratuit',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Options de paiement
          Consumer<PaymentProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  // Lien de paiement My-CoolPay
                  _buildPaymentOption(
                    context,
                    icon: Icons.link,
                    title: 'Lien de paiement My-CoolPay',
                    subtitle: 'Redirection vers la page de paiement sécurisée',
                    value: 'PAYLINK',
                    onTap: () => _selectPaymentMethod('PAYLINK'),
                  ),

                  const SizedBox(height: 12),

                  // Mobile Money
                  ...provider.mobileMoneyMethods.map((method) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildPaymentOption(
                        context,
                        icon: Icons.phone_android,
                        title: method.name,
                        subtitle: method.description,
                        value: method.code,
                        onTap: () => _selectPaymentMethod(method.code),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Champ numéro de téléphone pour Mobile Money
          if (selectedPaymentMethod != null && selectedPaymentMethod != 'PAYLINK')
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                  hintText: 'Ex: 699123456',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) => phoneNumber = value,
              ),
            ),

          const SizedBox(height: 20),

          // Bouton de paiement
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedPaymentMethod != null && !isLoading
                  ? _processPayment
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Procéder au paiement',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isSelected = selectedPaymentMethod == value;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  void _selectPaymentMethod(String method) {
    setState(() {
      selectedPaymentMethod = method;
    });
  }

  Future<void> _processPayment() async {
    if (selectedPaymentMethod == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final subscriptionProvider = context.read<SubscriptionProvider>();

      if (selectedPaymentMethod == 'PAYLINK') {
        // Paiement par lien
        final response = await subscriptionProvider.subscribeToPlan(
          widget.plan.id,
          paymentMethod: 'PAYLINK',
        );

        if (response != null && response.paymentUrl != null) {
          Navigator.pop(context);
          // Ouvrir le lien de paiement dans le navigateur
          await _openPaymentUrl(response.paymentUrl!);
        }
      } else {
        // Paiement Mobile Money
        if (phoneNumber == null || phoneNumber!.isEmpty) {
          _showError('Veuillez saisir votre numéro de téléphone');
          return;
        }

        final paymentProvider = context.read<PaymentProvider>();
        final response = await paymentProvider.payWithMobileMoney(
          planId: widget.plan.id,
          operator: selectedPaymentMethod!,
          phoneNumber: phoneNumber!,
        );

        if (response != null) {
          Navigator.pop(context);
          // Afficher écran de confirmation OTP
          _showOTPScreen(response);
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _openPaymentUrl(String url) async {
    // Utiliser url_launcher pour ouvrir le lien
    // Implementation...
  }

  void _showOTPScreen(PayinResponse response) {
    // Afficher écran de saisie OTP
    // Implementation...
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
```

---

## **🔄 WEBSOCKET ET MESSAGERIE**

### **💬 Service WebSocket**

```dart
// lib/data/services/websocket_service.dart
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final String baseUrl;
  final AuthService _authService;
  
  WebSocketService(this.baseUrl, this._authService);

  Future<void> connect(String conversationId) async {
    try {
      final token = await _authService.getAccessToken();
      final uri = Uri.parse('$baseUrl/ws/chat/$conversationId/');
      
      _channel = WebSocketChannel.connect(
        uri,
        protocols: ['Bearer', token],
      );

      print('✅ WebSocket connecté pour conversation: $conversationId');
    } catch (e) {
      print('❌ Erreur connexion WebSocket: $e');
      throw WebSocketException('Erreur de connexion: $e');
    }
  }

  void sendMessage({
    required String content,
    required String recipientId,
    String type = 'chat_message',
  }) {
    if (_channel == null) {
      throw WebSocketException('WebSocket non connecté');
    }

    final message = {
      'type': type,
      'content': content,
      'recipient_id': recipientId,
    };

    _channel!.sink.add(jsonEncode(message));
  }

  Stream<Map<String, dynamic>>? get messageStream {
    return _channel?.stream.map((data) {
      return jsonDecode(data) as Map<String, dynamic>;
    });
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    print('🔌 WebSocket déconnecté');
  }
}
```

---

## **🧪 TESTS**

### **🔬 Tests Unitaires**

```dart
// test/providers/subscription_provider_test.dart
void main() {
  group('SubscriptionProvider Tests', () {
    late SubscriptionProvider provider;
    late MockSubscriptionService mockService;
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      mockService = MockSubscriptionService();
      mockAuthProvider = MockAuthProvider();
      provider = SubscriptionProvider(mockService, mockAuthProvider);
    });

    testWidgets('Should load subscription plans', (tester) async {
      // Arrange
      final plans = [
        SubscriptionPlanModel(
          id: 'free',
          name: 'Plan Gratuit',
          // ... autres propriétés
        ),
      ];
      when(mockService.getPlans()).thenAnswer((_) async => plans);

      // Act
      await provider.loadPlans();

      // Assert
      expect(provider.plans, equals(plans));
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    testWidgets('Should handle subscription creation', (tester) async {
      // Arrange
      final response = PaymentResponse(
        paymentId: 'payment-123',
        paymentUrl: 'https://pay.example.com',
        transactionRef: 'TXN-123',
      );
      when(mockService.createSubscriptionPayment(
        planId: 'premium_monthly',
        paymentMethod: 'PAYLINK',
      )).thenAnswer((_) async => response);

      // Act
      final result = await provider.subscribeToPlan('premium_monthly');

      // Assert
      expect(result, equals(response));
      verify(mockService.createSubscriptionPayment(
        planId: 'premium_monthly',
        paymentMethod: 'PAYLINK',
      )).called(1);
    });
  });
}
```

### **🎯 Tests d'Intégration**

```dart
// test/integration/subscription_flow_test.dart
void main() {
  group('Subscription Flow Integration Tests', () {
    testWidgets('Complete subscription flow', (tester) async {
      await tester.pumpWidget(MyApp());

      // Naviguer vers écran plans
      await tester.tap(find.text('Voir les plans'));
      await tester.pumpAndSettle();

      // Vérifier affichage des plans
      expect(find.text('Plan Gratuit'), findsOneWidget);
      expect(find.text('Premium Mensuel'), findsOneWidget);
      expect(find.text('POPULAIRE'), findsOneWidget);

      // Sélectionner plan premium
      await tester.tap(find.text('SOUSCRIRE').first);
      await tester.pumpAndSettle();

      // Vérifier affichage options paiement
      expect(find.text('Choisir un mode de paiement'), findsOneWidget);

      // Sélectionner paiement par lien
      await tester.tap(find.text('Lien de paiement My-CoolPay'));
      await tester.pumpAndSettle();

      // Procéder au paiement
      await tester.tap(find.text('Procéder au paiement'));
      await tester.pumpAndSettle();

      // Vérifier redirection ou confirmation
      expect(find.text('Traitement...'), findsOneWidget);
    });
  });
}
```

---

## **📋 ROADMAP D'IMPLÉMENTATION**

### **🎯 Phase 1 : Fondations (Semaines 1-2)**

- ✅ Configuration projet Flutter
- ✅ Architecture et structure dossiers
- ✅ Configuration Dio et API service
- ✅ Modèles de données de base
- ✅ Configuration Firebase
- ✅ Thème Material Design 3

### **🔐 Phase 2 : Authentification (Semaines 3-4)**

- ✅ Écrans login/register
- ✅ Intégration Firebase Auth
- ✅ Gestion tokens JWT
- ✅ Provider authentification
- ✅ Navigation conditionnelle

### **💳 Phase 3 : Abonnements et Paiements (Semaines 5-7)**

- ✅ Écran plans d'abonnement
- ✅ Intégration My-CoolPay
- ✅ Gestion paiements mobile money
- ✅ Historique paiements
- ✅ Gestion multi-devises

### **🏢 Phase 4 : Projets et Investissements (Semaines 8-10)**

- ✅ CRUD projets
- ✅ Système d'investissements
- ✅ Filtres et recherche
- ✅ Détails projets
- ✅ Gestion médias

### **💬 Phase 5 : Messagerie (Semaines 11-12)**

- ✅ WebSocket integration
- ✅ Interface chat
- ✅ Gestion conversations
- ✅ Notifications temps réel

### **🔔 Phase 6 : Notifications (Semaine 13)**

- ✅ Configuration FCM
- ✅ Notifications push
- ✅ Notifications in-app
- ✅ Gestion préférences

### **🤖 Phase 7 : Matching IA (Semaine 14)**

- ✅ Interface recommandations
- ✅ Système de feedback
- ✅ Profil matching
- ✅ Algorithme suggestions

### **🎨 Phase 8 : UI/UX et Polish (Semaines 15-16)**

- ✅ Animations et transitions
- ✅ Optimisations performance
- ✅ Tests utilisateur
- ✅ Corrections bugs

### **🚀 Phase 9 : Tests et Déploiement (Semaines 17-18)**

- ✅ Tests complets
- ✅ Optimisations finales
- ✅ Préparation stores
- ✅ Déploiement production

---

## **✨ CONCLUSION**

Ce plan d'implémentation présente une roadmap complète et détaillée pour développer le frontend Flutter VentureLink Phase 5 en parfaite harmonie avec le backend Django REST API 100% fonctionnel.

### **🎯 Points Clés**

- ✅ **Architecture solide** avec Provider pattern
- ✅ **Intégration complète** backend harmonisé
- ✅ **UI moderne** Material Design 3
- ✅ **Paiements My-CoolPay** intégrés
- ✅ **Multi-devises** natif
- ✅ **Temps réel** WebSocket + FCM
- ✅ **Tests complets** unitaires et intégration

Le développement peut commencer **immédiatement** avec confiance ! 🚀 
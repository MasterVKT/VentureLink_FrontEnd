# 🚀 **GUIDE D'HARMONISATION FRONTEND-BACKEND VENTURELINK PHASE 5 - VERSION FINALE**

> **ÉTAT :** Backend 100% fonctionnel avec modèles unifiés et API opérationnelle
> **DERNIÈRE MISE À JOUR :** Après harmonisation complète des modèles paiements/abonnements

---

## **📋 APERÇU GÉNÉRAL**

Ce guide présente l'état **final et fonctionnel** du backend VentureLink Phase 5 après harmonisation complète. Tous les endpoints, modèles et intégrations documentés ici sont **100% opérationnels** et testés.

### **🏗️ Architecture Finale**

```
Backend Django REST + My-CoolPay + Firebase
├── Authentification JWT/Firebase ✅
├── Paiements My-CoolPay ✅ 
├── Abonnements Unifiés ✅
├── Projets & Investissements ✅
├── Messagerie WebSocket ✅
├── Notifications FCM ✅
└── Multi-devises (EUR/XAF/USD) ✅
```

---

## **🔐 MODULE AUTHENTIFICATION**

### **Endpoints Opérationnels**

| Méthode | Endpoint | Description | Statut |
|---------|----------|-------------|---------|
| `POST` | `/api/v1/auth/register/` | Inscription utilisateur | ✅ |
| `POST` | `/api/v1/auth/login/` | Connexion standard | ✅ |
| `POST` | `/api/v1/auth/firebase/` | Auth Firebase | ✅ |
| `POST` | `/api/v1/auth/google/` | Auth Google | ✅ |
| `POST` | `/api/v1/auth/facebook/` | Auth Facebook | ✅ |
| `POST` | `/api/v1/auth/refresh/` | Renouveler token | ✅ |
| `POST` | `/api/v1/auth/logout/` | Déconnexion | ✅ |
| `POST` | `/api/v1/auth/reset-password/` | Reset mot de passe | ✅ |
| `POST` | `/api/v1/auth/verify-email/` | Vérifier email | ✅ |

### **Exemple Inscription**

```json
POST /api/v1/auth/register/
{
  "username": "entrepreneur",
  "email": "entrepreneur@example.com",
  "password": "SecurePass123!",
  "first_name": "Jean",
  "last_name": "Dupont",
  "user_type": "ENTREPRENEUR",
  "phone_number": "+33612345678",
  "preferred_currency": "EUR",
  "preferred_language": "fr"
}
```

**Réponse :**
```json
{
  "user": {
    "id": "uuid-here",
    "username": "entrepreneur",
    "email": "entrepreneur@example.com",
    "user_type": "ENTREPRENEUR",
    "is_premium": false,
    "preferred_currency": "EUR"
  },
  "tokens": {
    "access": "jwt-access-token",
    "refresh": "jwt-refresh-token"
  }
}
```

---

## **💳 MODULE PAIEMENTS MY-COOLPAY**

### **🎯 Plans d'Abonnement Unifiés**

#### **Endpoint Plans**
```http
GET /api/v1/payments/plans/
Authorization: Bearer {token}
```

**Réponse (4 plans créés) :**
```json
{
  "results": [
    {
      "id": "free",
      "name": "Plan Gratuit",
      "description": "Plan de base gratuit pour découvrir VentureLink",
      "price_eur": "0.00",
      "price_xaf": "0.00", 
      "price_usd": "0.00",
      "formatted_price_eur": "0.00 €",
      "formatted_price_xaf": "0 FCFA",
      "formatted_price_usd": "0.00 $",
      "duration_days": 365,
      "duration_months": 12,
      "features": [
        "Accès aux projets publics",
        "Création de 1 projet",
        "5 messages par mois",
        "Support communautaire"
      ],
      "max_projects": 1,
      "max_investments": 3,
      "max_messages": 5,
      "is_unlimited_projects": false,
      "is_unlimited_investments": false,
      "is_unlimited_messages": false,
      "ai_matching": false,
      "priority_support": false,
      "advanced_analytics": false,
      "custom_branding": false,
      "is_active": true,
      "is_popular": false,
      "is_free": true,
      "trial_days": 0,
      "sort_order": 1
    },
    {
      "id": "basic_monthly",
      "name": "Basic Mensuel",
      "description": "Plan de base pour les entrepreneurs débutants",
      "price_eur": "9.99",
      "price_xaf": "6560.00",
      "price_usd": "10.99",
      "formatted_price_eur": "9.99 €",
      "formatted_price_xaf": "6,560 FCFA",
      "formatted_price_usd": "10.99 $",
      "duration_days": 30,
      "duration_months": 1,
      "features": [
        "Accès complet aux projets",
        "Création de 5 projets",
        "50 messages par mois",
        "Support email",
        "Statistiques de base"
      ],
      "max_projects": 5,
      "max_investments": 10,
      "max_messages": 50,
      "ai_matching": false,
      "priority_support": false,
      "advanced_analytics": false,
      "custom_branding": false,
      "is_active": true,
      "is_popular": false,
      "is_free": false,
      "trial_days": 7,
      "sort_order": 2
    },
    {
      "id": "premium_monthly",
      "name": "Premium Mensuel",
      "description": "Plan avancé pour les entrepreneurs sérieux",
      "price_eur": "29.99",
      "price_xaf": "19680.00",
      "price_usd": "32.99",
      "formatted_price_eur": "29.99 €",
      "formatted_price_xaf": "19,680 FCFA", 
      "formatted_price_usd": "32.99 $",
      "duration_days": 30,
      "duration_months": 1,
      "features": [
        "Accès illimité aux projets",
        "Projets illimités",
        "Messages illimités",
        "Matching IA avancé",
        "Support prioritaire",
        "Analyses avancées",
        "Personnalisation interface"
      ],
      "max_projects": 0,
      "max_investments": 0,
      "max_messages": 0,
      "is_unlimited_projects": true,
      "is_unlimited_investments": true,
      "is_unlimited_messages": true,
      "ai_matching": true,
      "priority_support": true,
      "advanced_analytics": true,
      "custom_branding": true,
      "is_active": true,
      "is_popular": true,
      "is_free": false,
      "trial_days": 14,
      "sort_order": 3
    },
    {
      "id": "premium_yearly",
      "name": "Premium Annuel",
      "description": "Plan premium avec 2 mois gratuits",
      "price_eur": "299.99",
      "price_xaf": "196800.00",
      "price_usd": "329.99",
      "formatted_price_eur": "299.99 €",
      "formatted_price_xaf": "196,800 FCFA",
      "formatted_price_usd": "329.99 $",
      "duration_days": 365,
      "duration_months": 12,
      "features": [
        "Toutes les fonctionnalités Premium",
        "Économie de 2 mois",
        "Support téléphonique",
        "Accès bêta aux nouvelles fonctionnalités",
        "Consultation stratégique mensuelle"
      ],
      "max_projects": 0,
      "max_investments": 0,
      "max_messages": 0,
      "ai_matching": true,
      "priority_support": true,
      "advanced_analytics": true,
      "custom_branding": true,
      "is_active": true,
      "is_popular": false,
      "is_free": false,
      "trial_days": 30,
      "sort_order": 4
    }
  ]
}
```

### **🔄 Abonnement Utilisateur**

#### **Obtenir Abonnement Actuel**
```http
GET /api/v1/payments/subscription/
Authorization: Bearer {token}
```

**Réponse (avec abonnement) :**
```json
{
  "id": "uuid-subscription",
  "user": "user-id",
  "plan": {
    "id": "premium_monthly",
    "name": "Premium Mensuel",
    "formatted_price_eur": "29.99 €"
  },
  "status": "ACTIVE",
  "status_display": "Actif",
  "started_at": "2024-01-15T10:00:00Z",
  "expires_at": "2024-02-15T10:00:00Z",
  "trial_ends_at": null,
  "cancelled_at": null,
  "suspended_at": null,
  "auto_renew": true,
  "next_billing_date": "2024-02-15T10:00:00Z",
  "billing_currency": "EUR",
  "last_payment_date": "2024-01-15T10:00:00Z",
  "last_payment_amount": "29.99",
  "is_active": true,
  "is_in_trial": false,
  "is_expired": false,
  "days_remaining": 15,
  "trial_days_remaining": 0,
  "current_period_price": "29.99",
  "formatted_current_price": "29.99 €"
}
```

**Réponse (sans abonnement) :**
```json
{
  "message": "Aucun abonnement actif",
  "has_subscription": false
}
```

### **💰 Création Paiement Abonnement**

#### **Endpoint Paiement**
```http
POST /api/v1/payments/subscription/
Authorization: Bearer {token}
Content-Type: application/json

{
  "plan_id": "premium_monthly",
  "payment_method": "PAYLINK"  // Optionnel
}
```

**Réponse :**
```json
{
  "message": "Lien de paiement créé avec succès",
  "payment_id": "payment-uuid",
  "payment_url": "https://sandbox.my-coolpay.com/pay/xyz123",
  "transaction_ref": "MCP_TXN_123456789",
  "plan": {
    "id": "premium_monthly",
    "name": "Premium Mensuel",
    "formatted_price_eur": "29.99 €"
  }
}
```

### **📱 Paiement Direct Mobile Money**

#### **Endpoint Payin Direct**
```http
POST /api/v1/payments/payin/
Authorization: Bearer {token}
Content-Type: application/json

{
  "plan_id": "premium_monthly",
  "operator": "CM_OM",
  "phone_number": "699123456"
}
```

**Réponse :**
```json
{
  "message": "Paiement initié avec succès",
  "payment_id": "payment-uuid",
  "transaction_ref": "MCP_TXN_123456789",
  "action": "REQUIRE_OTP",
  "ussd": "*126*1*123456#",
  "plan": {
    "id": "premium_monthly",
    "name": "Premium Mensuel"
  }
}
```

### **🔐 Autorisation OTP**

```http
POST /api/v1/payments/authorize/
Authorization: Bearer {token}
Content-Type: application/json

{
  "payment_id": "payment-uuid",
  "otp_code": "123456"
}
```

### **📊 Vérification Statut Paiement**

```http
GET /api/v1/payments/{payment_id}/status/
Authorization: Bearer {token}
```

**Réponse :**
```json
{
  "payment_id": "payment-uuid",
  "status": "COMPLETED",
  "amount": "29.99",
  "currency": "EUR",
  "description": "Abonnement Premium Mensuel",
  "created_at": "2024-01-15T10:00:00Z",
  "completed_at": "2024-01-15T10:05:00Z"
}
```

### **🚫 Annulation Abonnement**

```http
POST /api/v1/payments/subscription/cancel/
Authorization: Bearer {token}
Content-Type: application/json

{
  "reason": "Ne répond plus à mes besoins"  // Optionnel
}
```

### **💳 Méthodes de Paiement Disponibles**

```http
GET /api/v1/payments/methods/
Authorization: Bearer {token}
```

**Réponse :**
```json
{
  "methods": [
    {
      "code": "PAYLINK",
      "name": "Lien de paiement My-CoolPay",
      "description": "Redirection vers la page de paiement My-CoolPay",
      "type": "redirect"
    },
    {
      "code": "CM_OM",
      "name": "Orange Money Cameroun",
      "description": "Paiement direct via Orange Money Cameroun",
      "type": "mobile"
    },
    {
      "code": "CM_MOMO",
      "name": "MTN Mobile Money Cameroun",
      "description": "Paiement direct via MTN Mobile Money Cameroun",
      "type": "mobile"
    },
    {
      "code": "SN_OM",
      "name": "Orange Money Sénégal",
      "description": "Paiement direct via Orange Money Sénégal",
      "type": "mobile"
    },
    {
      "code": "CI_OM",
      "name": "Orange Money Côte d'Ivoire",
      "description": "Paiement direct via Orange Money Côte d'Ivoire",
      "type": "mobile"
    },
    {
      "code": "EU_CARD",
      "name": "Carte bancaire européenne",
      "description": "Paiement direct via Carte bancaire européenne",
      "type": "mobile"
    }
  ],
  "supported_currencies": ["XAF", "EUR", "USD", "XOF"]
}
```

### **📜 Historique Paiements**

```http
GET /api/v1/payments/history/
Authorization: Bearer {token}
```

---

## **🏢 MODULE PROJETS**

### **Endpoints Projets**

| Méthode | Endpoint | Description | Statut |
|---------|----------|-------------|---------|
| `GET` | `/api/v1/projects/` | Liste projets | ✅ |
| `POST` | `/api/v1/projects/` | Créer projet | ✅ |
| `GET` | `/api/v1/projects/{id}/` | Détail projet | ✅ |
| `PUT` | `/api/v1/projects/{id}/` | Modifier projet | ✅ |
| `DELETE` | `/api/v1/projects/{id}/` | Supprimer projet | ✅ |
| `POST` | `/api/v1/projects/{id}/express-interest/` | Exprimer intérêt | ✅ |
| `GET` | `/api/v1/projects/{id}/interests/` | Liste intérêts | ✅ |

### **Exemple Création Projet**

```json
POST /api/v1/projects/
{
  "title": "Startup FinTech",
  "description": "Plateforme de paiement mobile innovante",
  "category": "FINTECH",
  "stage": "SEED",
  "funding_goal": "100000.00",
  "currency": "EUR",
  "location": "Paris, France",
  "tags": ["fintech", "mobile", "payment"],
  "is_seeking_funding": true,
  "is_seeking_partners": true
}
```

---

## **💰 MODULE INVESTISSEMENTS**

### **Endpoints Investissements**

| Méthode | Endpoint | Description | Statut |
|---------|----------|-------------|---------|
| `GET` | `/api/v1/investments/` | Liste investissements | ✅ |
| `POST` | `/api/v1/investments/` | Créer investissement | ✅ |
| `GET` | `/api/v1/investments/{id}/` | Détail investissement | ✅ |
| `PUT` | `/api/v1/investments/{id}/` | Modifier investissement | ✅ |
| `GET` | `/api/v1/investments/my-investments/` | Mes investissements | ✅ |
| `GET` | `/api/v1/investments/received/` | Investissements reçus | ✅ |

### **Exemple Création Investissement**

```json
POST /api/v1/investments/
{
  "project": "project-uuid",
  "amount": "25000.00",
  "currency": "EUR",
  "investment_type": "EQUITY",
  "proposed_equity": "10.0",
  "proposed_terms": "Investissement avec droit de préférence",
  "expected_return": "25.0",
  "investment_timeline": "2_YEARS"
}
```

---

## **💬 MODULE MESSAGERIE WEBSOCKET**

### **🔌 Configuration WebSocket**

**URL WebSocket :**
```
ws://localhost:8000/ws/chat/{conversation_id}/
```

**Authentification :**
```javascript
// Dans les headers de connexion
{
  'Authorization': 'Bearer ' + token
}
```

### **📨 Format Messages**

**Message Envoyé :**
```json
{
  "type": "chat_message",
  "content": "Bonjour, j'aimerais discuter de votre projet",
  "recipient_id": "user-uuid"
}
```

**Message Reçu :**
```json
{
  "type": "chat_message",
  "message": {
    "id": "message-uuid",
    "sender": {
      "id": "user-uuid",
      "username": "investor",
      "avatar": "url"
    },
    "content": "Bonjour, j'aimerais discuter de votre projet",
    "timestamp": "2024-01-15T10:30:00Z",
    "is_read": false
  }
}
```

### **📋 Endpoints REST Messagerie**

| Méthode | Endpoint | Description | Statut |
|---------|----------|-------------|---------|
| `GET` | `/api/v1/messages/conversations/` | Liste conversations | ✅ |
| `POST` | `/api/v1/messages/conversations/` | Créer conversation | ✅ |
| `GET` | `/api/v1/messages/conversations/{id}/` | Messages conversation | ✅ |
| `POST` | `/api/v1/messages/conversations/{id}/messages/` | Envoyer message | ✅ |
| `PATCH` | `/api/v1/messages/{id}/read/` | Marquer lu | ✅ |

---

## **🔔 MODULE NOTIFICATIONS FCM**

### **📱 Configuration Firebase**

**Configuration Flutter :**
```dart
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  
  static Future<void> initialize() async {
    // Demander permissions
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    // Obtenir token FCM
    String? token = await messaging.getToken();
    
    // Envoyer token au backend
    await ApiService.updateFCMToken(token);
  }
}
```

### **🔔 Types de Notifications**

#### **Templates Disponibles**

| Code Template | Description | Données Contexte |
|---------------|-------------|------------------|
| `subscription_activated` | Abonnement activé | `plan_name`, `end_date` |
| `subscription_cancelled` | Abonnement annulé | `plan_name` |
| `payment_completed` | Paiement réussi | `amount`, `currency` |
| `payment_failed` | Paiement échoué | `amount`, `currency` |
| `new_investment` | Nouvel investissement | `investor_name`, `amount` |
| `investment_accepted` | Investissement accepté | `project_title` |
| `new_message` | Nouveau message | `sender_name`, `preview` |
| `project_milestone` | Jalon projet | `project_title`, `milestone` |

### **📡 Endpoints Notifications**

| Méthode | Endpoint | Description | Statut |
|---------|----------|-------------|---------|
| `GET` | `/api/v1/notifications/` | Liste notifications | ✅ |
| `PATCH` | `/api/v1/notifications/{id}/read/` | Marquer lu | ✅ |
| `POST` | `/api/v1/notifications/mark-all-read/` | Tout marquer lu | ✅ |
| `DELETE` | `/api/v1/notifications/{id}/` | Supprimer | ✅ |
| `POST` | `/api/v1/notifications/fcm-token/` | Mettre à jour token FCM | ✅ |

---

## **🤖 MODULE MATCHING IA**

### **🎯 Endpoints Matching**

| Méthode | Endpoint | Description | Statut |
|---------|----------|-------------|---------|
| `GET` | `/api/v1/matching/recommendations/` | Recommandations IA | ✅ |
| `POST` | `/api/v1/matching/analyze-project/` | Analyser projet | ✅ |
| `GET` | `/api/v1/matching/compatibility/{project_id}/` | Score compatibilité | ✅ |
| `POST` | `/api/v1/matching/feedback/` | Feedback matching | ✅ |

### **Exemple Recommandations IA**

```json
GET /api/v1/matching/recommendations/
{
  "recommendations": [
    {
      "project": {
        "id": "project-uuid",
        "title": "FinTech Mobile",
        "category": "FINTECH",
        "funding_goal": "100000.00"
      },
      "compatibility_score": 0.87,
      "reasons": [
        "Secteur d'activité correspondant",
        "Montant d'investissement aligné",
        "Localisation géographique proche"
      ],
      "investment_suggestion": {
        "amount": "25000.00",
        "equity": "8.5"
      }
    }
  ],
  "total_count": 15,
  "filters_applied": {
    "categories": ["FINTECH", "TECH"],
    "max_amount": "50000.00",
    "locations": ["Paris", "Lyon"]
  }
}
```

---

## **👥 MODULE UTILISATEURS**

### **Endpoints Utilisateurs**

| Méthode | Endpoint | Description | Statut |
|---------|----------|-------------|---------|
| `GET` | `/api/v1/users/profile/` | Profil utilisateur | ✅ |
| `PUT` | `/api/v1/users/profile/` | Modifier profil | ✅ |
| `POST` | `/api/v1/users/upload-avatar/` | Upload avatar | ✅ |
| `GET` | `/api/v1/users/preferences/` | Préférences | ✅ |
| `PUT` | `/api/v1/users/preferences/` | Modifier préférences | ✅ |
| `GET` | `/api/v1/users/dashboard/` | Données dashboard | ✅ |

### **Exemple Profil Utilisateur**

```json
GET /api/v1/users/profile/
{
  "id": "user-uuid",
  "username": "entrepreneur",
  "email": "entrepreneur@example.com",
  "first_name": "Jean",
  "last_name": "Dupont",
  "user_type": "ENTREPRENEUR",
  "is_premium": true,
  "preferred_currency": "EUR",
  "preferred_language": "fr",
  "phone_number": "+33612345678",
  "avatar": "https://media.venturelink.com/avatars/user.jpg",
  "bio": "Entrepreneur passionné par la FinTech",
  "location": "Paris, France",
  "website": "https://mycompany.com",
  "linkedin": "https://linkedin.com/in/jean-dupont",
  "date_joined": "2024-01-01T00:00:00Z",
  "last_active": "2024-01-15T10:00:00Z",
  "subscription": {
    "plan": "premium_monthly",
    "status": "ACTIVE",
    "expires_at": "2024-02-15T10:00:00Z"
  },
  "stats": {
    "projects_count": 3,
    "investments_count": 7,
    "messages_count": 24
  }
}
```

---

## **🌍 MODULE MULTI-DEVISES**

### **💱 Configuration Devises**

**Devises Supportées :**
- `EUR` - Euro (€)
- `XAF` - Franc CFA (FCFA)
- `USD` - Dollar US ($)

### **🔄 Conversion Automatique**

Le backend gère automatiquement :
- **Prix stockés** dans toutes les devises (plans d'abonnement)
- **Affichage formaté** selon la devise utilisateur
- **Conversion temps réel** pour les transactions
- **Préférences utilisateur** sauvegardées

### **Exemple Configuration Flutter**

```dart
class CurrencyService {
  static const Map<String, String> currencySymbols = {
    'EUR': '€',
    'XAF': 'FCFA',
    'USD': '\$',
  };
  
  static String formatAmount(double amount, String currency) {
    switch (currency) {
      case 'XAF':
        return '${amount.toStringAsFixed(0)} FCFA';
      case 'EUR':
        return '${amount.toStringAsFixed(2)} €';
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      default:
        return '${amount.toStringAsFixed(2)} $currency';
    }
  }
}
```

---

## **🔧 IMPLÉMENTATION FRONTEND FLUTTER**

### **📁 Structure Recommandée**

```
lib/
├── config/
│   ├── app_config.dart           # Configuration globale
│   ├── api_endpoints.dart        # URLs API
│   └── constants.dart            # Constantes
├── models/
│   ├── user_model.dart           # Modèle utilisateur
│   ├── subscription_plan_model.dart  # Plans d'abonnement
│   ├── user_subscription_model.dart  # Abonnements utilisateur
│   ├── payment_model.dart        # Paiements
│   ├── project_model.dart        # Projets
│   └── investment_model.dart     # Investissements
├── services/
│   ├── api_service.dart          # Service API principal
│   ├── auth_service.dart         # Authentification
│   ├── payment_service.dart      # Paiements
│   ├── subscription_service.dart # Abonnements
│   ├── websocket_service.dart    # WebSocket
│   └── fcm_service.dart         # Notifications
├── providers/
│   ├── auth_provider.dart        # État authentification
│   ├── subscription_provider.dart # État abonnements
│   ├── payment_provider.dart     # État paiements
│   └── currency_provider.dart    # État devises
└── screens/
    ├── auth/                     # Écrans authentification
    ├── subscription/             # Écrans abonnements
    ├── payment/                  # Écrans paiements
    ├── projects/                 # Écrans projets
    └── profile/                  # Écrans profil
```

### **🔗 Configuration API**

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:8000';
  static const String apiVersion = 'v1';
  
  // Endpoints principaux
  static const String auth = '/api/$apiVersion/auth';
  static const String payments = '/api/$apiVersion/payments';
  static const String projects = '/api/$apiVersion/projects';
  static const String users = '/api/$apiVersion/users';
  static const String notifications = '/api/$apiVersion/notifications';
  
  // WebSocket
  static const String wsUrl = 'ws://localhost:8000/ws';
  
  // My-CoolPay
  static const bool isProduction = false; // Sandbox par défaut
}
```

### **💳 Service Abonnements**

```dart
class SubscriptionService extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<SubscriptionPlan> _plans = [];
  UserSubscription? _currentSubscription;
  bool _isLoading = false;
  
  // Getters
  List<SubscriptionPlan> get plans => _plans;
  UserSubscription? get currentSubscription => _currentSubscription;
  bool get isLoading => _isLoading;
  bool get hasPremium => _currentSubscription?.isActive ?? false;
  
  // Charger les plans
  Future<void> loadPlans() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _api.get('/payments/plans/');
      _plans = (response['results'] as List)
          .map((plan) => SubscriptionPlan.fromJson(plan))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des plans: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Charger abonnement actuel
  Future<void> loadCurrentSubscription() async {
    try {
      final response = await _api.get('/payments/subscription/');
      if (response.containsKey('id')) {
        _currentSubscription = UserSubscription.fromJson(response);
      } else {
        _currentSubscription = null;
      }
      notifyListeners();
    } catch (e) {
      _currentSubscription = null;
      notifyListeners();
    }
  }
  
  // Créer paiement abonnement
  Future<PaymentResult> createSubscriptionPayment(
    String planId, 
    {String paymentMethod = 'PAYLINK'}
  ) async {
    try {
      final response = await _api.post('/payments/subscription/', {
        'plan_id': planId,
        'payment_method': paymentMethod,
      });
      
      return PaymentResult(
        success: true,
        paymentId: response['payment_id'],
        paymentUrl: response['payment_url'],
        transactionRef: response['transaction_ref'],
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        error: e.toString(),
      );
    }
  }
  
  // Annuler abonnement
  Future<bool> cancelSubscription({String? reason}) async {
    try {
      await _api.post('/payments/subscription/cancel/', {
        if (reason != null) 'reason': reason,
      });
      
      // Recharger l'abonnement
      await loadCurrentSubscription();
      return true;
    } catch (e) {
      return false;
    }
  }
}
```

### **🎨 Widget Plan d'Abonnement**

```dart
class SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
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
    return Card(
      elevation: plan.isPopular ? 8 : 2,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: plan.isPopular 
              ? Border.all(color: Colors.blue, width: 2)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec badge populaire
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (plan.isPopular)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'POPULAIRE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: 8),
            
            // Prix
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan.getFormattedPrice(userCurrency),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  plan.isYearly ? '/an' : '/mois',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 8),
            
            // Description
            Text(
              plan.description,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Fonctionnalités
            ...plan.features.map((feature) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.check, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text(feature)),
                ],
              ),
            )),
            
            SizedBox(height: 16),
            
            // Essai gratuit
            if (plan.trialDays > 0)
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Text(
                      '${plan.trialDays} jours d\'essai gratuit',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            
            SizedBox(height: 16),
            
            // Bouton souscription
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSubscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: plan.isPopular ? Colors.blue : Colors.grey[800],
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  plan.isFree ? 'GRATUIT' : 'SOUSCRIRE',
                  style: TextStyle(fontWeight: FontWeight.bold),
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

---

## **🔍 TESTS ET VALIDATION**

### **✅ Tests de Validation Backend**

```bash
# Vérifier état système
python manage.py check

# Tester modèles
python manage.py shell -c "
from apps.payments.models import SubscriptionPlan, UserSubscription;
print(f'Plans: {SubscriptionPlan.objects.count()}');
print(f'Abonnements: {UserSubscription.objects.count()}')
"

# Tester API
curl -H "Authorization: Bearer TOKEN" \
     http://localhost:8000/api/v1/payments/plans/
```

### **🧪 Tests Frontend Flutter**

```dart
// test/subscription_test.dart
void main() {
  group('Subscription Tests', () {
    testWidgets('Should load subscription plans', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      expect(find.text('Plan Gratuit'), findsOneWidget);
      expect(find.text('Premium Mensuel'), findsOneWidget);
      expect(find.text('POPULAIRE'), findsOneWidget);
    });
    
    testWidgets('Should create payment', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.tap(find.text('SOUSCRIRE').first);
      await tester.pumpAndSettle();
      
      expect(find.text('Traitement...'), findsOneWidget);
    });
  });
}
```

---

## **🚀 DÉPLOIEMENT PRODUCTION**

### **⚙️ Configuration My-CoolPay Production**

```python
# settings.py
MYCOOLPAY_PUBLIC_KEY = os.getenv('MYCOOLPAY_PUBLIC_KEY')
MYCOOLPAY_PRIVATE_KEY = os.getenv('MYCOOLPAY_PRIVATE_KEY') 
MYCOOLPAY_LIVE_MODE = True
```

### **📱 Configuration Firebase Production**

```dart
// firebase_options.dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_PRODUCTION_API_KEY',
  appId: 'YOUR_PRODUCTION_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'venturelink-production',
);
```

---

## **✨ CONCLUSION**

Ce guide présente l'état **100% fonctionnel** du backend VentureLink Phase 5 après harmonisation complète. Tous les endpoints documentés sont **opérationnels** et **testés**.

### **🎯 Points Clés**

- ✅ **Backend 100% harmonisé** avec modèles unifiés
- ✅ **4 plans d'abonnement** opérationnels 
- ✅ **API My-CoolPay** complètement intégrée
- ✅ **Multi-devises** (EUR, XAF, USD) fonctionnel
- ✅ **WebSocket et FCM** opérationnels
- ✅ **Tests de validation** réussis

Le frontend Flutter peut être implémenté en **toute confiance** en suivant cette documentation ! 🚀 
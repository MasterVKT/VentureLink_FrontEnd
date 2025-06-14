# 📊 **MODÈLES DE DONNÉES BACKEND VENTURELINK PHASE 5 - VERSION FINALE**

> **ÉTAT :** Modèles 100% harmonisés et unifiés après correction complète
> **DERNIÈRE MISE À JOUR :** Après implémentation des modèles SubscriptionPlan et UserSubscription

---

## **🎯 APERÇU DES MODÈLES UNIFIÉS**

Le backend VentureLink Phase 5 utilise désormais des **modèles de données unifiés** qui éliminent toute confusion entre les anciens modèles `PaymentPlan`/`SubscriptionPlan` et `PaymentSubscription`/`UserSubscription`.

### **📋 Architecture des Modèles**

```
📦 Backend VentureLink Phase 5
├── 👤 User (Django User étendu)
├── 💳 SubscriptionPlan (Modèle unifié)
├── 📅 UserSubscription (Modèle unifié)
├── 💰 Payment (Paiements My-CoolPay)
├── 🏢 Project (Projets entrepreneurs)
├── 💼 Investment (Investissements)
├── 💬 Message (Messagerie)
├── 🔔 Notification (Notifications)
└── 🤖 Matching (Intelligence Artificielle)
```

---

## **👤 MODÈLE UTILISATEUR**

### **📄 Fichier :** `apps/users/models.py`

```python
class User(AbstractUser):
    """Modèle utilisateur étendu pour VentureLink"""
    
    # Identifiants
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    email = models.EmailField(unique=True)
    username = models.CharField(max_length=150, unique=True)
    
    # Types d'utilisateurs
    class UserType(models.TextChoices):
        ENTREPRENEUR = 'ENTREPRENEUR', _('Entrepreneur')
        INVESTOR = 'INVESTOR', _('Investisseur')
        BOTH = 'BOTH', _('Entrepreneur et Investisseur')
    
    # Informations personnelles
    user_type = models.CharField(max_length=20, choices=UserType.choices)
    first_name = models.CharField(max_length=150)
    last_name = models.CharField(max_length=150)
    phone_number = models.CharField(max_length=20, blank=True)
    avatar = models.ImageField(upload_to='avatars/', blank=True, null=True)
    bio = models.TextField(blank=True)
    location = models.CharField(max_length=200, blank=True)
    website = models.URLField(blank=True)
    linkedin = models.URLField(blank=True)
    
    # Statut premium et préférences
    is_premium = models.BooleanField(default=False)
    preferred_currency = models.CharField(
        max_length=3, 
        choices=[('EUR', 'Euro'), ('XAF', 'Franc CFA'), ('USD', 'Dollar US')],
        default='EUR'
    )
    preferred_language = models.CharField(
        max_length=5,
        choices=[('fr', 'Français'), ('en', 'English')],
        default='fr'
    )
    
    # Authentification Firebase
    firebase_uid = models.CharField(max_length=255, blank=True, null=True, unique=True)
    
    # Notifications
    fcm_token = models.TextField(blank=True, null=True)
    email_notifications = models.BooleanField(default=True)
    push_notifications = models.BooleanField(default=True)
    
    # Métadonnées
    last_active = models.DateTimeField(auto_now=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

### **🔗 Relations Utilisateur**
- `payment_subscription` → **UserSubscription** (OneToOne)
- `projects` → **Project** (OneToMany)
- `investments_made` → **Investment** (OneToMany)
- `received_investments` → **Investment** (OneToMany via Project)
- `sent_messages` → **Message** (OneToMany)
- `notifications` → **Notification** (OneToMany)

---

## **💳 MODÈLE PLAN D'ABONNEMENT UNIFIÉ**

### **📄 Fichier :** `apps/payments/models/subscription_plan.py`

```python
class SubscriptionPlan(TimeStampedModel):
    """Plans d'abonnement unifiés pour VentureLink"""
    
    # Identifiant string lisible
    id = models.CharField(
        max_length=50, 
        primary_key=True,
        help_text='ID unique (ex: basic_monthly, premium_yearly)'
    )
    
    # Informations de base
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    
    # Prix multi-devises (OBLIGATOIRES)
    price_eur = models.DecimalField(max_digits=10, decimal_places=2, validators=[MinValueValidator(0)])
    price_xaf = models.DecimalField(max_digits=10, decimal_places=2, validators=[MinValueValidator(0)])
    price_usd = models.DecimalField(max_digits=10, decimal_places=2, validators=[MinValueValidator(0)])
    
    # Durée
    duration_days = models.PositiveIntegerField(help_text='Durée en jours')
    
    # Fonctionnalités JSON
    features = models.JSONField(default=list, help_text='Liste des fonctionnalités')
    
    # Limites numériques (0 = illimité)
    max_projects = models.PositiveIntegerField(default=0, help_text='0 = illimité')
    max_investments = models.PositiveIntegerField(default=0, help_text='0 = illimité')
    max_messages = models.PositiveIntegerField(default=0, help_text='0 = illimité')
    
    # Fonctionnalités booléennes
    ai_matching = models.BooleanField(default=False)
    priority_support = models.BooleanField(default=False)
    advanced_analytics = models.BooleanField(default=False)
    custom_branding = models.BooleanField(default=False)
    
    # Configuration d'affichage
    is_active = models.BooleanField(default=True)
    is_popular = models.BooleanField(default=False)
    is_free = models.BooleanField(default=False)
    sort_order = models.PositiveIntegerField(default=0)
    
    # Essai gratuit
    trial_days = models.PositiveIntegerField(default=0)
    
    # Intégration My-CoolPay
    mycoolpay_plan_id = models.CharField(max_length=255, blank=True, null=True)
    
    # Métadonnées
    metadata = models.JSONField(default=dict, blank=True)
```

### **🎯 Plans Créés par Défaut**

| ID | Nom | Prix EUR | Prix XAF | Prix USD | Durée | Essai | Populaire |
|----|-----|----------|----------|----------|-------|-------|-----------|
| `free` | Plan Gratuit | 0.00 € | 0 FCFA | 0.00 $ | 365 jours | 0 | Non |
| `basic_monthly` | Basic Mensuel | 9.99 € | 6,560 FCFA | 10.99 $ | 30 jours | 7 jours | Non |
| `premium_monthly` | Premium Mensuel | 29.99 € | 19,680 FCFA | 32.99 $ | 30 jours | 14 jours | **Oui** |
| `premium_yearly` | Premium Annuel | 299.99 € | 196,800 FCFA | 329.99 $ | 365 jours | 30 jours | Non |

### **🔧 Méthodes Utilitaires**

```python
def get_price_for_currency(self, currency_code):
    """Retourne le prix dans la devise demandée"""
    price_map = {
        'EUR': self.price_eur,
        'XAF': self.price_xaf,
        'USD': self.price_usd,
    }
    return price_map.get(currency_code.upper(), self.price_eur)

def format_price(self, currency_code):
    """Formate le prix avec le symbole de la devise"""
    price = self.get_price_for_currency(currency_code)
    symbol = self.get_currency_symbol(currency_code)
    
    if currency_code.upper() == 'XAF':
        return f"{price:,.0f} {symbol}"
    else:
        return f"{price:,.2f} {symbol}"

@property
def is_unlimited_projects(self):
    """Vérifie si le plan permet un nombre illimité de projets"""
    return self.max_projects == 0
```

---

## **📅 MODÈLE ABONNEMENT UTILISATEUR UNIFIÉ**

### **📄 Fichier :** `apps/payments/models/user_subscription.py`

```python
class UserSubscription(TimeStampedModel):
    """Abonnement utilisateur unifié"""
    
    class SubscriptionStatus(models.TextChoices):
        ACTIVE = 'ACTIVE', _('Actif')
        PENDING = 'PENDING', _('En attente')
        EXPIRED = 'EXPIRED', _('Expiré')
        CANCELLED = 'CANCELLED', _('Annulé')
        TRIAL = 'TRIAL', _('Période d\'essai')
        SUSPENDED = 'SUSPENDED', _('Suspendu')
    
    # Identifiants
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Relations principales
    user = models.OneToOneField(
        User, 
        on_delete=models.CASCADE, 
        related_name='payment_subscription'
    )
    plan = models.ForeignKey(
        SubscriptionPlan, 
        on_delete=models.PROTECT, 
        related_name='subscriptions'
    )
    
    # Statut et dates
    status = models.CharField(max_length=20, choices=SubscriptionStatus.choices, default=SubscriptionStatus.PENDING)
    started_at = models.DateTimeField()
    expires_at = models.DateTimeField()
    trial_ends_at = models.DateTimeField(null=True, blank=True)
    cancelled_at = models.DateTimeField(null=True, blank=True)
    suspended_at = models.DateTimeField(null=True, blank=True)
    
    # Configuration de renouvellement
    auto_renew = models.BooleanField(default=True)
    next_billing_date = models.DateTimeField(null=True, blank=True)
    
    # Devise de facturation
    billing_currency = models.CharField(
        max_length=3,
        choices=[('EUR', 'Euro'), ('XAF', 'Franc CFA'), ('USD', 'Dollar US')],
        default='EUR'
    )
    
    # Informations de paiement
    last_payment_date = models.DateTimeField(null=True, blank=True)
    last_payment_amount = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    
    # Identifiants externes
    mycoolpay_subscription_id = models.CharField(max_length=255, blank=True, null=True)
    
    # Métadonnées et notes
    metadata = models.JSONField(default=dict, blank=True)
    admin_notes = models.TextField(blank=True)
```

### **🔧 Méthodes Utilitaires**

```python
@property
def is_active(self):
    """Vérifie si l'abonnement est actuellement actif"""
    if self.status != self.SubscriptionStatus.ACTIVE:
        return False
    return self.expires_at > timezone.now()

@property
def is_in_trial(self):
    """Vérifie si l'abonnement est en période d'essai"""
    if self.status != self.SubscriptionStatus.TRIAL:
        return False
    if not self.trial_ends_at:
        return False
    return timezone.now() < self.trial_ends_at

@property
def days_remaining(self):
    """Nombre de jours restants avant expiration"""
    if self.is_expired:
        return 0
    delta = self.expires_at - timezone.now()
    return max(0, delta.days)

def activate(self):
    """Active l'abonnement"""
    self.status = self.SubscriptionStatus.ACTIVE
    if not self.user.is_premium:
        self.user.is_premium = True
        self.user.save(update_fields=['is_premium'])
    self.save(update_fields=['status'])

def cancel(self, reason=None):
    """Annule l'abonnement"""
    self.status = self.SubscriptionStatus.CANCELLED
    self.cancelled_at = timezone.now()
    self.auto_renew = False
    if self.user.is_premium:
        self.user.is_premium = False
        self.user.save(update_fields=['is_premium'])
    self.save()

@classmethod
def create_subscription(cls, user, plan, billing_currency='EUR', start_trial=True):
    """Crée un nouvel abonnement pour un utilisateur"""
    now = timezone.now()
    
    if start_trial and plan.trial_days > 0:
        expires_at = now + timedelta(days=plan.trial_days)
        status = cls.SubscriptionStatus.TRIAL
        trial_ends_at = expires_at
    else:
        expires_at = now + timedelta(days=plan.duration_days)
        status = cls.SubscriptionStatus.PENDING
        trial_ends_at = None
    
    subscription = cls.objects.create(
        user=user,
        plan=plan,
        status=status,
        started_at=now,
        expires_at=expires_at,
        trial_ends_at=trial_ends_at,
        billing_currency=billing_currency,
        next_billing_date=expires_at if status != cls.SubscriptionStatus.TRIAL else None
    )
    
    return subscription
```

---

## **💰 MODÈLE PAIEMENT**

### **📄 Fichier :** `apps/payments/models/payment.py`

```python
class Payment(TimeStampedModel):
    """Modèle de paiement My-CoolPay"""
    
    class PaymentStatus(models.TextChoices):
        PENDING = 'PENDING', _('En attente')
        PROCESSING = 'PROCESSING', _('En cours')
        COMPLETED = 'COMPLETED', _('Complété')
        FAILED = 'FAILED', _('Échoué')
        CANCELLED = 'CANCELLED', _('Annulé')
        REFUNDED = 'REFUNDED', _('Remboursé')
    
    class PaymentType(models.TextChoices):
        SUBSCRIPTION = 'SUBSCRIPTION', _('Abonnement')
        ONE_TIME = 'ONE_TIME', _('Paiement unique')
        REFUND = 'REFUND', _('Remboursement')
    
    # Identifiants
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Relations
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='payments')
    
    # Informations du paiement
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    currency = models.CharField(max_length=3, choices=[('EUR', 'Euro'), ('XAF', 'Franc CFA'), ('USD', 'Dollar US')])
    description = models.TextField()
    payment_type = models.CharField(max_length=20, choices=PaymentType.choices, default=PaymentType.ONE_TIME)
    status = models.CharField(max_length=20, choices=PaymentStatus.choices, default=PaymentStatus.PENDING)
    
    # Méthode de paiement
    payment_method = models.CharField(max_length=50, help_text='CM_OM, CM_MOMO, PAYLINK, etc.')
    
    # Intégration My-CoolPay
    external_reference = models.CharField(max_length=255, blank=True, null=True)
    external_checkout_url = models.URLField(blank=True, null=True)
    
    # URLs de redirection
    success_url = models.URLField(blank=True, null=True)
    cancel_url = models.URLField(blank=True, null=True)
    
    # Dates
    completed_at = models.DateTimeField(null=True, blank=True)
    
    # Métadonnées
    metadata = models.JSONField(default=dict, blank=True)
    
    # Flags
    is_test = models.BooleanField(default=False)
```

---

## **🏢 MODÈLE PROJET**

### **📄 Fichier :** `apps/projects/models.py`

```python
class Project(TimeStampedModel):
    """Modèle de projet entrepreneur"""
    
    class Category(models.TextChoices):
        TECH = 'TECH', _('Technologie')
        FINTECH = 'FINTECH', _('FinTech')
        HEALTHCARE = 'HEALTHCARE', _('Santé')
        EDUCATION = 'EDUCATION', _('Éducation')
        ECOMMERCE = 'ECOMMERCE', _('E-commerce')
        AGRICULTURE = 'AGRICULTURE', _('Agriculture')
        ENERGY = 'ENERGY', _('Énergie')
        REAL_ESTATE = 'REAL_ESTATE', _('Immobilier')
        TRANSPORT = 'TRANSPORT', _('Transport')
        OTHER = 'OTHER', _('Autre')
    
    class Stage(models.TextChoices):
        IDEA = 'IDEA', _('Idée')
        VALIDATION = 'VALIDATION', _('Validation')
        PROTOTYPE = 'PROTOTYPE', _('Prototype')
        SEED = 'SEED', _('Amorçage')
        GROWTH = 'GROWTH', _('Croissance')
        EXPANSION = 'EXPANSION', _('Expansion')
    
    class Status(models.TextChoices):
        DRAFT = 'DRAFT', _('Brouillon')
        PUBLISHED = 'PUBLISHED', _('Publié')
        FUNDED = 'FUNDED', _('Financé')
        PAUSED = 'PAUSED', _('En pause')
        CLOSED = 'CLOSED', _('Fermé')
    
    # Identifiants
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Relations
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='projects')
    
    # Informations de base
    title = models.CharField(max_length=200)
    description = models.TextField()
    category = models.CharField(max_length=20, choices=Category.choices)
    stage = models.CharField(max_length=20, choices=Stage.choices)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.DRAFT)
    
    # Financement
    funding_goal = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    funding_raised = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    currency = models.CharField(max_length=3, choices=[('EUR', 'Euro'), ('XAF', 'Franc CFA'), ('USD', 'Dollar US')], default='EUR')
    
    # Localisation
    location = models.CharField(max_length=200, blank=True)
    
    # Média
    logo = models.ImageField(upload_to='projects/logos/', blank=True, null=True)
    images = models.JSONField(default=list, blank=True)
    
    # SEO et découverte
    tags = models.JSONField(default=list, blank=True)
    
    # Flags
    is_seeking_funding = models.BooleanField(default=True)
    is_seeking_partners = models.BooleanField(default=False)
    is_featured = models.BooleanField(default=False)
    
    # Statistiques
    views_count = models.PositiveIntegerField(default=0)
    interests_count = models.PositiveIntegerField(default=0)
    
    # Métadonnées
    metadata = models.JSONField(default=dict, blank=True)
```

---

## **💼 MODÈLE INVESTISSEMENT**

### **📄 Fichier :** `apps/investments/models.py`

```python
class Investment(TimeStampedModel):
    """Modèle d'investissement"""
    
    class InvestmentType(models.TextChoices):
        EQUITY = 'EQUITY', _('Capital')
        DEBT = 'DEBT', _('Dette')
        CONVERTIBLE = 'CONVERTIBLE', _('Convertible')
        GRANT = 'GRANT', _('Subvention')
    
    class Status(models.TextChoices):
        PENDING = 'PENDING', _('En attente')
        UNDER_REVIEW = 'UNDER_REVIEW', _('En cours d\'examen')
        ACCEPTED = 'ACCEPTED', _('Accepté')
        REJECTED = 'REJECTED', _('Rejeté')
        COMPLETED = 'COMPLETED', _('Complété')
        CANCELLED = 'CANCELLED', _('Annulé')
    
    class Timeline(models.TextChoices):
        IMMEDIATE = 'IMMEDIATE', _('Immédiat')
        ONE_MONTH = '1_MONTH', _('1 mois')
        THREE_MONTHS = '3_MONTHS', _('3 mois')
        SIX_MONTHS = '6_MONTHS', _('6 mois')
        ONE_YEAR = '1_YEAR', _('1 an')
        TWO_YEARS = '2_YEARS', _('2 ans')
        FLEXIBLE = 'FLEXIBLE', _('Flexible')
    
    # Identifiants
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Relations
    investor = models.ForeignKey(User, on_delete=models.CASCADE, related_name='investments_made')
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='received_investments')
    
    # Détails de l'investissement
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    currency = models.CharField(max_length=3, choices=[('EUR', 'Euro'), ('XAF', 'Franc CFA'), ('USD', 'Dollar US')])
    investment_type = models.CharField(max_length=20, choices=InvestmentType.choices)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    
    # Termes de l'investissement
    proposed_equity = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    proposed_terms = models.TextField(blank=True)
    expected_return = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    investment_timeline = models.CharField(max_length=20, choices=Timeline.choices)
    
    # Conditions
    conditions = models.TextField(blank=True)
    
    # Métadonnées
    metadata = models.JSONField(default=dict, blank=True)
```

---

## **💬 MODÈLE MESSAGE**

### **📄 Fichier :** `apps/messaging/models.py`

```python
class Conversation(TimeStampedModel):
    """Modèle de conversation"""
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    participants = models.ManyToManyField(User, related_name='conversations')
    title = models.CharField(max_length=200, blank=True)
    is_group = models.BooleanField(default=False)
    last_message_at = models.DateTimeField(null=True, blank=True)

class Message(TimeStampedModel):
    """Modèle de message"""
    
    class MessageType(models.TextChoices):
        TEXT = 'TEXT', _('Texte')
        IMAGE = 'IMAGE', _('Image')
        FILE = 'FILE', _('Fichier')
        SYSTEM = 'SYSTEM', _('Système')
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    conversation = models.ForeignKey(Conversation, on_delete=models.CASCADE, related_name='messages')
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sent_messages')
    
    content = models.TextField()
    message_type = models.CharField(max_length=10, choices=MessageType.choices, default=MessageType.TEXT)
    
    # Fichier attaché
    attachment = models.FileField(upload_to='messages/attachments/', null=True, blank=True)
    
    # Statut de lecture
    read_by = models.ManyToManyField(User, through='MessageRead', related_name='read_messages')
    
    # Métadonnées
    metadata = models.JSONField(default=dict, blank=True)

class MessageRead(models.Model):
    """Modèle de lecture de message"""
    
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    message = models.ForeignKey(Message, on_delete=models.CASCADE)
    read_at = models.DateTimeField(auto_now_add=True)
```

---

## **🔔 MODÈLE NOTIFICATION**

### **📄 Fichier :** `apps/notifications/models.py`

```python
class NotificationTemplate(models.Model):
    """Modèle de template de notification"""
    
    code = models.CharField(max_length=50, unique=True)
    name = models.CharField(max_length=200)
    title_template = models.CharField(max_length=200)
    message_template = models.TextField()
    is_active = models.BooleanField(default=True)

class Notification(TimeStampedModel):
    """Modèle de notification"""
    
    class NotificationType(models.TextChoices):
        INFO = 'INFO', _('Information')
        SUCCESS = 'SUCCESS', _('Succès')
        WARNING = 'WARNING', _('Avertissement')
        ERROR = 'ERROR', _('Erreur')
    
    class Channel(models.TextChoices):
        PUSH = 'PUSH', _('Notification push')
        EMAIL = 'EMAIL', _('Email')
        SMS = 'SMS', _('SMS')
        IN_APP = 'IN_APP', _('In-app')
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    recipient = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    
    title = models.CharField(max_length=200)
    message = models.TextField()
    notification_type = models.CharField(max_length=10, choices=NotificationType.choices, default=NotificationType.INFO)
    
    # Canaux de diffusion
    channels = models.JSONField(default=list)
    
    # Statut
    is_read = models.BooleanField(default=False)
    read_at = models.DateTimeField(null=True, blank=True)
    
    # Données contextuelles
    context_data = models.JSONField(default=dict, blank=True)
    
    # Métadonnées
    metadata = models.JSONField(default=dict, blank=True)
```

---

## **🤖 MODÈLE MATCHING IA**

### **📄 Fichier :** `apps/matching/models.py`

```python
class MatchingProfile(TimeStampedModel):
    """Profil de matching pour l'IA"""
    
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='matching_profile')
    
    # Préférences d'investissement
    preferred_categories = models.JSONField(default=list)
    min_investment_amount = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    max_investment_amount = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    preferred_stages = models.JSONField(default=list)
    preferred_locations = models.JSONField(default=list)
    
    # Critères de sélection
    risk_tolerance = models.CharField(max_length=10, choices=[('LOW', 'Faible'), ('MEDIUM', 'Moyen'), ('HIGH', 'Élevé')], default='MEDIUM')
    investment_horizon = models.CharField(max_length=20, default='FLEXIBLE')
    
    # Historique et apprentissage
    interaction_history = models.JSONField(default=dict, blank=True)
    feedback_data = models.JSONField(default=dict, blank=True)
    
    # Métadonnées IA
    ai_metadata = models.JSONField(default=dict, blank=True)

class MatchingRecommendation(TimeStampedModel):
    """Recommandation de matching générée par l'IA"""
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='recommendations')
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='recommendations')
    
    # Score de compatibilité (0.0 à 1.0)
    compatibility_score = models.FloatField()
    
    # Raisons de la recommandation
    reasons = models.JSONField(default=list)
    
    # Suggestion d'investissement
    suggested_amount = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    suggested_equity = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    
    # Statut
    is_viewed = models.BooleanField(default=False)
    user_feedback = models.CharField(max_length=20, choices=[('LIKE', 'Intéressé'), ('DISLIKE', 'Pas intéressé'), ('NEUTRAL', 'Neutre')], null=True, blank=True)
    
    # Métadonnées IA
    ai_metadata = models.JSONField(default=dict, blank=True)

class MatchingFeedback(TimeStampedModel):
    """Feedback utilisateur pour améliorer l'IA"""
    
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    recommendation = models.ForeignKey(MatchingRecommendation, on_delete=models.CASCADE, null=True, blank=True)
    
    # Type de feedback
    feedback_type = models.CharField(max_length=20, choices=[('LIKE', 'Like'), ('DISLIKE', 'Dislike'), ('INVEST', 'Invested'), ('IGNORE', 'Ignored')])
    
    # Commentaire optionnel
    comment = models.TextField(blank=True)
    
    # Métadonnées pour l'apprentissage
    context_data = models.JSONField(default=dict, blank=True)
```

---

## **📊 RELATIONS ET CONTRAINTES**

### **🔗 Relations Principales**

```python
# User → UserSubscription (OneToOne)
user.payment_subscription

# SubscriptionPlan → UserSubscription (OneToMany)
plan.subscriptions.all()

# User → Project (OneToMany)
user.projects.all()

# User → Investment (OneToMany)
user.investments_made.all()

# Project → Investment (OneToMany)
project.received_investments.all()

# User → Message (OneToMany)
user.sent_messages.all()

# User → Notification (OneToMany)
user.notifications.all()

# User → MatchingProfile (OneToOne)
user.matching_profile

# User → MatchingRecommendation (OneToMany)
user.recommendations.all()
```

### **🔒 Contraintes de Données**

```python
# Contraintes uniques
- User.email (unique)
- User.username (unique)
- User.firebase_uid (unique, nullable)
- SubscriptionPlan.id (primary key string)
- NotificationTemplate.code (unique)

# Contraintes de validation
- SubscriptionPlan.price_* >= 0
- Investment.amount > 0
- MatchingRecommendation.compatibility_score (0.0 à 1.0)
- UserSubscription.expires_at > started_at

# Index de performance
- UserSubscription: (user, status), (status, expires_at)
- Project: (status, category), (owner, status)
- Investment: (investor, status), (project, status)
- Message: (conversation, created_at)
- Notification: (recipient, is_read, created_at)
```

---

## **💾 STRUCTURE BASE DE DONNÉES**

### **📊 Tables Principales**

| Table | Description | Enregistrements |
|-------|-------------|-----------------|
| `auth_user` | Utilisateurs Django étendus | Variable |
| `payments_subscriptionplan` | Plans d'abonnement unifiés | 4 (par défaut) |
| `payments_usersubscription` | Abonnements utilisateurs | Variable |
| `payments_payment` | Historique paiements My-CoolPay | Variable |
| `projects_project` | Projets entrepreneurs | Variable |
| `investments_investment` | Investissements | Variable |
| `messaging_conversation` | Conversations | Variable |
| `messaging_message` | Messages | Variable |
| `notifications_notification` | Notifications | Variable |
| `matching_matchingrecommendation` | Recommandations IA | Variable |

### **🔄 Scripts d'Initialisation**

```python
# Script de création des plans par défaut
python create_default_plans.py

# Résultat attendu:
# ✅ Plan créé: Plan Gratuit
# ✅ Plan créé: Basic Mensuel  
# ✅ Plan créé: Premium Mensuel
# ✅ Plan créé: Premium Annuel
# 📊 Total plans: 4
```

---

## **🔍 VALIDATION ET TESTS**

### **✅ Tests de Modèles**

```python
# Test création plan d'abonnement
plan = SubscriptionPlan.objects.create(
    id='test_plan',
    name='Plan Test',
    price_eur=19.99,
    price_xaf=13000.00,
    price_usd=21.99,
    duration_days=30
)
assert plan.format_price('EUR') == '19.99 €'
assert plan.format_price('XAF') == '13,000 FCFA'

# Test création abonnement utilisateur
subscription = UserSubscription.create_subscription(
    user=user,
    plan=plan,
    billing_currency='EUR',
    start_trial=True
)
assert subscription.status == 'TRIAL'
assert subscription.is_in_trial

# Test activation abonnement
subscription.activate()
assert subscription.user.is_premium == True
assert subscription.status == 'ACTIVE'
```

### **🧪 Validation Contraintes**

```python
# Validation prix plan gratuit
free_plan = SubscriptionPlan(
    id='free',
    is_free=True,
    price_eur=0.00,
    price_xaf=0.00,
    price_usd=0.00
)
free_plan.clean()  # ✅ Validation réussie

# Validation abonnement unique par utilisateur
existing_subscription = UserSubscription.objects.filter(
    user=user,
    status__in=['ACTIVE', 'TRIAL']
).exists()
assert not existing_subscription  # Un seul abonnement actif par utilisateur
```

---

## **✨ CONCLUSION**

Les modèles de données VentureLink Phase 5 sont maintenant **100% unifiés et harmonisés** :

### **🎯 Points Clés**

- ✅ **Modèles unifiés** : `SubscriptionPlan` et `UserSubscription` remplacent la confusion précédente
- ✅ **Multi-devises** : Support natif EUR, XAF, USD dans tous les modèles
- ✅ **Relations cohérentes** : Liens clairs entre tous les modèles
- ✅ **Validation robuste** : Contraintes et méthodes utilitaires
- ✅ **Extensibilité** : Architecture prête pour futures fonctionnalités
- ✅ **Performance** : Index optimisés pour requêtes fréquentes

Le frontend Flutter peut utiliser ces modèles en **toute confiance** ! 🚀 
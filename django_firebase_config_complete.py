#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Configuration complète Firebase pour Django - VentureLink
Guide étape par étape pour une authentification Firebase fonctionnelle
"""

# ============================================================================
# 1. INSTALLATION DES DÉPENDANCES DJANGO
# ============================================================================

"""
Dans votre environnement virtuel Django, installez :

pip install firebase-admin
pip install python-jose[cryptography]
pip install requests
"""

# ============================================================================
# 2. CONFIGURATION SETTINGS.PY
# ============================================================================

DJANGO_SETTINGS_FIREBASE = """
# Dans settings.py

import os
import json
from pathlib import Path

# Configuration Firebase
FIREBASE_CONFIG = {
    'type': 'service_account',
    'project_id': 'venturelink-5b045',
    'private_key_id': os.getenv('FIREBASE_PRIVATE_KEY_ID', ''),
    'private_key': os.getenv('FIREBASE_PRIVATE_KEY', '').replace('\\n', '\n'),
    'client_email': os.getenv('FIREBASE_CLIENT_EMAIL', ''),
    'client_id': os.getenv('FIREBASE_CLIENT_ID', ''),
    'auth_uri': 'https://accounts.google.com/o/oauth2/auth',
    'token_uri': 'https://oauth2.googleapis.com/token',
    'auth_provider_x509_cert_url': 'https://www.googleapis.com/oauth2/v1/certs',
    'client_x509_cert_url': f'https://www.googleapis.com/robot/v1/metadata/x509/{os.getenv("FIREBASE_CLIENT_EMAIL", "")}'
}

# Configuration pour le développement (plus permissive)
FIREBASE_DEV_MODE = True  # Mettre False en production

# REST Framework avec Firebase
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'apps.core.authentication.FirebaseAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'apps.core.permissions.FirebasePermission',  # Permission personnalisée
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
}

# Middleware Firebase
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'apps.core.middleware.FirebaseAuthenticationMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# CORS pour Flutter
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://10.0.2.2:8000",  # Émulateur Android
]

CORS_ALLOW_CREDENTIALS = True
"""

# ============================================================================
# 3. AUTHENTIFICATION FIREBASE PERSONNALISÉE
# ============================================================================

FIREBASE_AUTHENTICATION_CLASS = '''
# apps/core/authentication.py

import firebase_admin
from firebase_admin import auth, credentials
from rest_framework import authentication, exceptions
from django.contrib.auth import get_user_model
from django.conf import settings
import logging

logger = logging.getLogger(__name__)
User = get_user_model()

class FirebaseAuthentication(authentication.BaseAuthentication):
    """
    Authentification Firebase pour Django REST Framework
    """
    
    def __init__(self):
        if not firebase_admin._apps:
            try:
                # Initialiser Firebase Admin SDK
                if hasattr(settings, 'FIREBASE_CONFIG') and settings.FIREBASE_CONFIG.get('private_key'):
                    cred = credentials.Certificate(settings.FIREBASE_CONFIG)
                    firebase_admin.initialize_app(cred)
                    logger.info("Firebase Admin SDK initialisé avec succès")
                else:
                    logger.warning("Configuration Firebase manquante, mode développement activé")
            except Exception as e:
                logger.error(f"Erreur initialisation Firebase: {e}")
    
    def authenticate(self, request):
        """
        Authentifier l'utilisateur via Firebase token
        """
        auth_header = request.META.get('HTTP_AUTHORIZATION')
        
        if not auth_header:
            # En mode développement, permettre l'accès sans token pour certains endpoints
            if getattr(settings, 'FIREBASE_DEV_MODE', False):
                return self._create_anonymous_user(request)
            return None
        
        try:
            # Extraire le token
            if auth_header.startswith('Bearer '):
                token = auth_header.split(' ')[1]
            elif auth_header.startswith('Firebase '):
                token = auth_header.split(' ')[1]
            else:
                return None
            
            # Vérifier le token Firebase
            decoded_token = auth.verify_id_token(token)
            firebase_uid = decoded_token['uid']
            
            # Récupérer ou créer l'utilisateur Django
            user = self._get_or_create_user(decoded_token)
            
            return (user, decoded_token)
            
        except auth.InvalidIdTokenError:
            logger.warning("Token Firebase invalide")
            if getattr(settings, 'FIREBASE_DEV_MODE', False):
                return self._create_anonymous_user(request)
            raise exceptions.AuthenticationFailed('Token Firebase invalide')
            
        except Exception as e:
            logger.error(f"Erreur authentification Firebase: {e}")
            if getattr(settings, 'FIREBASE_DEV_MODE', False):
                return self._create_anonymous_user(request)
            raise exceptions.AuthenticationFailed('Erreur authentification')
    
    def _get_or_create_user(self, decoded_token):
        """
        Récupérer ou créer un utilisateur Django à partir du token Firebase
        """
        firebase_uid = decoded_token['uid']
        email = decoded_token.get('email', '')
        name = decoded_token.get('name', '')
        
        try:
            # Chercher par email d'abord
            if email:
                user = User.objects.get(email=email)
            else:
                # Chercher par firebase_uid si pas d'email
                user = User.objects.get(firebase_uid=firebase_uid)
                
        except User.DoesNotExist:
            # Créer un nouvel utilisateur
            first_name = name.split(' ')[0] if name else 'Utilisateur'
            last_name = ' '.join(name.split(' ')[1:]) if len(name.split(' ')) > 1 else 'Firebase'
            
            user = User.objects.create(
                email=email or f"{firebase_uid}@firebase.local",
                first_name=first_name,
                last_name=last_name,
                firebase_uid=firebase_uid,
                is_active=True,
                user_type='BOTH'  # Type par défaut
            )
            logger.info(f"Nouvel utilisateur créé: {user.email}")
        
        # Mettre à jour le firebase_uid si nécessaire
        if not hasattr(user, 'firebase_uid') or not user.firebase_uid:
            user.firebase_uid = firebase_uid
            user.save()
        
        return user
    
    def _create_anonymous_user(self, request):
        """
        Créer un utilisateur anonyme pour le mode développement
        """
        try:
            user, created = User.objects.get_or_create(
                email='dev@venturelink.local',
                defaults={
                    'first_name': 'Dev',
                    'last_name': 'User',
                    'user_type': 'BOTH',
                    'is_active': True,
                    'firebase_uid': 'dev-user-uid'
                }
            )
            return (user, {'uid': 'dev-user-uid', 'email': 'dev@venturelink.local'})
        except Exception as e:
            logger.error(f"Erreur création utilisateur dev: {e}")
            return None
'''

# ============================================================================
# 4. PERMISSIONS PERSONNALISÉES
# ============================================================================

FIREBASE_PERMISSIONS_CLASS = '''
# apps/core/permissions.py

from rest_framework import permissions
from django.conf import settings
import logging

logger = logging.getLogger(__name__)

class FirebasePermission(permissions.BasePermission):
    """
    Permission personnalisée pour Firebase avec mode développement
    """
    
    def has_permission(self, request, view):
        """
        Vérifier les permissions au niveau de la vue
        """
        # En mode développement, être plus permissif
        if getattr(settings, 'FIREBASE_DEV_MODE', False):
            # Permettre l'accès en lecture pour les endpoints publics
            if request.method in permissions.SAFE_METHODS:
                return True
            # Pour les modifications, vérifier l'authentification
            return request.user and request.user.is_authenticated
        
        # En production, exiger l'authentification
        return request.user and request.user.is_authenticated
    
    def has_object_permission(self, request, view, obj):
        """
        Vérifier les permissions au niveau de l'objet
        """
        # Lecture publique en mode dev
        if getattr(settings, 'FIREBASE_DEV_MODE', False) and request.method in permissions.SAFE_METHODS:
            return True
        
        # Propriétaire ou admin
        if hasattr(obj, 'creator'):
            return obj.creator == request.user or request.user.is_staff
        elif hasattr(obj, 'user'):
            return obj.user == request.user or request.user.is_staff
        
        return request.user.is_staff

class IsOwnerOrReadOnly(permissions.BasePermission):
    """
    Permission pour propriétaire ou lecture seule
    """
    
    def has_object_permission(self, request, view, obj):
        # Lecture pour tous
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # Écriture pour le propriétaire uniquement
        return obj.creator == request.user if hasattr(obj, 'creator') else False
'''

# ============================================================================
# 5. MIDDLEWARE FIREBASE
# ============================================================================

FIREBASE_MIDDLEWARE_CLASS = '''
# apps/core/middleware.py

import logging
from django.utils.deprecation import MiddlewareMixin
from django.contrib.auth import get_user_model
from django.conf import settings

logger = logging.getLogger(__name__)
User = get_user_model()

class FirebaseAuthenticationMiddleware(MiddlewareMixin):
    """
    Middleware pour gérer l'authentification Firebase
    """
    
    def process_request(self, request):
        """
        Traiter la requête pour l'authentification Firebase
        """
        # Ajouter des headers CORS si nécessaire
        if hasattr(settings, 'FIREBASE_DEV_MODE') and settings.FIREBASE_DEV_MODE:
            # En mode dev, ajouter des headers permissifs
            pass
        
        return None
    
    def process_response(self, request, response):
        """
        Traiter la réponse
        """
        # Ajouter des headers CORS pour Firebase
        if hasattr(settings, 'FIREBASE_DEV_MODE') and settings.FIREBASE_DEV_MODE:
            response['Access-Control-Allow-Origin'] = '*'
            response['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
            response['Access-Control-Allow-Headers'] = 'Authorization, Content-Type'
        
        return response
'''

# ============================================================================
# 6. MODÈLE UTILISATEUR ÉTENDU
# ============================================================================

USER_MODEL_EXTENSION = '''
# Dans apps/users/models.py, ajoutez le champ firebase_uid

from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    # ... autres champs existants ...
    
    firebase_uid = models.CharField(
        max_length=128, 
        unique=True, 
        null=True, 
        blank=True,
        help_text="UID Firebase de l'utilisateur"
    )
    
    class Meta:
        db_table = 'users_user'
        verbose_name = 'Utilisateur'
        verbose_name_plural = 'Utilisateurs'

# N'oubliez pas de créer et appliquer la migration :
# python manage.py makemigrations
# python manage.py migrate
'''

# ============================================================================
# 7. VARIABLES D'ENVIRONNEMENT
# ============================================================================

ENV_VARIABLES = '''
# Créez un fichier .env dans votre projet Django avec :

FIREBASE_PRIVATE_KEY_ID=your_private_key_id_here
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@venturelink-5b045.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your_client_id_here

# Pour charger les variables d'environnement, ajoutez dans settings.py :
from dotenv import load_dotenv
load_dotenv()

# Ou installez python-decouple :
# pip install python-decouple
from decouple import config
FIREBASE_PRIVATE_KEY = config('FIREBASE_PRIVATE_KEY')
'''

print("Configuration Firebase complète créée!")
print("Consultez les sections ci-dessus pour configurer Firebase dans Django.") 
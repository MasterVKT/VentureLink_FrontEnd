#!/usr/bin/env python3
"""
Script pour configurer les permissions Django et permettre l'accès anonyme
pendant le développement de VentureLink
"""

import os
import sys
import requests
import json

def test_current_permissions():
    """Tester les permissions actuelles"""
    print("🔍 Test des permissions actuelles...")
    
    endpoints = {
        'projects': '/api/v1/projects/',
        'categories': '/api/v1/projects/categories/',
        'tags': '/api/v1/projects/tags/',
        'publications': '/api/v1/content/publications/',
    }
    
    base_url = 'http://127.0.0.1:8000'
    
    for name, endpoint in endpoints.items():
        try:
            response = requests.get(f"{base_url}{endpoint}", timeout=5)
            if response.status_code == 200:
                print(f"✅ {name} - Accessible (200)")
            elif response.status_code == 401:
                print(f"🔐 {name} - Authentification requise (401)")
            elif response.status_code == 404:
                print(f"❌ {name} - Non trouvé (404)")
            else:
                print(f"⚠️  {name} - Status: {response.status_code}")
        except Exception as e:
            print(f"❌ {name} - Erreur: {e}")

def create_django_settings_patch():
    """Créer un patch pour les settings Django"""
    print("\n🔧 Création du patch pour les permissions Django...")
    
    patch_content = '''
# Patch temporaire pour les permissions Django - VentureLink
# À ajouter dans settings.py pour permettre l'accès anonyme pendant le développement

# Configuration REST Framework pour le développement
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.SessionAuthentication',
        'rest_framework.authentication.TokenAuthentication',
        # 'apps.core.authentication.FirebaseAuthentication',  # Désactivé temporairement
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',  # Permet l'accès anonyme
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ],
}

# Configuration CORS pour le développement
CORS_ALLOW_ALL_ORIGINS = True  # Attention: uniquement pour le développement
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://10.0.2.2:8000",
]

# Désactiver temporairement le middleware Firebase
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    # 'apps.core.middleware.FirebaseAuthenticationMiddleware',  # Désactivé temporairement
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

print("✅ Configuration temporaire appliquée pour le développement")
print("⚠️  N'oubliez pas de réactiver l'authentification Firebase en production!")
'''
    
    with open('django_dev_settings_patch.py', 'w', encoding='utf-8') as f:
        f.write(patch_content)
    
    print("✅ Patch créé dans 'django_dev_settings_patch.py'")

def create_viewset_patches():
    """Créer des patches pour les ViewSets Django"""
    print("\n🔧 Création des patches pour les ViewSets...")
    
    viewset_patches = {
        'projects_viewset.py': '''
# Patch pour ProjectViewSet - VentureLink
# À appliquer dans apps/projects/views.py

from rest_framework.permissions import AllowAny
from rest_framework.decorators import action
from rest_framework.response import Response

class ProjectViewSet(viewsets.ModelViewSet):
    """ViewSet pour les projets avec permissions temporaires"""
    
    permission_classes = [AllowAny]  # Temporaire pour le développement
    
    def get_queryset(self):
        """Retourner tous les projets publiés"""
        return Project.objects.filter(is_draft=False, status='ACTIVE')
    
    @action(detail=False, methods=['get'])
    def trending(self, request):
        """Projets tendance"""
        days = int(request.query_params.get('days', 7))
        limit = int(request.query_params.get('limit', 10))
        
        # Logique simplifiée pour les projets tendance
        projects = self.get_queryset().order_by('-views_count')[:limit]
        serializer = self.get_serializer(projects, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def featured(self, request):
        """Projets mis en avant"""
        limit = int(request.query_params.get('limit', 10))
        projects = self.get_queryset().filter(is_featured=True)[:limit]
        serializer = self.get_serializer(projects, many=True)
        return Response(serializer.data)
''',
        
        'content_viewset.py': '''
# Patch pour ContentViewSet - VentureLink
# À appliquer dans apps/content/views.py

from rest_framework.permissions import AllowAny

class PublicationViewSet(viewsets.ModelViewSet):
    """ViewSet pour les publications avec permissions temporaires"""
    
    permission_classes = [AllowAny]  # Temporaire pour le développement
    
    def get_queryset(self):
        """Retourner toutes les publications publiées"""
        return Publication.objects.filter(status='PUBLISHED')
    
    @action(detail=False, methods=['get'])
    def featured(self, request):
        """Publications mises en avant"""
        limit = int(request.query_params.get('limit', 10))
        publications = self.get_queryset().filter(is_featured=True)[:limit]
        serializer = self.get_serializer(publications, many=True)
        return Response(serializer.data)
'''
    }
    
    for filename, content in viewset_patches.items():
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✅ Patch créé: {filename}")

def create_management_command():
    """Créer une commande de gestion Django pour créer des données de test"""
    print("\n🔧 Création de la commande de gestion Django...")
    
    command_content = '''
# Commande Django pour créer des données de test
# À placer dans apps/projects/management/commands/create_test_data.py

from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from apps.projects.models import Project, ProjectCategory, ProjectTag
from apps.content.models import Publication

User = get_user_model()

class Command(BaseCommand):
    help = 'Crée des données de test pour VentureLink'
    
    def handle(self, *args, **options):
        self.stdout.write('🚀 Création des données de test...')
        
        # Créer un utilisateur admin
        admin_user, created = User.objects.get_or_create(
            email='admin@venturelink.com',
            defaults={
                'first_name': 'Admin',
                'last_name': 'VentureLink',
                'user_type': 'ADMIN',
                'is_staff': True,
                'is_superuser': True,
            }
        )
        
        if created:
            admin_user.set_password('admin123')
            admin_user.save()
            self.stdout.write('✅ Utilisateur admin créé')
        
        # Créer des catégories
        categories_data = [
            {'name_fr': 'Technologie', 'name_en': 'Technology', 'icon': 'tech'},
            {'name_fr': 'Santé', 'name_en': 'Health', 'icon': 'health'},
            {'name_fr': 'Éducation', 'name_en': 'Education', 'icon': 'education'},
        ]
        
        for cat_data in categories_data:
            category, created = ProjectCategory.objects.get_or_create(
                name_fr=cat_data['name_fr'],
                defaults=cat_data
            )
            if created:
                self.stdout.write(f'✅ Catégorie créée: {category.name_fr}')
        
        # Créer des tags
        tags_data = [
            {'name_fr': 'IA', 'name_en': 'AI'},
            {'name_fr': 'Mobile', 'name_en': 'Mobile'},
            {'name_fr': 'Web', 'name_en': 'Web'},
        ]
        
        for tag_data in tags_data:
            tag, created = ProjectTag.objects.get_or_create(
                name_fr=tag_data['name_fr'],
                defaults=tag_data
            )
            if created:
                self.stdout.write(f'✅ Tag créé: {tag.name_fr}')
        
        self.stdout.write('✅ Données de test créées avec succès!')
'''
    
    with open('create_test_data_command.py', 'w', encoding='utf-8') as f:
        f.write(command_content)
    
    print("✅ Commande de gestion créée: create_test_data_command.py")

def main():
    """Fonction principale"""
    print("🚀 Configuration des permissions Django pour VentureLink")
    print("="*60)
    
    # Tester les permissions actuelles
    test_current_permissions()
    
    # Créer les patches
    create_django_settings_patch()
    create_viewset_patches()
    create_management_command()
    
    print("\n" + "="*60)
    print("✅ Configuration terminée!")
    print("\n📋 Étapes suivantes:")
    print("1. Appliquez le contenu de 'django_dev_settings_patch.py' dans votre settings.py")
    print("2. Appliquez les patches des ViewSets dans vos vues Django")
    print("3. Redémarrez le serveur Django")
    print("4. Testez l'application Flutter")
    print("\n⚠️  N'oubliez pas de réactiver l'authentification Firebase en production!")

if __name__ == "__main__":
    main() 
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour diagnostiquer et résoudre les problèmes d'authentification Django
pour VentureLink
"""

import requests
import json

def test_endpoints():
    """Tester les endpoints Django"""
    print("🔍 Test des endpoints Django...")
    
    base_url = "http://127.0.0.1:8000/api/v1"
    
    endpoints = {
        "Categories": "/projects/categories/",
        "Tags": "/projects/tags/", 
        "Projects": "/projects/",
        "Publications": "/content/publications/"
    }
    
    results = {}
    
    for name, endpoint in endpoints.items():
        try:
            response = requests.get(f"{base_url}{endpoint}", timeout=5)
            results[name] = response.status_code
            
            if response.status_code == 200:
                print(f"✅ {name}: OK (200)")
            elif response.status_code == 401:
                print(f"🔐 {name}: Authentification requise (401)")
            else:
                print(f"⚠️  {name}: Status {response.status_code}")
                
        except Exception as e:
            print(f"❌ {name}: Erreur - {e}")
            results[name] = "error"
    
    return results

def create_django_patch():
    """Créer un patch pour Django"""
    print("\n🔧 Création du patch Django...")
    
    patch_content = '''
# PATCH TEMPORAIRE POUR VENTURELINK - À APPLIQUER DANS LE BACKEND DJANGO
# =====================================================================

# 1. Dans settings.py, modifiez REST_FRAMEWORK:
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',  # Temporaire pour développement
    ],
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.SessionAuthentication',
    ],
}

# 2. Dans apps/projects/views.py, ajoutez:
from rest_framework.permissions import AllowAny

class ProjectViewSet(viewsets.ModelViewSet):
    permission_classes = [AllowAny]  # Temporaire
    
    def get_queryset(self):
        return Project.objects.filter(is_draft=False)

# 3. Dans apps/content/views.py, ajoutez:
class PublicationViewSet(viewsets.ModelViewSet):
    permission_classes = [AllowAny]  # Temporaire
    
    def get_queryset(self):
        return Publication.objects.filter(status='PUBLISHED')

# 4. Redémarrez le serveur Django:
# python manage.py runserver

# ⚠️  N'oubliez pas de réactiver l'authentification en production!
'''
    
    with open('django_auth_patch.txt', 'w', encoding='utf-8') as f:
        f.write(patch_content)
    
    print("✅ Patch créé dans 'django_auth_patch.txt'")

def main():
    """Fonction principale"""
    print("🚀 Diagnostic d'authentification Django - VentureLink")
    print("=" * 60)
    
    # Tester les endpoints
    results = test_endpoints()
    
    # Analyser les résultats
    auth_required = [name for name, status in results.items() if status == 401]
    working = [name for name, status in results.items() if status == 200]
    
    print(f"\n📊 Résultats:")
    print(f"   ✅ Fonctionnels: {', '.join(working) if working else 'Aucun'}")
    print(f"   🔐 Authentification requise: {', '.join(auth_required) if auth_required else 'Aucun'}")
    
    if auth_required:
        print(f"\n💡 Solution: Modifier les permissions Django pour permettre l'accès anonyme")
        create_django_patch()
        
        print(f"\n📋 Étapes à suivre:")
        print(f"1. Appliquez le contenu de 'django_auth_patch.txt' dans votre backend Django")
        print(f"2. Redémarrez le serveur Django")
        print(f"3. Testez l'application Flutter")
    else:
        print(f"\n✅ Tous les endpoints sont accessibles!")
    
    print(f"\n⚠️  Important: Réactivez l'authentification Firebase en production!")

if __name__ == "__main__":
    main()
import requests
print('Test Django endpoints')
response = requests.get('http://127.0.0.1:8000/api/v1/projects/categories/')
print(f'Categories: {response.status_code}')
response = requests.get('http://127.0.0.1:8000/api/v1/projects/')
print(f'Projects: {response.status_code}')

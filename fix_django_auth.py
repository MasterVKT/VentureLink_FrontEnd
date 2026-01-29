#!/usr/bin/env python3
"""
Script pour diagnostiquer et corriger les problèmes d'authentification Django
Utilise des requêtes HTTP directes vers l'API Django en cours d'exécution
"""

import requests
import json
import sys
from datetime import datetime

# Configuration
DJANGO_BASE_URL = "http://127.0.0.1:8000"  # ou http://10.0.2.2:8000 pour émulateur
API_BASE_URL = f"{DJANGO_BASE_URL}/api/v1"

def test_django_server():
    """Tester si le serveur Django est accessible"""
    print("🔍 Test de connectivité au serveur Django...")
    
    try:
        response = requests.get(f"{DJANGO_BASE_URL}/", timeout=10)
        print(f"✅ Serveur Django accessible - Status: {response.status_code}")
        return True
    except requests.exceptions.RequestException as e:
        print(f"❌ Serveur Django inaccessible: {e}")
        return False

def test_api_endpoints():
    """Tester les endpoints de l'API"""
    print("\n🔍 Test des endpoints API...")
    
    endpoints = [
        "/projects/",
        "/projects/categories/",
        "/projects/tags/",
        "/content/publications/",
        "/users/me/"
    ]
    
    results = {}
    
    for endpoint in endpoints:
        try:
            url = f"{API_BASE_URL}{endpoint}"
            response = requests.get(url, timeout=10)
            results[endpoint] = {
                'status': response.status_code,
                'accessible': response.status_code != 404
            }
            
            if response.status_code == 200:
                print(f"✅ {endpoint} - OK (200)")
            elif response.status_code == 401:
                print(f"🔐 {endpoint} - Authentification requise (401)")
            elif response.status_code == 404:
                print(f"❌ {endpoint} - Non trouvé (404)")
            else:
                print(f"⚠️  {endpoint} - Status: {response.status_code}")
                
        except requests.exceptions.RequestException as e:
            print(f"❌ {endpoint} - Erreur: {e}")
            results[endpoint] = {'status': 'error', 'accessible': False}
    
    return results

def create_test_user():
    """Créer un utilisateur de test via l'API"""
    print("\n🔍 Tentative de création d'un utilisateur de test...")
    
    # Essayer de créer un utilisateur via l'API d'inscription
    user_data = {
        "email": "test@venturelink.com",
        "password": "TestPassword123!",
        "password_confirmation": "TestPassword123!",
        "first_name": "Test",
        "last_name": "User",
        "account_type": "PERSONAL",
        "user_type": "BOTH",
        "terms_accepted": True
    }
    
    try:
        response = requests.post(
            f"{API_BASE_URL}/auth/register/",
            json=user_data,
            headers={'Content-Type': 'application/json'},
            timeout=10
        )
        
        if response.status_code == 201:
            print("✅ Utilisateur de test créé avec succès")
            return True
        elif response.status_code == 400:
            # L'utilisateur existe peut-être déjà
            print("⚠️  Utilisateur existe peut-être déjà")
            return True
        else:
            print(f"❌ Échec création utilisateur - Status: {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Erreur lors de la création d'utilisateur: {e}")
        return False

def test_authentication():
    """Tester l'authentification"""
    print("\n🔍 Test de l'authentification...")
    
    # Essayer de se connecter avec l'utilisateur de test
    login_data = {
        "email": "test@venturelink.com",
        "password": "TestPassword123!"
    }
    
    try:
        response = requests.post(
            f"{API_BASE_URL}/auth/token/",
            json=login_data,
            headers={'Content-Type': 'application/json'},
            timeout=10
        )
        
        if response.status_code == 200:
            data = response.json()
            access_token = data.get('access')
            print("✅ Authentification réussie")
            return access_token
        else:
            print(f"❌ Échec authentification - Status: {response.status_code}")
            print(f"Response: {response.text}")
            return None
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Erreur lors de l'authentification: {e}")
        return None

def test_authenticated_endpoints(token):
    """Tester les endpoints avec authentification"""
    print("\n🔍 Test des endpoints avec authentification...")
    
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    
    endpoints = [
        "/users/me/",
        "/projects/",
        "/content/publications/"
    ]
    
    for endpoint in endpoints:
        try:
            url = f"{API_BASE_URL}{endpoint}"
            response = requests.get(url, headers=headers, timeout=10)
            
            if response.status_code == 200:
                print(f"✅ {endpoint} - OK avec authentification")
            else:
                print(f"❌ {endpoint} - Status: {response.status_code}")
                
        except requests.exceptions.RequestException as e:
            print(f"❌ {endpoint} - Erreur: {e}")

def create_test_data():
    """Créer des données de test via l'API"""
    print("\n🔍 Création de données de test...")
    
    # D'abord, obtenir un token d'authentification
    token = test_authentication()
    if not token:
        print("❌ Impossible d'obtenir un token d'authentification")
        return False
    
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    
    # Créer une catégorie de test
    category_data = {
        "name_fr": "Technologie Test",
        "name_en": "Technology Test",
        "description_fr": "Catégorie de test pour la technologie",
        "description_en": "Test category for technology",
        "icon": "tech"
    }
    
    try:
        response = requests.post(
            f"{API_BASE_URL}/projects/categories/",
            json=category_data,
            headers=headers,
            timeout=10
        )
        
        if response.status_code in [200, 201]:
            print("✅ Catégorie de test créée")
        else:
            print(f"⚠️  Catégorie - Status: {response.status_code}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Erreur création catégorie: {e}")
    
    return True

def fix_permissions():
    """Suggestions pour corriger les permissions"""
    print("\n🔧 Suggestions pour corriger les problèmes d'authentification:")
    print("="*60)
    
    print("\n1. Configuration temporaire pour le développement:")
    print("   Modifiez les permissions dans vos vues Django pour permettre l'accès anonyme")
    
    print("\n2. Dans vos ViewSets Django, utilisez:")
    print("   permission_classes = [AllowAny]  # Temporaire pour debug")
    
    print("\n3. Vérifiez que les URLs sont correctement configurées")
    
    print("\n✅ Diagnostic terminé.")

def main():
    """Fonction principale"""
    print("🚀 Diagnostic de l'authentification Django")
    print("="*60)
    
    # Test de connectivité
    if not test_django_server():
        print("\n❌ Le serveur Django n'est pas accessible.")
        print("Assurez-vous que le serveur Django fonctionne sur http://127.0.0.1:8000")
        return
    
    # Test des endpoints
    api_results = test_api_endpoints()
    
    # Créer un utilisateur de test
    create_test_user()
    
    # Tester l'authentification
    token = test_authentication()
    
    if token:
        # Tester les endpoints authentifiés
        test_authenticated_endpoints(token)
        
        # Créer des données de test
        create_test_data()
    
    # Afficher les suggestions de correction
    fix_permissions()
    
    print("\n" + "="*60)
    print("✅ Diagnostic terminé. Consultez les suggestions ci-dessus.")

if __name__ == "__main__":
    main() 
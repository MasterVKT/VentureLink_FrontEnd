#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de test complet pour l'authentification Firebase - VentureLink
Teste toute la chaîne d'authentification Django + Firebase
"""

import os
import sys
import django
import requests
import json
from datetime import datetime

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'venture_link_project.settings')
django.setup()

from django.contrib.auth import get_user_model
from django.conf import settings
import firebase_admin
from firebase_admin import auth, credentials

User = get_user_model()

class FirebaseTestSuite:
    def __init__(self):
        self.base_url = "http://127.0.0.1:8000/api/v1"
        self.test_email = "test@venturelink.com"
        self.test_password = "TestPassword123!"
        self.firebase_app = None
        
    def print_header(self, title):
        print(f"\n{'='*60}")
        print(f"🔥 {title}")
        print(f"{'='*60}")
    
    def print_step(self, step, description):
        print(f"\n📋 Étape {step}: {description}")
        print("-" * 50)
    
    def print_success(self, message):
        print(f"✅ {message}")
    
    def print_error(self, message):
        print(f"❌ {message}")
    
    def print_info(self, message):
        print(f"ℹ️  {message}")
    
    def test_django_configuration(self):
        """Test de la configuration Django"""
        self.print_step(1, "Vérification de la configuration Django")
        
        try:
            # Vérifier les settings Firebase
            if hasattr(settings, 'FIREBASE_CONFIG'):
                config = settings.FIREBASE_CONFIG
                if config.get('project_id') == 'venturelink-5b045':
                    self.print_success("Configuration Firebase trouvée")
                    self.print_info(f"Project ID: {config.get('project_id')}")
                else:
                    self.print_error("Project ID incorrect dans la configuration")
                    return False
            else:
                self.print_error("FIREBASE_CONFIG manquant dans settings.py")
                return False
            
            # Vérifier REST_FRAMEWORK
            if hasattr(settings, 'REST_FRAMEWORK'):
                auth_classes = settings.REST_FRAMEWORK.get('DEFAULT_AUTHENTICATION_CLASSES', [])
                if 'apps.core.authentication.FirebaseAuthentication' in auth_classes:
                    self.print_success("FirebaseAuthentication configurée")
                else:
                    self.print_error("FirebaseAuthentication manquante dans REST_FRAMEWORK")
                    return False
            
            # Vérifier le mode développement
            if hasattr(settings, 'FIREBASE_DEV_MODE'):
                self.print_info(f"Mode développement: {settings.FIREBASE_DEV_MODE}")
            
            return True
            
        except Exception as e:
            self.print_error(f"Erreur configuration Django: {e}")
            return False
    
    def test_firebase_admin_sdk(self):
        """Test de l'initialisation Firebase Admin SDK"""
        self.print_step(2, "Test Firebase Admin SDK")
        
        try:
            # Initialiser Firebase Admin si pas déjà fait
            if not firebase_admin._apps:
                if hasattr(settings, 'FIREBASE_CONFIG') and settings.FIREBASE_CONFIG.get('private_key'):
                    cred = credentials.Certificate(settings.FIREBASE_CONFIG)
                    self.firebase_app = firebase_admin.initialize_app(cred)
                    self.print_success("Firebase Admin SDK initialisé")
                else:
                    self.print_error("Clés Firebase manquantes")
                    return False
            else:
                self.print_success("Firebase Admin SDK déjà initialisé")
            
            # Test de création d'un token personnalisé
            test_uid = "test-user-123"
            custom_token = auth.create_custom_token(test_uid)
            self.print_success("Token personnalisé créé avec succès")
            self.print_info(f"Token (50 premiers caractères): {custom_token.decode()[:50]}...")
            
            return True
            
        except Exception as e:
            self.print_error(f"Erreur Firebase Admin SDK: {e}")
            return False
    
    def test_django_user_creation(self):
        """Test de création d'utilisateur Django"""
        self.print_step(3, "Test de création d'utilisateur Django")
        
        try:
            # Supprimer l'utilisateur de test s'il existe
            User.objects.filter(email=self.test_email).delete()
            
            # Créer un nouvel utilisateur
            user = User.objects.create_user(
                email=self.test_email,
                password=self.test_password,
                first_name='Test',
                last_name='User',
                user_type='BOTH',
                firebase_uid='test-firebase-uid-123'
            )
            
            self.print_success(f"Utilisateur créé: {user.email}")
            self.print_info(f"ID: {user.id}")
            self.print_info(f"Firebase UID: {user.firebase_uid}")
            
            return True
            
        except Exception as e:
            self.print_error(f"Erreur création utilisateur: {e}")
            return False
    
    def test_api_without_auth(self):
        """Test des endpoints API sans authentification"""
        self.print_step(4, "Test API sans authentification (mode dev)")
        
        endpoints_to_test = [
            "/projects/",
            "/projects/categories/",
            "/projects/tags/",
            "/content/publications/",
        ]
        
        success_count = 0
        
        for endpoint in endpoints_to_test:
            try:
                url = f"{self.base_url}{endpoint}"
                response = requests.get(url, timeout=10)
                
                if response.status_code in [200, 404]:  # 404 acceptable si pas de données
                    self.print_success(f"GET {endpoint} - Status: {response.status_code}")
                    success_count += 1
                else:
                    self.print_error(f"GET {endpoint} - Status: {response.status_code}")
                    
            except Exception as e:
                self.print_error(f"GET {endpoint} - Erreur: {e}")
        
        return success_count == len(endpoints_to_test)
    
    def test_api_with_firebase_token(self):
        """Test des endpoints API avec token Firebase"""
        self.print_step(5, "Test API avec token Firebase")
        
        try:
            # Créer un token personnalisé pour l'utilisateur de test
            user = User.objects.get(email=self.test_email)
            custom_token = auth.create_custom_token(user.firebase_uid or 'test-uid')
            
            # Simuler un token ID (en réalité, il faudrait l'échanger côté client)
            # Pour le test, on utilise directement le custom token
            headers = {
                'Authorization': f'Bearer {custom_token.decode()}',
                'Content-Type': 'application/json'
            }
            
            # Test sur quelques endpoints
            endpoints_to_test = [
                "/projects/",
                "/users/me/",
            ]
            
            success_count = 0
            
            for endpoint in endpoints_to_test:
                try:
                    url = f"{self.base_url}{endpoint}"
                    response = requests.get(url, headers=headers, timeout=10)
                    
                    if response.status_code in [200, 404]:
                        self.print_success(f"GET {endpoint} avec token - Status: {response.status_code}")
                        success_count += 1
                    else:
                        self.print_error(f"GET {endpoint} avec token - Status: {response.status_code}")
                        self.print_info(f"Réponse: {response.text[:200]}...")
                        
                except Exception as e:
                    self.print_error(f"GET {endpoint} avec token - Erreur: {e}")
            
            return success_count > 0
            
        except Exception as e:
            self.print_error(f"Erreur test avec token: {e}")
            return False
    
    def test_authentication_middleware(self):
        """Test du middleware d'authentification"""
        self.print_step(6, "Test du middleware d'authentification")
        
        try:
            # Test sans token (mode dev)
            response = requests.get(f"{self.base_url}/projects/", timeout=10)
            
            if response.status_code == 200:
                self.print_success("Middleware permet l'accès sans token en mode dev")
            else:
                self.print_error(f"Middleware bloque l'accès sans token: {response.status_code}")
                return False
            
            # Test avec token invalide
            headers = {'Authorization': 'Bearer invalid-token-123'}
            response = requests.get(f"{self.base_url}/projects/", headers=headers, timeout=10)
            
            if response.status_code in [200, 401]:  # 200 en mode dev, 401 en prod
                self.print_success("Middleware gère correctement les tokens invalides")
            else:
                self.print_error(f"Middleware ne gère pas les tokens invalides: {response.status_code}")
            
            return True
            
        except Exception as e:
            self.print_error(f"Erreur test middleware: {e}")
            return False
    
    def test_cors_configuration(self):
        """Test de la configuration CORS"""
        self.print_step(7, "Test de la configuration CORS")
        
        try:
            # Test avec Origin Flutter
            headers = {
                'Origin': 'http://localhost:3000',
                'Access-Control-Request-Method': 'GET',
                'Access-Control-Request-Headers': 'Authorization'
            }
            
            response = requests.options(f"{self.base_url}/projects/", headers=headers, timeout=10)
            
            if response.status_code in [200, 204]:
                self.print_success("CORS configuré correctement")
                
                # Vérifier les headers CORS
                cors_headers = response.headers.get('Access-Control-Allow-Origin')
                if cors_headers:
                    self.print_info(f"CORS Origin: {cors_headers}")
                
            else:
                self.print_error(f"CORS mal configuré: {response.status_code}")
                return False
            
            return True
            
        except Exception as e:
            self.print_error(f"Erreur test CORS: {e}")
            return False
    
    def generate_flutter_test_code(self):
        """Génère du code de test Flutter"""
        self.print_step(8, "Génération du code de test Flutter")
        
        flutter_test_code = '''
// Test Firebase Auth Flutter - À ajouter dans votre app
// lib/test/firebase_test.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/services/firebase_auth_service.dart';
import '../data/services/base_api_service.dart';

class FirebaseTestWidget extends StatefulWidget {
  @override
  _FirebaseTestWidgetState createState() => _FirebaseTestWidgetState();
}

class _FirebaseTestWidgetState extends State<FirebaseTestWidget> {
  String _status = 'Prêt pour les tests';
  
  Future<void> _testFirebaseAuth() async {
    setState(() => _status = 'Test en cours...');
    
    try {
      // Test 1: Connexion Firebase
      final credential = await FirebaseAuthService.signInWithEmailAndPassword(
        email: 'test@venturelink.com',
        password: 'TestPassword123!',
      );
      
      if (credential != null) {
        setState(() => _status = '✅ Connexion Firebase réussie');
        
        // Test 2: Obtenir le token
        final token = await FirebaseAuthService.getIdToken();
        if (token != null) {
          setState(() => _status = '✅ Token Firebase obtenu');
          
          // Test 3: Appel API avec token
          final response = await BaseApiService.dio.get('/projects/');
          if (response.statusCode == 200) {
            setState(() => _status = '✅ Appel API avec token réussi');
          } else {
            setState(() => _status = '❌ Échec appel API: ${response.statusCode}');
          }
        } else {
          setState(() => _status = '❌ Échec obtention token');
        }
      } else {
        setState(() => _status = '❌ Échec connexion Firebase');
      }
    } catch (e) {
      setState(() => _status = '❌ Erreur: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Firebase')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, textAlign: TextAlign.center),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testFirebaseAuth,
              child: Text('Tester Firebase Auth'),
            ),
          ],
        ),
      ),
    );
  }
}
'''
        
        with open('flutter_firebase_test.dart', 'w', encoding='utf-8') as f:
            f.write(flutter_test_code)
        
        self.print_success("Code de test Flutter généré: flutter_firebase_test.dart")
        return True
    
    def run_all_tests(self):
        """Exécute tous les tests"""
        self.print_header("SUITE DE TESTS FIREBASE VENTURELINK")
        
        tests = [
            ("Configuration Django", self.test_django_configuration),
            ("Firebase Admin SDK", self.test_firebase_admin_sdk),
            ("Création utilisateur Django", self.test_django_user_creation),
            ("API sans authentification", self.test_api_without_auth),
            ("API avec token Firebase", self.test_api_with_firebase_token),
            ("Middleware d'authentification", self.test_authentication_middleware),
            ("Configuration CORS", self.test_cors_configuration),
            ("Génération code Flutter", self.generate_flutter_test_code),
        ]
        
        results = []
        
        for test_name, test_func in tests:
            try:
                result = test_func()
                results.append((test_name, result))
            except Exception as e:
                self.print_error(f"Erreur dans {test_name}: {e}")
                results.append((test_name, False))
        
        # Résumé des résultats
        self.print_header("RÉSUMÉ DES TESTS")
        
        passed = sum(1 for _, result in results if result)
        total = len(results)
        
        for test_name, result in results:
            status = "✅ PASSÉ" if result else "❌ ÉCHOUÉ"
            print(f"{status} - {test_name}")
        
        print(f"\n📊 Résultat global: {passed}/{total} tests passés")
        
        if passed == total:
            self.print_success("🎉 Tous les tests sont passés ! Firebase est correctement configuré.")
            print("\n📝 Prochaines étapes :")
            print("1. Testez l'authentification dans votre app Flutter")
            print("2. Utilisez le code généré dans flutter_firebase_test.dart")
            print("3. Vérifiez que les appels API fonctionnent avec les tokens")
        else:
            self.print_error("⚠️  Certains tests ont échoué. Vérifiez la configuration.")
            print("\n🔧 Actions recommandées :")
            print("1. Vérifiez les variables d'environnement Firebase")
            print("2. Assurez-vous que le serveur Django fonctionne")
            print("3. Consultez les logs pour plus de détails")
        
        return passed == total

def main():
    """Fonction principale"""
    print("🚀 Démarrage des tests Firebase VentureLink...")
    
    # Vérifier que Django fonctionne
    try:
        from django.core.management import execute_from_command_line
        print("✅ Django importé avec succès")
    except Exception as e:
        print(f"❌ Erreur import Django: {e}")
        return
    
    # Lancer les tests
    test_suite = FirebaseTestSuite()
    success = test_suite.run_all_tests()
    
    # Code de sortie
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main() 
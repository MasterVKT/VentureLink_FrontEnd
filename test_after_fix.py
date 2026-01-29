#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de test pour vérifier que les corrections d'authentification Django fonctionnent
"""

import requests
import json

def test_endpoints():
    """Tester tous les endpoints après correction"""
    print("🧪 Test des endpoints après correction d'authentification")
    print("=" * 60)
    
    base_url = "http://127.0.0.1:8000/api/v1"
    
    endpoints = {
        "Projects": "/projects/",
        "Categories": "/projects/categories/",
        "Tags": "/projects/tags/",
        "Publications": "/content/publications/",
        "Trending Projects": "/projects/trending/?days=7&limit=10",
        "Featured Projects": "/projects/featured/?limit=10"
    }
    
    success_count = 0
    total_count = len(endpoints)
    
    for name, endpoint in endpoints.items():
        try:
            response = requests.get(f"{base_url}{endpoint}", timeout=10)
            
            if response.status_code == 200:
                print(f"✅ {name}: OK (200)")
                
                # Analyser la réponse pour les listes
                try:
                    data = response.json()
                    if isinstance(data, dict) and 'results' in data:
                        count = len(data['results'])
                        print(f"   📊 {count} éléments trouvés")
                    elif isinstance(data, list):
                        count = len(data)
                        print(f"   📊 {count} éléments trouvés")
                except:
                    print(f"   📄 Réponse reçue")
                
                success_count += 1
                
            elif response.status_code == 401:
                print(f"❌ {name}: Authentification encore requise (401)")
                print(f"   💡 Vérifiez que les permissions Django ont été modifiées")
                
            elif response.status_code == 404:
                print(f"⚠️  {name}: Endpoint non trouvé (404)")
                print(f"   💡 Vérifiez la configuration des URLs Django")
                
            else:
                print(f"⚠️  {name}: Status {response.status_code}")
                
        except requests.exceptions.ConnectionError:
            print(f"❌ {name}: Serveur Django inaccessible")
            print(f"   💡 Assurez-vous que le serveur Django fonctionne sur http://127.0.0.1:8000")
            
        except Exception as e:
            print(f"❌ {name}: Erreur - {e}")
    
    print("\n" + "=" * 60)
    print(f"📊 Résultats: {success_count}/{total_count} endpoints fonctionnels")
    
    if success_count == total_count:
        print("🎉 Tous les endpoints fonctionnent correctement!")
        print("✅ L'application Flutter devrait maintenant pouvoir charger les données")
    elif success_count > 2:  # Categories et Tags fonctionnaient déjà
        print("🔧 Progrès réalisé! Certains endpoints fonctionnent maintenant")
        print("💡 Continuez à appliquer les corrections pour les endpoints restants")
    else:
        print("❌ Les corrections n'ont pas encore été appliquées")
        print("📋 Consultez le fichier SOLUTION_AUTHENTIFICATION_DJANGO.md")
    
    return success_count == total_count

def test_specific_flutter_endpoints():
    """Tester spécifiquement les endpoints utilisés par Flutter"""
    print("\n🎯 Test des endpoints spécifiques à Flutter")
    print("-" * 40)
    
    base_url = "http://127.0.0.1:8000/api/v1"
    
    # Endpoints utilisés par l'application Flutter d'après les logs
    flutter_endpoints = [
        ("/projects/?limit=10&ordering=-interests_count", "Projets recommandés"),
        ("/projects/trending/?days=7&limit=10", "Projets tendance"),
        ("/content/publications/?is_featured=true&limit=10", "Publications mises en avant"),
        ("/projects/categories/", "Catégories"),
        ("/projects/tags/", "Tags")
    ]
    
    for endpoint, description in flutter_endpoints:
        try:
            response = requests.get(f"{base_url}{endpoint}", timeout=5)
            
            if response.status_code == 200:
                print(f"✅ {description}: OK")
            else:
                print(f"❌ {description}: Status {response.status_code}")
                
        except Exception as e:
            print(f"❌ {description}: {e}")

if __name__ == "__main__":
    # Test principal
    all_working = test_endpoints()
    
    # Test spécifique Flutter
    test_specific_flutter_endpoints()
    
    print("\n" + "=" * 60)
    if all_working:
        print("🚀 Prêt pour tester l'application Flutter!")
        print("   Lancez l'application et vérifiez que les données se chargent")
    else:
        print("🔧 Actions requises:")
        print("   1. Appliquez les corrections dans le backend Django")
        print("   2. Redémarrez le serveur Django")
        print("   3. Relancez ce script de test")
        print("   4. Consultez SOLUTION_AUTHENTIFICATION_DJANGO.md pour plus de détails") 
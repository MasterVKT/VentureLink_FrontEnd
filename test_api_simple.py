#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de test simple pour vérifier les endpoints API Django
"""

import requests
import json
from datetime import datetime

def test_api_endpoints():
    """Test des endpoints API principaux"""
    base_url = "http://127.0.0.1:8000/api/v1"
    
    endpoints = [
        ("/projects/", "Projets"),
        ("/projects/categories/", "Catégories de projets"),
        ("/projects/tags/", "Tags de projets"),
        ("/projects/trending/", "Projets tendance"),
        ("/content/publications/", "Publications"),
        ("/users/", "Utilisateurs"),
    ]
    
    print("🧪 Test des endpoints API VentureLink...")
    print(f"🌐 Base URL: {base_url}")
    print(f"⏰ Heure: {datetime.now().strftime('%H:%M:%S')}")
    print("=" * 60)
    
    results = []
    
    for endpoint, description in endpoints:
        try:
            url = f"{base_url}{endpoint}"
            print(f"\n📡 Test: {description}")
            print(f"🔗 URL: {url}")
            
            response = requests.get(url, timeout=10)
            
            status_icon = "✅" if response.status_code == 200 else "⚠️" if response.status_code == 404 else "❌"
            print(f"{status_icon} Status: {response.status_code}")
            
            if response.status_code == 200:
                try:
                    data = response.json()
                    
                    # Analyser la structure de la réponse
                    if isinstance(data, dict):
                        if 'results' in data:
                            count = len(data['results'])
                            total = data.get('count', count)
                            print(f"📊 Réponse paginée: {count} éléments sur {total} total")
                            
                            # Afficher un exemple si disponible
                            if data['results'] and len(data['results']) > 0:
                                first_item = data['results'][0]
                                if isinstance(first_item, dict):
                                    keys = list(first_item.keys())[:5]  # Premiers 5 champs
                                    print(f"🔍 Champs disponibles: {', '.join(keys)}")
                        
                        elif any(key in data for key in ['projects', 'publications', 'categories']):
                            print("🏠 Réponse API root (liens vers endpoints)")
                            for key, value in data.items():
                                print(f"   • {key}: {value}")
                        
                        else:
                            print(f"📋 Objet unique avec {len(data)} champs")
                    
                    elif isinstance(data, list):
                        print(f"📊 Liste directe: {len(data)} éléments")
                        
                        # Afficher un exemple si disponible
                        if data and len(data) > 0:
                            first_item = data[0]
                            if isinstance(first_item, dict):
                                keys = list(first_item.keys())[:5]
                                print(f"🔍 Champs disponibles: {', '.join(keys)}")
                    
                    else:
                        print(f"📄 Type de réponse: {type(data)}")
                    
                    results.append((endpoint, True, response.status_code, "OK"))
                
                except json.JSONDecodeError:
                    print("❌ Réponse non-JSON")
                    print(f"📄 Contenu: {response.text[:100]}...")
                    results.append((endpoint, False, response.status_code, "Non-JSON"))
            
            elif response.status_code == 404:
                print("⚠️  Endpoint non trouvé (normal si pas de données)")
                results.append((endpoint, True, response.status_code, "Not Found"))
            
            elif response.status_code == 401:
                print("🔒 Authentification requise")
                results.append((endpoint, False, response.status_code, "Auth Required"))
            
            elif response.status_code == 403:
                print("🚫 Accès interdit")
                results.append((endpoint, False, response.status_code, "Forbidden"))
            
            else:
                print(f"❌ Erreur HTTP: {response.status_code}")
                print(f"📄 Réponse: {response.text[:200]}...")
                results.append((endpoint, False, response.status_code, "Error"))
                
        except requests.exceptions.ConnectionError:
            print("❌ Impossible de se connecter au serveur Django")
            print("💡 Vérifiez que Django tourne sur http://127.0.0.1:8000")
            results.append((endpoint, False, 0, "Connection Error"))
            
        except requests.exceptions.Timeout:
            print("⏰ Timeout de la requête")
            results.append((endpoint, False, 0, "Timeout"))
            
        except Exception as e:
            print(f"❌ Erreur inattendue: {e}")
            results.append((endpoint, False, 0, str(e)))
    
    # Résumé des résultats
    print("\n" + "=" * 60)
    print("📊 RÉSUMÉ DES TESTS")
    print("=" * 60)
    
    success_count = sum(1 for _, success, _, _ in results if success)
    total_count = len(results)
    
    for endpoint, success, status_code, message in results:
        status_icon = "✅" if success else "❌"
        print(f"{status_icon} {endpoint:<25} | {status_code:<3} | {message}")
    
    print(f"\n🎯 Résultat: {success_count}/{total_count} endpoints fonctionnels")
    
    if success_count == total_count:
        print("🎉 Tous les tests sont passés ! L'API Django fonctionne correctement.")
    elif success_count > 0:
        print("⚠️  Certains endpoints fonctionnent. Vérifiez la configuration.")
    else:
        print("❌ Aucun endpoint ne fonctionne. Vérifiez que Django est démarré.")
    
    return success_count, total_count

def test_specific_endpoints():
    """Test des endpoints spécifiques pour Flutter"""
    base_url = "http://127.0.0.1:8000/api/v1"
    
    print("\n" + "=" * 60)
    print("🎯 TESTS SPÉCIFIQUES POUR FLUTTER")
    print("=" * 60)
    
    flutter_endpoints = [
        ("/projects/?limit=10&ordering=-interests_count", "Projets recommandés"),
        ("/projects/trending/?days=7&limit=10", "Projets tendance"),
        ("/content/publications/?is_featured=true&limit=10", "Publications mises en avant"),
        ("/projects/categories/", "Catégories pour filtres"),
        ("/projects/tags/", "Tags pour recherche"),
    ]
    
    for endpoint, description in flutter_endpoints:
        try:
            url = f"{base_url}{endpoint}"
            print(f"\n🔍 {description}")
            print(f"🔗 {url}")
            
            response = requests.get(url, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                
                if isinstance(data, dict) and 'results' in data:
                    count = len(data['results'])
                    print(f"✅ {count} éléments trouvés")
                elif isinstance(data, list):
                    print(f"✅ {len(data)} éléments trouvés")
                else:
                    print(f"⚠️  Structure inattendue: {type(data)}")
            else:
                print(f"❌ Status: {response.status_code}")
                
        except Exception as e:
            print(f"❌ Erreur: {e}")

def main():
    """Fonction principale"""
    print("🚀 Test de l'API VentureLink")
    print("=" * 60)
    
    try:
        # Test de base
        success, total = test_api_endpoints()
        
        # Tests spécifiques si au moins un endpoint fonctionne
        if success > 0:
            test_specific_endpoints()
        
        # Recommandations
        print("\n" + "=" * 60)
        print("💡 RECOMMANDATIONS")
        print("=" * 60)
        
        if success == 0:
            print("1. Vérifiez que Django est démarré :")
            print("   python manage.py runserver")
            print("2. Vérifiez l'URL de base dans le script")
            print("3. Vérifiez les permissions dans settings.py")
        
        elif success < total:
            print("1. Certains endpoints ne fonctionnent pas")
            print("2. Vérifiez la configuration des permissions")
            print("3. Créez des données de test si nécessaire")
        
        else:
            print("✅ L'API fonctionne correctement !")
            print("🎯 Vous pouvez maintenant tester avec Flutter")
            print("📱 Assurez-vous que Flutter utilise la bonne URL de base")
        
        print("\n🔧 Pour créer des données de test :")
        print("python manage.py shell")
        print("# Puis créez des projets, catégories, etc.")
        
    except KeyboardInterrupt:
        print("\n⏹️  Test interrompu par l'utilisateur")
    
    except Exception as e:
        print(f"\n❌ Erreur inattendue: {e}")

if __name__ == "__main__":
    main() 
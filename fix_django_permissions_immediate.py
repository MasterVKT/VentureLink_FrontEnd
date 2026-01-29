#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour corriger immédiatement les permissions Django
À exécuter dans le dossier de votre projet Django backend
"""

import os
import sys

def find_django_settings():
    """Trouve le fichier settings.py Django"""
    possible_paths = [
        "venture_link_project/settings.py",
        "venturelink/settings.py", 
        "backend/venture_link_project/settings.py",
        "backend/settings.py",
        "src/venture_link_project/settings.py",
        "../backend/venture_link_project/settings.py",
        "../../backend/venture_link_project/settings.py",
    ]
    
    for path in possible_paths:
        if os.path.exists(path):
            return path
    
    return None

def backup_settings(settings_path):
    """Crée une sauvegarde du fichier settings.py"""
    backup_path = f"{settings_path}.backup"
    
    try:
        with open(settings_path, 'r', encoding='utf-8') as original:
            content = original.read()
        
        with open(backup_path, 'w', encoding='utf-8') as backup:
            backup.write(content)
        
        print(f"✅ Sauvegarde créée: {backup_path}")
        return True
    except Exception as e:
        print(f"❌ Erreur sauvegarde: {e}")
        return False

def apply_permission_fix(settings_path):
    """Applique la correction des permissions"""
    
    try:
        with open(settings_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Chercher la configuration REST_FRAMEWORK existante
        if 'REST_FRAMEWORK' in content:
            print("🔍 Configuration REST_FRAMEWORK trouvée, modification...")
            
            # Remplacer la configuration REST_FRAMEWORK
            rest_framework_config = '''
# Configuration temporaire pour le développement - VentureLink
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',  # Temporaire pour dev
    ],
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    'EXCEPTION_HANDLER': 'rest_framework.views.exception_handler',
}'''
            
            # Trouver et remplacer la configuration REST_FRAMEWORK
            import re
            pattern = r'REST_FRAMEWORK\s*=\s*\{[^}]*\}'
            if re.search(pattern, content, re.DOTALL):
                content = re.sub(pattern, rest_framework_config.strip(), content, flags=re.DOTALL)
            else:
                # Ajouter la configuration à la fin
                content += "\n\n" + rest_framework_config
        
        else:
            print("➕ Ajout de la configuration REST_FRAMEWORK...")
            rest_framework_config = '''
# Configuration temporaire pour le développement - VentureLink
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',  # Temporaire pour dev
    ],
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
}'''
            content += "\n\n" + rest_framework_config
        
        # Ajouter/modifier CORS si nécessaire
        if 'CORS_ALLOWED_ORIGINS' not in content:
            print("➕ Ajout de la configuration CORS...")
            cors_config = '''
# Configuration CORS pour Flutter - VentureLink
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://127.0.0.1:3000", 
    "http://10.0.2.2:8000",
]
CORS_ALLOW_CREDENTIALS = True
CORS_ALLOW_ALL_ORIGINS = True  # Temporaire pour dev'''
            content += "\n\n" + cors_config
        
        # Écrire le fichier modifié
        with open(settings_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print("✅ Configuration appliquée avec succès!")
        return True
        
    except Exception as e:
        print(f"❌ Erreur lors de l'application: {e}")
        return False

def main():
    """Fonction principale"""
    print("🔧 Correction des permissions Django - VentureLink")
    print("=" * 60)
    
    # Chercher le fichier settings.py
    settings_path = find_django_settings()
    
    if not settings_path:
        print("❌ Fichier settings.py non trouvé!")
        print("\n💡 Recherche manuelle :")
        print("1. Trouvez votre dossier backend Django")
        print("2. Localisez le fichier settings.py")
        print("3. Exécutez ce script depuis ce dossier")
        print("\n🔍 Chemins recherchés :")
        possible_paths = [
            "venture_link_project/settings.py",
            "venturelink/settings.py", 
            "backend/venture_link_project/settings.py",
            "backend/settings.py",
        ]
        for path in possible_paths:
            print(f"   • {path}")
        return False
    
    print(f"✅ Fichier settings.py trouvé: {settings_path}")
    
    # Créer une sauvegarde
    if not backup_settings(settings_path):
        print("❌ Impossible de créer la sauvegarde, arrêt.")
        return False
    
    # Appliquer la correction
    if apply_permission_fix(settings_path):
        print("\n🎉 Correction appliquée avec succès!")
        print("\n📋 Prochaines étapes :")
        print("1. Redémarrez votre serveur Django :")
        print("   python manage.py runserver")
        print("2. Testez l'API :")
        print("   python test_api_simple.py")
        print("3. Testez votre app Flutter")
        print("\n⚠️  IMPORTANT :")
        print("Cette configuration est temporaire pour le développement.")
        print("En production, configurez Firebase correctement.")
        return True
    else:
        print("\n❌ Échec de l'application de la correction")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1) 
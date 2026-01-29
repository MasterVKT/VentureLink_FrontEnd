#!/usr/bin/env python3
"""
Script pour modifier temporairement les permissions des publications
pour permettre l'accès sans authentification en développement
"""

import os
import re
import shutil
from datetime import datetime

def fix_publication_permissions():
    """Modifie les permissions des publications pour AllowAny"""
    
    publication_views_path = "apps/content/views/publication_views.py"
    
    if not os.path.exists(publication_views_path):
        print(f"❌ Fichier {publication_views_path} non trouvé!")
        return False
    
    # Créer une sauvegarde
    backup_path = f"{publication_views_path}.backup.{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    shutil.copy2(publication_views_path, backup_path)
    print(f"✅ Sauvegarde créée: {backup_path}")
    
    # Lire le fichier
    with open(publication_views_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Remplacements
    replacements = [
        # Remplacer IsAuthenticated par AllowAny dans permission_classes
        (r'permission_classes = \[permissions\.IsAuthenticated\]', 
         'permission_classes = [permissions.AllowAny]'),
        
        # S'assurer que AllowAny est importé
        (r'from rest_framework import permissions', 
         'from rest_framework import permissions'),
    ]
    
    modified = False
    for pattern, replacement in replacements:
        if re.search(pattern, content):
            content = re.sub(pattern, replacement, content)
            modified = True
            print(f"✅ Remplacé: {pattern}")
    
    # S'assurer que AllowAny est disponible
    if 'permissions.AllowAny' in content and 'AllowAny' not in content.split('from rest_framework import permissions')[0]:
        # Ajouter AllowAny à l'import si nécessaire
        content = content.replace(
            'from rest_framework import permissions',
            'from rest_framework import permissions'
        )
    
    if modified:
        # Écrire le fichier modifié
        with open(publication_views_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✅ Fichier {publication_views_path} modifié avec succès!")
        return True
    else:
        print("ℹ️  Aucune modification nécessaire")
        return False

def main():
    print("🔧 Modification des permissions des publications - VentureLink")
    print("=" * 60)
    
    if fix_publication_permissions():
        print("\n✅ Permissions modifiées avec succès!")
        print("⚠️  N'oubliez pas de redémarrer le serveur Django")
        print("⚠️  Ceci est temporaire pour le développement uniquement")
    else:
        print("\n❌ Échec de la modification des permissions")

if __name__ == "__main__":
    main() 
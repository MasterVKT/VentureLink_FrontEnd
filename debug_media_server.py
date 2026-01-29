#!/usr/bin/env python3
"""
Script de debug pour vérifier la configuration des médias côté serveur Django
"""

import os
import sys
import django
import requests
from pathlib import Path

# Configuration Django
sys.path.append('.')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')

try:
    django.setup()
    from django.conf import settings
    from apps.content.models import Publication, PublicationMedia
    from apps.projects.models import Project, ProjectMedia
    print("✅ Django configuré avec succès")
except Exception as e:
    print(f"❌ Erreur configuration Django: {e}")
    sys.exit(1)

def check_media_configuration():
    """Vérifier la configuration des médias Django"""
    print("\n=== CONFIGURATION MÉDIAS DJANGO ===")
    print(f"MEDIA_URL: {settings.MEDIA_URL}")
    print(f"MEDIA_ROOT: {settings.MEDIA_ROOT}")
    print(f"DEBUG: {settings.DEBUG}")
    
    # Vérifier si le dossier MEDIA_ROOT existe
    media_root = Path(settings.MEDIA_ROOT)
    if media_root.exists():
        print(f"✅ MEDIA_ROOT existe: {media_root}")
    else:
        print(f"❌ MEDIA_ROOT n'existe pas: {media_root}")
        return
    
    # Lister les sous-dossiers
    print("\n--- Structure MEDIA_ROOT ---")
    for item in media_root.iterdir():
        if item.is_dir():
            print(f"📁 {item.name}/")
            # Compter les fichiers dans chaque dossier
            file_count = len([f for f in item.rglob('*') if f.is_file()])
            print(f"   └── {file_count} fichier(s)")
        else:
            print(f"📄 {item.name}")

def check_publication_media():
    """Vérifier les médias des publications en base"""
    print("\n=== MÉDIAS PUBLICATIONS EN BASE ===")
    
    publications = Publication.objects.all()[:5]  # Limiter à 5 pour le debug
    print(f"Publications en base: {Publication.objects.count()}")
    
    for pub in publications:
        print(f"\n📰 Publication: {pub.title}")
        print(f"   ID: {pub.id}")
        print(f"   Statut: {pub.status}")
        
        # Vérifier featured_media
        if hasattr(pub, 'featured_media') and pub.featured_media:
            fm = pub.featured_media
            print(f"   🖼️ Featured Media:")
            print(f"      File: {fm.file}")
            print(f"      Type: {fm.media_type}")
            print(f"      URL complète: {settings.MEDIA_URL}{fm.file}")
            
            # Vérifier si le fichier existe
            file_path = Path(settings.MEDIA_ROOT) / str(fm.file)
            if file_path.exists():
                print(f"      ✅ Fichier existe: {file_path}")
                print(f"      Taille: {file_path.stat().st_size} bytes")
            else:
                print(f"      ❌ Fichier manquant: {file_path}")
        else:
            print("   ❌ Pas de featured_media")
        
        # Vérifier tous les médias
        media_list = pub.media.all() if hasattr(pub, 'media') else []
        if media_list:
            print(f"   📁 Médias ({len(media_list)}):")
            for i, media in enumerate(media_list):
                print(f"      {i+1}. {media.file} ({media.media_type})")
                file_path = Path(settings.MEDIA_ROOT) / str(media.file)
                exists = "✅" if file_path.exists() else "❌"
                print(f"         {exists} {file_path}")
        else:
            print("   📁 Aucun média associé")

def check_project_media():
    """Vérifier les médias des projets pour comparaison"""
    print("\n=== MÉDIAS PROJETS (pour comparaison) ===")
    
    projects = Project.objects.all()[:3]  # Limiter à 3 pour le debug
    print(f"Projets en base: {Project.objects.count()}")
    
    for project in projects:
        print(f"\n🚀 Projet: {project.title}")
        print(f"   ID: {project.id}")
        
        # Vérifier primary_image_url
        if project.primary_image_url:
            print(f"   🖼️ Primary Image: {project.primary_image_url}")
            
            # Si c'est un chemin relatif, vérifier le fichier
            if not project.primary_image_url.startswith('http'):
                file_path = Path(settings.MEDIA_ROOT) / project.primary_image_url.lstrip('/')
                if file_path.exists():
                    print(f"      ✅ Fichier existe: {file_path}")
                else:
                    print(f"      ❌ Fichier manquant: {file_path}")
        
        # Vérifier les médias du projet
        if hasattr(project, 'media') and project.media:
            media_list = project.media.all()
            print(f"   📁 Médias ({len(media_list)}):")
            for media in media_list:
                if hasattr(media, 'file') and media.file:
                    print(f"      - {media.file}")
                    file_path = Path(settings.MEDIA_ROOT) / str(media.file)
                    exists = "✅" if file_path.exists() else "❌"
                    print(f"        {exists} {file_path}")

def test_media_urls():
    """Tester l'accès aux URLs de médias"""
    print("\n=== TEST ACCÈS URLs MÉDIAS ===")
    
    base_url = "http://127.0.0.1:8000"  # ou votre URL de dev
    
    # Test d'accès au dossier media
    test_urls = [
        f"{base_url}/media/",
        f"{base_url}/media/publications/",
        f"{base_url}/media/publications/media/",
        f"{base_url}/media/projects/",
    ]
    
    for url in test_urls:
        try:
            response = requests.get(url, timeout=5)
            print(f"✅ {url} - Status: {response.status_code}")
            if response.status_code == 200:
                content_type = response.headers.get('content-type', 'inconnu')
                print(f"   Content-Type: {content_type}")
        except requests.exceptions.RequestException as e:
            print(f"❌ {url} - Erreur: {e}")

def create_test_media():
    """Créer des médias de test pour les publications"""
    print("\n=== CRÉATION MÉDIAS DE TEST ===")
    
    # Créer le dossier publications/media s'il n'existe pas
    publications_media_dir = Path(settings.MEDIA_ROOT) / 'publications' / 'media'
    publications_media_dir.mkdir(parents=True, exist_ok=True)
    print(f"✅ Dossier créé: {publications_media_dir}")
    
    # Créer un fichier de test simple
    test_file = publications_media_dir / 'test_image.txt'
    with open(test_file, 'w') as f:
        f.write("Ceci est un fichier de test pour les médias de publications")
    
    print(f"✅ Fichier de test créé: {test_file}")
    
    # Essayer de créer un média en base
    try:
        publication = Publication.objects.first()
        if publication:
            # Vérifier si on peut créer un PublicationMedia
            print(f"✅ Publication trouvée pour test: {publication.title}")
            # Note: Ne pas créer réellement pour éviter de polluer la base
            print("   (Simulation - pas de création réelle)")
        else:
            print("❌ Aucune publication trouvée pour test")
    except Exception as e:
        print(f"❌ Erreur test création média: {e}")

def main():
    """Fonction principale"""
    print("🔍 DIAGNOSTIC MÉDIAS PUBLICATIONS - VentureLink")
    print("=" * 50)
    
    try:
        check_media_configuration()
        check_publication_media()
        check_project_media()
        test_media_urls()
        create_test_media()
        
        print("\n" + "=" * 50)
        print("✅ Diagnostic terminé")
        
    except Exception as e:
        print(f"\n❌ Erreur lors du diagnostic: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main() 
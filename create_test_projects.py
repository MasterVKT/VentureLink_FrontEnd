#!/usr/bin/env python3
"""
Script pour créer des projets de test dans VentureLink
Exécuter depuis le répertoire racine du projet Flutter
"""

import os
import sys
import django
from datetime import datetime, timedelta

# Trouver le répertoire du projet Django
django_project_path = None
possible_paths = [
    'env/venture_link_project',
    '../venture_link_project', 
    './venture_link_project',
    'backend',
    'server'
]

for path in possible_paths:
    if os.path.exists(path) and os.path.exists(os.path.join(path, 'manage.py')):
        django_project_path = path
        break

if not django_project_path:
    print("❌ Impossible de trouver le projet Django.")
    print("Veuillez vous assurer que le serveur Django est dans un des répertoires suivants:")
    for path in possible_paths:
        print(f"   - {path}")
    sys.exit(1)

print(f"✅ Projet Django trouvé dans: {django_project_path}")

# Configuration Django
sys.path.insert(0, django_project_path)
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'venture_link_project.settings')

try:
    django.setup()
    print("✅ Django configuré avec succès")
except Exception as e:
    print(f"❌ Erreur lors de la configuration Django: {e}")
    sys.exit(1)

try:
    from apps.users.models import User
    from apps.projects.models import Project, ProjectCategory, ProjectTag
    print("✅ Modèles Django importés avec succès")
except ImportError as e:
    print(f"❌ Erreur lors de l'import des modèles: {e}")
    print("Assurez-vous que le serveur Django est correctement configuré.")
    sys.exit(1)

def create_test_projects():
    """Créer des projets de test"""
    
    print("🚀 Début de la création des données de test...")
    
    # Récupérer ou créer un utilisateur admin
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
        print(f"✅ Utilisateur admin créé: {admin_user.email}")
    else:
        print(f"✅ Utilisateur admin existant: {admin_user.email}")
    
    # Créer des catégories de test
    categories_data = [
        {
            'name_fr': 'Technologie',
            'name_en': 'Technology',
            'description_fr': 'Projets technologiques et innovation',
            'description_en': 'Technology and innovation projects',
            'icon': 'tech'
        },
        {
            'name_fr': 'Santé',
            'name_en': 'Health',
            'description_fr': 'Projets de santé et bien-être',
            'description_en': 'Health and wellness projects',
            'icon': 'health'
        },
        {
            'name_fr': 'Éducation',
            'name_en': 'Education',
            'description_fr': 'Projets éducatifs et formation',
            'description_en': 'Educational and training projects',
            'icon': 'education'
        },
        {
            'name_fr': 'Environnement',
            'name_en': 'Environment',
            'description_fr': 'Projets environnementaux et durables',
            'description_en': 'Environmental and sustainable projects',
            'icon': 'environment'
        }
    ]
    
    categories = {}
    for cat_data in categories_data:
        category, created = ProjectCategory.objects.get_or_create(
            name_fr=cat_data['name_fr'],
            defaults=cat_data
        )
        categories[cat_data['name_fr']] = category
        if created:
            print(f"✅ Catégorie créée: {category.name_fr}")
    
    # Créer des tags de test
    tags_data = [
        {'name_fr': 'IA', 'name_en': 'AI', 'color': '#FF6B6B'},
        {'name_fr': 'Mobile', 'name_en': 'Mobile', 'color': '#4ECDC4'},
        {'name_fr': 'Web', 'name_en': 'Web', 'color': '#45B7D1'},
        {'name_fr': 'Blockchain', 'name_en': 'Blockchain', 'color': '#96CEB4'},
        {'name_fr': 'IoT', 'name_en': 'IoT', 'color': '#FFEAA7'},
        {'name_fr': 'Startup', 'name_en': 'Startup', 'color': '#DDA0DD'},
        {'name_fr': 'Innovation', 'name_en': 'Innovation', 'color': '#98D8C8'},
        {'name_fr': 'Écologie', 'name_en': 'Ecology', 'color': '#6C5CE7'}
    ]
    
    tags = {}
    for tag_data in tags_data:
        tag, created = ProjectTag.objects.get_or_create(
            name_fr=tag_data['name_fr'],
            defaults=tag_data
        )
        tags[tag_data['name_fr']] = tag
        if created:
            print(f"✅ Tag créé: {tag.name_fr}")
    
    # Créer des projets de test
    projects_data = [
        {
            'title': 'EcoApp - Application de gestion écologique',
            'short_description': 'Application mobile pour réduire son empreinte carbone au quotidien',
            'full_description': '''EcoApp est une application mobile innovante qui aide les utilisateurs à réduire leur empreinte carbone grâce à des conseils personnalisés, un suivi de consommation et des défis écologiques.

Fonctionnalités principales :
- Calculateur d'empreinte carbone personnalisé
- Conseils quotidiens pour réduire sa consommation
- Défis écologiques communautaires
- Suivi des économies réalisées
- Marketplace de produits éco-responsables

L'application utilise l'IA pour analyser les habitudes de consommation et proposer des alternatives durables adaptées à chaque utilisateur.''',
            'category': categories['Technologie'],
            'stage': 'PROTOTYPE',
            'funding_min': 50000.00,
            'funding_max': 200000.00,
            'funding_currency': 'EUR',
            'location_country': 'France',
            'location_city': 'Paris',
            'is_featured': True,
            'is_premium': True,
            'tags': [tags['Mobile'], tags['IA'], tags['Écologie'], tags['Startup']]
        },
        {
            'title': 'MedConnect - Télémédecine pour zones rurales',
            'short_description': 'Plateforme de télémédecine pour améliorer l\'accès aux soins en zones rurales',
            'full_description': '''MedConnect révolutionne l'accès aux soins de santé dans les zones rurales grâce à une plateforme de télémédecine complète.

Notre solution comprend :
- Consultations vidéo sécurisées avec des médecins spécialisés
- Diagnostic assisté par IA pour les cas d'urgence
- Gestion des dossiers médicaux électroniques
- Réseau de pharmacies partenaires pour la livraison de médicaments
- Formation continue pour les professionnels de santé locaux

La plateforme est conçue pour fonctionner même avec une connexion internet limitée, garantissant un accès universel aux soins.''',
            'category': categories['Santé'],
            'stage': 'DEVELOPMENT',
            'funding_min': 100000.00,
            'funding_max': 500000.00,
            'funding_currency': 'EUR',
            'location_country': 'France',
            'location_city': 'Lyon',
            'is_featured': True,
            'tags': [tags['Web'], tags['IA'], tags['Innovation']]
        },
        {
            'title': 'EduTech VR - Formation immersive en réalité virtuelle',
            'short_description': 'Plateforme de formation professionnelle en réalité virtuelle',
            'full_description': '''EduTech VR transforme la formation professionnelle grâce à la réalité virtuelle immersive.

Nos modules de formation couvrent :
- Sécurité industrielle et gestes de premiers secours
- Formation technique pour l'industrie 4.0
- Soft skills et management d'équipe
- Langues étrangères avec immersion culturelle
- Formations médicales et chirurgicales

La plateforme utilise des environnements 3D réalistes et des scénarios interactifs pour maximiser l'apprentissage et la rétention des connaissances.''',
            'category': categories['Éducation'],
            'stage': 'IDEA',
            'funding_min': 75000.00,
            'funding_max': 300000.00,
            'funding_currency': 'EUR',
            'location_country': 'France',
            'location_city': 'Toulouse',
            'is_premium': True,
            'tags': [tags['Innovation'], tags['Startup']]
        },
        {
            'title': 'GreenChain - Traçabilité blockchain pour l\'agriculture',
            'short_description': 'Solution blockchain pour la traçabilité des produits agricoles bio',
            'full_description': '''GreenChain utilise la technologie blockchain pour garantir la traçabilité complète des produits agricoles biologiques, de la ferme à l'assiette.

Notre solution offre :
- Traçabilité complète de la chaîne d'approvisionnement
- Certification automatique des pratiques biologiques
- Marketplace directe producteur-consommateur
- Système de récompenses pour les pratiques durables
- Analytics pour optimiser les rendements écologiques

Les consommateurs peuvent scanner un QR code pour connaître l'origine exacte de leurs aliments et soutenir directement les producteurs locaux.''',
            'category': categories['Environnement'],
            'stage': 'PROTOTYPE',
            'funding_min': 80000.00,
            'funding_max': 250000.00,
            'funding_currency': 'EUR',
            'location_country': 'France',
            'location_city': 'Bordeaux',
            'is_featured': True,
            'tags': [tags['Blockchain'], tags['Écologie'], tags['Innovation']]
        },
        {
            'title': 'SmartHome IoT - Maison connectée intelligente',
            'short_description': 'Écosystème IoT pour optimiser la consommation énergétique domestique',
            'full_description': '''SmartHome IoT propose un écosystème complet d'objets connectés pour transformer n'importe quelle maison en habitat intelligent et économe en énergie.

Notre gamme comprend :
- Capteurs de température, humidité et qualité de l'air
- Système de gestion intelligente de l'éclairage
- Optimisation automatique du chauffage et climatisation
- Monitoring de la consommation électrique en temps réel
- Assistant vocal intégré pour le contrôle domotique

L'IA embarquée apprend les habitudes des résidents pour optimiser automatiquement la consommation énergétique tout en maintenant le confort.''',
            'category': categories['Technologie'],
            'stage': 'GROWTH',
            'funding_min': 150000.00,
            'funding_max': 600000.00,
            'funding_currency': 'EUR',
            'location_country': 'France',
            'location_city': 'Nice',
            'tags': [tags['IoT'], tags['IA'], tags['Innovation']]
        }
    ]
    
    # Créer les projets
    for i, project_data in enumerate(projects_data):
        tags_to_add = project_data.pop('tags', [])
        
        project, created = Project.objects.get_or_create(
            title=project_data['title'],
            defaults={
                **project_data,
                'creator': admin_user,
                'status': 'ACTIVE',
                'is_draft': False,
                'published_at': datetime.now() - timedelta(days=i),
                'views_count': (5 - i) * 100 + 50,  # Vues décroissantes
                'interests_count': (5 - i) * 10 + 5,  # Intérêts décroissants
                'favorites_count': (5 - i) * 5 + 2,   # Favoris décroissants
            }
        )
        
        if created:
            # Ajouter les tags
            for tag in tags_to_add:
                project.tags.add(tag)
            
            print(f"✅ Projet créé: {project.title}")
            print(f"   - Catégorie: {project.category.name_fr}")
            print(f"   - Stage: {project.stage}")
            print(f"   - Financement: {project.funding_min}€ - {project.funding_max}€")
            print(f"   - Vues: {project.views_count}")
            print(f"   - Intérêts: {project.interests_count}")
            print(f"   - Tags: {', '.join([tag.name_fr for tag in project.tags.all()])}")
            print()
        else:
            print(f"⚠️ Projet existant: {project.title}")
    
    print(f"\n🎉 Création terminée !")
    print(f"📊 Statistiques:")
    print(f"   - Utilisateurs: {User.objects.count()}")
    print(f"   - Catégories: {ProjectCategory.objects.count()}")
    print(f"   - Tags: {ProjectTag.objects.count()}")
    print(f"   - Projets: {Project.objects.count()}")
    print(f"   - Projets featured: {Project.objects.filter(is_featured=True).count()}")
    print(f"   - Projets premium: {Project.objects.filter(is_premium=True).count()}")

if __name__ == '__main__':
    create_test_projects() 
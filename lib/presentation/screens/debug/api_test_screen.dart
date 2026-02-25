import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/data/providers/project_provider.dart';
import 'package:venturelink/data/providers/content_provider.dart';
import 'package:venturelink/core/utils/logger.dart';
import 'package:venturelink/data/services/content_api_service.dart';
import 'package:venturelink/core/config/app_config.dart';
import 'package:venturelink/data/models/publication_model.dart';
import 'package:dio/dio.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  _ApiTestScreenState createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final List<String> _testResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test des APIs'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Boutons de test
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _testProjectsAPI,
                  child: const Text('Test Projets'),
                ),
                ElevatedButton(
                  onPressed: _testPublicationsAPI,
                  child: const Text('Test Publications'),
                ),
                ElevatedButton(
                  onPressed: _testFeaturedProjectsAPI,
                  child: const Text('Test Projets Featured'),
                ),
                ElevatedButton(
                  onPressed: _testURLsCorrection,
                  child: const Text('Test URLs'),
                ),
                ElevatedButton(
                  onPressed: _testPublicationParsing,
                  child: const Text('Test Publication Parsing'),
                ),
                ElevatedButton(
                  onPressed: _testPublicationMedia,
                  child: const Text('Test Médias Publications'),
                ),
                ElevatedButton(
                  onPressed: _testMediaUrls,
                  child: const Text('Test URLs de médias'),
                ),
                ElevatedButton(
                  onPressed: _testProjectCreators,
                  child: const Text('Test Créateurs de Projets'),
                ),
                ElevatedButton(
                  onPressed: _testBackendConnectivity,
                  child: const Text('Test Connectivité Backend'),
                ),
                ElevatedButton(
                  onPressed: _clearResults,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Vider'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Résultats des tests
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _testResults.length,
                  itemBuilder: (context, index) {
                    final result = _testResults[index];
                    final isError =
                        result.contains('ERREUR') || result.contains('❌');
                    final isSuccess = result.contains('✅');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isError
                            ? Colors.red.withValues(alpha: 0.1)
                            : isSuccess
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        result,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: isError
                              ? Colors.red[700]
                              : isSuccess
                                  ? Colors.green[700]
                                  : Colors.black87,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addResult(String message) {
    setState(() {
      final timestamp = DateTime.now().toString().substring(11, 19);
      _testResults.add('[$timestamp] $message');
    });
    AppLogger.info('API Test: $message');
  }

  void _clearResults() {
    setState(() {
      _testResults.clear();
    });
  }

  Future<void> _testProjectsAPI() async {
    _addResult('🔄 Test de l\'API des projets...');

    try {
      final projectProvider =
          Provider.of<ProjectProvider>(context, listen: false);

      // Test endpoint principal des projets - utiliser la méthode correcte
      await projectProvider.loadProjects();

      final projects = projectProvider.projects;
      final featuredProjects = projectProvider.featuredProjects;
      final trendingProjects = projectProvider.trendingProjects;

      _addResult('✅ Projets chargés: ${projects.length}');
      _addResult('✅ Projets featured: ${featuredProjects.length}');
      _addResult('✅ Projets trending: ${trendingProjects.length}');

      if (projects.isEmpty &&
          featuredProjects.isEmpty &&
          trendingProjects.isEmpty) {
        _addResult('⚠️ Aucun projet trouvé - vérifier le backend');
      }
    } catch (e) {
      _addResult('❌ ERREUR Projets: $e');
    }
  }

  Future<void> _testPublicationsAPI() async {
    _addResult('🔄 Test de l\'API des publications...');

    try {
      _addResult('📋 Test structure modèle Publication...');

      // Test direct avec une réponse simulée
      final testJson = {
        'id': 'test-123',
        'title': 'Test Publication',
        'publication_type': 'EDUCATIONAL',
        'domain': 'TECHNOLOGY',
        'author': {
          'id': 1,
          'email': 'test@test.com',
          'full_name': 'Test User',
          'user_type': 'BOTH',
          'account_type': 'PERSONAL'
        },
        'status': 'PUBLISHED',
        'views_count': 0,
        'likes_count': 0,
        'comments_count': 0,
        'is_featured': false,
        'is_pinned': false,
        'is_sponsored': false,
        'tags_list': ['test'],
        'user_has_liked': false,
      };

      try {
        final testPub = Publication.fromJson(testJson);
        _addResult('✅ Modèle Publication : OK (${testPub.title})');
      } catch (e) {
        _addResult('❌ Erreur modèle Publication : $e');
        return;
      }

      final contentProvider =
          Provider.of<ContentProvider>(context, listen: false);

      // Test endpoint publications épinglées
      _addResult('🔄 Test publications épinglées...');
      try {
        await contentProvider.loadPinnedPublications();
        final pinnedPublications = contentProvider.pinnedPublications;
        _addResult('✅ Publications épinglées: ${pinnedPublications.length}');
      } catch (e) {
        _addResult('❌ Erreur épinglées: $e');
      }

      // Test endpoint publications mises en avant
      _addResult('🔄 Test publications featured...');
      try {
        await contentProvider.loadFeaturedPublications();
        final featuredPublications = contentProvider.featuredPublications;
        _addResult('✅ Publications featured: ${featuredPublications.length}');
      } catch (e) {
        _addResult('❌ Erreur featured: $e');
      }

      // Test endpoint publications générales
      _addResult('🔄 Test publications générales...');
      try {
        await contentProvider.loadPublications();
        final publications = contentProvider.publications;
        _addResult('✅ Publications générales: ${publications.length}');

        if (publications.isNotEmpty) {
          final firstPub = publications.first;
          _addResult('📝 Première publication: ${firstPub.title}');
          _addResult('📝 Type: ${firstPub.publicationType}');
          _addResult('📝 Domain: ${firstPub.domain}');
          _addResult('📝 Media présent: ${firstPub.hasMedia}');
        }
      } catch (e) {
        _addResult('❌ Erreur générales: $e');
      }
    } catch (e) {
      _addResult('❌ Erreur API publications: $e');

      // Test direct de l'endpoint
      try {
        _addResult('🔄 Test direct endpoint /content/publications/...');

        // Simulation d'un appel direct pour diagnostiquer
        final contentApiService = ContentApiService();
        final result = await contentApiService.getFeaturedPublications();

        _addResult('📊 Résultat test direct: ${result.length} publications');
      } catch (directError) {
        _addResult('❌ Erreur test direct: $directError');

        // Vérifier si c'est une erreur HTML
        if (directError.toString().contains('<!DOCTYPE html>') ||
            directError.toString().contains('<html>')) {
          _addResult(
              '🚨 PROBLÈME: Le backend retourne du HTML au lieu de JSON !');
          _addResult(
              '💡 Solution: Désactiver Django Debug Toolbar ou corriger les headers');
        } else if (directError.toString().contains('type cast')) {
          _addResult('🚨 PROBLÈME: Erreur de type cast dans le modèle !');
          _addResult(
              '💡 Solution: Vérifier la correspondance entre API et modèle');
        }
      }
    }
  }

  Future<void> _testFeaturedProjectsAPI() async {
    _addResult('🔄 Test spécifique des projets featured...');

    try {
      final projectProvider =
          Provider.of<ProjectProvider>(context, listen: false);

      // Test direct de la méthode featured
      await projectProvider.loadFeaturedProjects();

      final featuredProjects = projectProvider.featuredProjects;
      _addResult('✅ Test featured direct: ${featuredProjects.length} projets');

      // Vérification de l'URL construite
      _addResult(
          '📡 URL attendue: /api/v1/projects/projects/?is_featured=true');
    } catch (e) {
      _addResult('❌ ERREUR Featured: $e');
    }
  }

  Future<void> _testURLsCorrection() async {
    _addResult('🔧 Test de correction des URLs...');

    try {
      _addResult('📋 URLs attendues (SANS duplication /api/v1/):');
      _addResult('✅ Base URL: ${AppConfig.fullApiUrl}');
      _addResult(
          '✅ Publications: ${AppConfig.fullApiUrl}/content/publications/');
      _addResult('✅ Projets: ${AppConfig.fullApiUrl}/projects/projects/');
      _addResult('✅ Matching: ${AppConfig.fullApiUrl}/matching/projects/');

      _addResult('🚀 Test des endpoints corrigés...');

      // Test Content API
      final contentApiService = ContentApiService();
      try {
        final featuredPubs = await contentApiService.getFeaturedPublications();
        _addResult(
            '✅ Content API: ${featuredPubs.length} publications featured');
      } catch (e) {
        _addResult('❌ Content API error: $e');
      }

      // Test Project API
      final projectProvider =
          Provider.of<ProjectProvider>(context, listen: false);
      try {
        await projectProvider.loadFeaturedProjects();
        final featuredProjects = projectProvider.featuredProjects;
        _addResult(
            '✅ Project API: ${featuredProjects.length} projets featured');
      } catch (e) {
        _addResult('❌ Project API error: $e');
      }

      _addResult('🎉 Test URLs terminé !');
    } catch (e) {
      _addResult('❌ Erreur test URLs: $e');
    }
  }

  void _testPublicationParsing() {
    try {
      AppLogger.info('Test du parsing des publications...');

      // Données de test basées sur la réponse réelle
      final Map<String, dynamic> testData = {
        "id": "2110ba0d-75d6-4601-ab00-edb35d54e2f9",
        "title": "Comment financer votre startup",
        "summary": "Les différentes options de financement pour les startups",
        "publication_type": "EDUCATIONAL",
        "domain": "FINANCE_INVESTMENT",
        "author": {
          "id": 24,
          "email": "admin@venturelink.com",
          "full_name": "Admin VentureLink",
          "user_type": "BOTH",
          "account_type": "PERSONAL"
        },
        "status": "PUBLISHED",
        "published_at": "2025-06-16T00:08:40.065988+02:00",
        "views_count": 0,
        "likes_count": 0,
        "comments_count": 0,
        "shares_count": null,
        "is_featured": true,
        "is_pinned": false,
        "is_sponsored": false,
        "sponsor_name": null,
        "sponsor_url": null,
        "meta_description": null,
        "slug": "comment-financer-votre-startup-8560f595",
        "featured_media": null,
        "media": null,
        "likes": null,
        "tags_list": ["financement", "startup", "investissement", "capital"],
        "user_has_liked": false,
        "allow_comments": null,
        "can_be_commented": null,
        "is_published": null,
        "created_at": null,
        "updated_at": null
      };

      AppLogger.info('Tentative de parsing...');
      final publication = Publication.fromJson(testData);
      AppLogger.info('✅ Parsing réussi: ${publication.title}');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Erreur lors du parsing: $e');
      AppLogger.error('Stack trace: $stackTrace');
    }
  }

  Future<void> _testPublicationMedia() async {
    _addResult('🔄 Test spécifique des médias de publications...');

    try {
      // Test avec des données de média réalistes
      final Map<String, dynamic> testDataWithMedia = {
        "id": "test-with-media",
        "title": "Test avec médias",
        "publication_type": "EDUCATIONAL",
        "domain": "TECHNOLOGY",
        "author": {
          "id": 1,
          "email": "test@test.com",
          "full_name": "Test User",
          "user_type": "BOTH",
          "account_type": "PERSONAL"
        },
        "status": "PUBLISHED",
        "views_count": 0,
        "likes_count": 0,
        "comments_count": 0,
        "is_featured": false,
        "is_pinned": false,
        "is_sponsored": false,
        "tags_list": ["test"],
        "user_has_liked": false,
        "featured_media": {
          "id": "media-1",
          "file": "/media/publications/media/test_image.jpg",
          "media_type": "image/jpeg",
          "title": "Image de test",
          "description": "Description test",
          "alt_text": "Texte alternatif",
          "order": 0,
          "is_featured": true,
          "file_size": 12345,
          "created_at": "2024-01-01T00:00:00Z"
        },
        "media": [
          {
            "id": "media-1",
            "file": "/media/publications/media/test_image.jpg",
            "media_type": "image/jpeg",
            "title": "Image de test",
            "description": "Description test",
            "alt_text": "Texte alternatif",
            "order": 0,
            "is_featured": true,
            "file_size": 12345,
            "created_at": "2024-01-01T00:00:00Z"
          },
          {
            "id": "media-2",
            "file": "/media/publications/media/test_video.mp4",
            "media_type": "video/mp4",
            "title": "Vidéo de test",
            "description": "Vidéo de test",
            "alt_text": null,
            "order": 1,
            "is_featured": false,
            "file_size": 987654,
            "duration": 60,
            "created_at": "2024-01-01T00:00:00Z"
          }
        ]
      };

      try {
        final publication = Publication.fromJson(testDataWithMedia);
        _addResult('✅ Publication avec médias parsée: ${publication.title}');
        _addResult(
            '📸 Featured media: ${publication.featuredMedia?.file ?? 'null'}');
        _addResult('📁 Nombre de médias: ${publication.media?.length ?? 0}');

        if (publication.media != null) {
          for (int i = 0; i < publication.media!.length; i++) {
            final media = publication.media![i];
            _addResult('  📷 Média $i: ${media.mediaType} - ${media.file}');
            _addResult('  🔗 URL complète: ${media.fullUrl}');
          }
        }

        _addResult('✅ Test médias locaux réussi!');
      } catch (e) {
        _addResult('❌ Erreur parsing médias: $e');
        return;
      }

      // Test avec des vraies données du backend
      _addResult('🔄 Test avec données backend réelles...');
      try {
        final contentApiService = ContentApiService();
        final publications = await contentApiService.getPublications();

        _addResult('📊 Publications récupérées: ${publications.length}');

        // Chercher une publication avec des médias
        Publication? publicationWithMedia;
        for (final pub in publications) {
          if (pub.featuredMedia != null ||
              (pub.media != null && pub.media!.isNotEmpty)) {
            publicationWithMedia = pub;
            break;
          }
        }

        if (publicationWithMedia != null) {
          _addResult(
              '✅ Publication avec médias trouvée: ${publicationWithMedia.title}');
          _addResult(
              '📸 Featured media: ${publicationWithMedia.featuredMedia?.file ?? 'null'}');
          _addResult('📁 Médias: ${publicationWithMedia.media?.length ?? 0}');

          if (publicationWithMedia.featuredMedia != null) {
            final fm = publicationWithMedia.featuredMedia!;
            _addResult('  🔗 Featured URL: ${fm.fullUrl}');
            _addResult('  📱 Type: ${fm.mediaType}');
          }

          if (publicationWithMedia.media != null &&
              publicationWithMedia.media!.isNotEmpty) {
            for (int i = 0; i < publicationWithMedia.media!.length; i++) {
              final media = publicationWithMedia.media![i];
              _addResult('  📷 Média $i: ${media.mediaType}');
              _addResult('  🔗 URL: ${media.fullUrl}');
            }
          }
        } else {
          _addResult('⚠️ Aucune publication avec médias trouvée');
        }
      } catch (e) {
        _addResult('❌ Erreur test backend: $e');
      }
    } catch (e) {
      _addResult('❌ Erreur générale test médias: $e');
    }
  }

  void _testMediaUrls() async {
    try {
      _addResult('🧪 Test des URLs de médias...');

      // Test de configuration des URLs
      _addResult('📍 Configuration URLs:');
      _addResult('  Base URL: ${AppConfig.apiBaseUrl}');
      _addResult('  Full API URL: ${AppConfig.fullApiUrl}');

      // Test avec une publication qui a un featured_media
      final publications = await ContentApiService().getPublications();

      if (publications.isNotEmpty) {
        for (final publication in publications.take(3)) {
          if (publication.featuredMedia != null) {
            final media = publication.featuredMedia!;
            _addResult('🔍 Publication: ${publication.title}');
            _addResult('  Media file (raw): ${media.file}');
            _addResult('  Media fullUrl: ${media.fullUrl}');
            _addResult('  Media type: ${media.mediaType}');

            // Test de construction manuelle de l'URL
            String manualUrl1 = '${AppConfig.apiBaseUrl}${media.file}';
            String manualUrl2 =
                '${AppConfig.apiBaseUrl}/media/${media.file.replaceFirst('/media/', '')}';
            String manualUrl3 =
                '${AppConfig.apiBaseUrl}/media/publications/media/${media.file.split('/').last}';

            _addResult('  🔧 URL manuelle 1: $manualUrl1');
            _addResult('  🔧 URL manuelle 2: $manualUrl2');
            _addResult('  🔧 URL manuelle 3: $manualUrl3');

            break;
          }
        }
      } else {
        _addResult('❌ Aucune publication trouvée');
      }

      // Test d'une URL connue
      _addResult('🌐 Test URL externe: https://picsum.photos/200/300');
    } catch (e) {
      _addResult('❌ Erreur test URLs: $e');
    }
  }

  void _testProjectCreators() async {
    try {
      _addResult('👥 Test des créateurs de projets...');

      // Charger quelques projets
      final projectProvider =
          Provider.of<ProjectProvider>(context, listen: false);
      await projectProvider.loadProjects();

      final projects = projectProvider.projects.take(3);

      if (projects.isEmpty) {
        _addResult('❌ Aucun projet trouvé');
        return;
      }

      for (final project in projects) {
        _addResult('🏢 Projet: ${project.title}');
        _addResult('  Creator ID: ${project.creator.id}');
        _addResult('  Creator Email: ${project.creator.email}');
        _addResult('  Creator FirstName: ${project.creator.firstName}');
        _addResult('  Creator LastName: ${project.creator.lastName}');
        _addResult('  Creator FullName: ${project.creator.fullName}');
        _addResult('  Creator UserType: ${project.creator.userType}');
        _addResult('  Creator Verified: ${project.creator.isVerified}');

        if (project.creatorName != null) {
          _addResult('  CreatorName field: ${project.creatorName}');
        } else {
          _addResult('  CreatorName field: null');
        }

        _addResult('  ---');
      }
    } catch (e) {
      _addResult('❌ Erreur test creators: $e');
    }
  }

  void _testBackendConnectivity() async {
    try {
      _addResult('🌐 Test de connectivité backend...');

      // Test de l'URL de base
      _addResult('📍 Configuration:');
      _addResult('  Base URL: ${AppConfig.apiBaseUrl}');
      _addResult('  API URL: ${AppConfig.fullApiUrl}');

      // Test d'une requête simple
      final dio = Dio();

      try {
        _addResult('🔍 Test GET sur l\'API base...');
        final response = await dio.get('${AppConfig.apiBaseUrl}/');
        _addResult('✅ Réponse reçue, status: ${response.statusCode}');
        _addResult('  Type de réponse: ${response.data.runtimeType}');

        if (response.data is String) {
          final content = response.data as String;
          if (content.length > 200) {
            _addResult('  Contenu (début): ${content.substring(0, 200)}...');
          } else {
            _addResult('  Contenu: $content');
          }
        }
      } catch (e) {
        _addResult('❌ Erreur requête base: $e');
      }

      // Test d'accès aux médias
      try {
        _addResult('🖼️ Test d\'accès aux médias...');
        final mediaTestUrl = '${AppConfig.apiBaseUrl}/media/';
        final mediaResponse = await dio.get(mediaTestUrl);
        _addResult(
            '✅ Dossier media accessible, status: ${mediaResponse.statusCode}');
      } catch (e) {
        _addResult('❌ Dossier media inaccessible: $e');
      }

      // Test d'une URL d'image spécifique si on en a une
      try {
        final publications = await ContentApiService().getPublications();
        if (publications.isNotEmpty) {
          final pub = publications.firstWhere(
            (p) => p.featuredMedia != null,
            orElse: () => publications.first,
          );

          if (pub.featuredMedia != null) {
            _addResult('🎯 Test d\'une image spécifique...');
            final imageUrl = pub.featuredMedia!.fullUrl;
            _addResult('  URL testée: $imageUrl');

            final imageResponse = await dio.get(imageUrl);
            _addResult(
                '✅ Image accessible, status: ${imageResponse.statusCode}');
            _addResult(
                '  Content-Type: ${imageResponse.headers['content-type']?.first ?? 'inconnu'}');
            _addResult(
                '  Taille: ${imageResponse.headers['content-length']?.first ?? 'inconnue'} bytes');
          }
        }
      } catch (e) {
        _addResult('❌ Erreur test image spécifique: $e');
      }
    } catch (e) {
      _addResult('❌ Erreur test connectivité: $e');
    }
  }
}

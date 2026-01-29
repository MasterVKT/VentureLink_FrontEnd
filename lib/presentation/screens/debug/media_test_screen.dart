import 'package:flutter/material.dart';
import '../../../data/models/publication_model.dart';
import '../../../data/services/content_api_service.dart';
import '../../../core/config/app_config.dart';
import '../../../core/utils/logger.dart';
import '../../../presentation/widgets/content/publication_media_widget.dart';
import 'package:dio/dio.dart';

class MediaTestScreen extends StatefulWidget {
  const MediaTestScreen({super.key});

  @override
  State<MediaTestScreen> createState() => _MediaTestScreenState();
}

class _MediaTestScreenState extends State<MediaTestScreen> {
  final List<String> _logs = [];
  bool _isLoading = false;

  void _addLog(String message) {
    setState(() {
      _logs.add(message);
    });
    AppLogger.info(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Médias Publications'),
      ),
      body: Column(
        children: [
          // Boutons de test
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testPublicationMedias,
                  child: const Text('Test Médias Publications'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testUrlConstruction,
                  child: const Text('Test Construction URLs'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testDirectMediaAccess,
                  child: const Text('Test Accès Direct Médias'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testUrlVariants,
                  child: const Text('Test Variantes URLs'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testFeaturedPublications,
                  child: const Text('Test Publications Mises en Avant'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testPublicationsComparison,
                  child: const Text('Test Comparaison Publications'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testCarouselSpecifically,
                  child: const Text('Test Carrousel Spécifique'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _logs.clear();
                    });
                  },
                  child: const Text('Vider les logs'),
                ),
              ],
            ),
          ),

          // Médias de test
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildTestMediaWidget(),
                ),
              ],
            ),
          ),

          // Logs
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      _logs[index],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestMediaWidget() {
    // Créer des médias de test
    final testMedias = [
      PublicationMedia(
        id: 'test1',
        file: '/media/publications/test1.jpg',
        mediaType: 'IMAGE',
        createdAt: DateTime.now(),
      ),
      PublicationMedia(
        id: 'test2',
        file: 'https://picsum.photos/400/300',
        mediaType: 'IMAGE',
        createdAt: DateTime.now(),
      ),
    ];

    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            AppLogger.info('=== TEST MANUEL LOGS ===');
            AppLogger.info('Bouton pressé dans MediaTestScreen');
            AppLogger.info('Nombre de médias de test: ${testMedias.length}');
            for (int i = 0; i < testMedias.length; i++) {
              final media = testMedias[i];
              AppLogger.info('Média test${i + 1}: ${media.fullUrl}');
            }
          },
          child: const Text('Test Manuel Logs'),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: testMedias.map((media) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: PublicationMediaWidget(
                    media: media,
                    height: 150,
                    showDescription: false,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _testPublicationMedias() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addLog('=== TEST MÉDIAS PUBLICATIONS ===');
      _addLog('Configuration API: ${AppConfig.apiBaseUrl}');

      // Récupérer les publications
      final publications = await ContentApiService().getPublications();
      _addLog('Publications récupérées: ${publications.length}');

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
        _addLog('✅ Publication avec médias: ${publicationWithMedia.title}');

        // Analyser le featured media
        if (publicationWithMedia.featuredMedia != null) {
          final fm = publicationWithMedia.featuredMedia!;
          _addLog('--- FEATURED MEDIA ---');
          _addLog('ID: ${fm.id}');
          _addLog('File (raw): ${fm.file}');
          _addLog('Media Type: ${fm.mediaType}');
          _addLog('Full URL: ${fm.fullUrl}');
          _addLog('Is Image: ${fm.isImage}');
          _addLog('Is Video: ${fm.isVideo}');
          _addLog('Title: ${fm.title ?? 'null'}');
          _addLog('Description: ${fm.description ?? 'null'}');
        }

        // Analyser tous les médias
        if (publicationWithMedia.media != null &&
            publicationWithMedia.media!.isNotEmpty) {
          _addLog(
              '--- TOUS LES MÉDIAS (${publicationWithMedia.media!.length}) ---');
          for (int i = 0; i < publicationWithMedia.media!.length; i++) {
            final media = publicationWithMedia.media![i];
            _addLog('Média $i:');
            _addLog('  ID: ${media.id}');
            _addLog('  File: ${media.file}');
            _addLog('  Type: ${media.mediaType}');
            _addLog('  Full URL: ${media.fullUrl}');
            _addLog('  Is Image: ${media.isImage}');
          }
        }
      } else {
        _addLog('❌ Aucune publication avec médias trouvée');
      }
    } catch (e) {
      _addLog('❌ Erreur: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testUrlConstruction() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addLog('=== TEST CONSTRUCTION URLs ===');

      // Test avec différents formats de fichiers
      final testFiles = [
        '/media/publications/test1.jpg',
        'media/publications/test2.jpg',
        'publications/media/test3.jpg',
        'test4.jpg',
        'https://example.com/test5.jpg',
      ];

      for (final file in testFiles) {
        _addLog('--- Test avec file: "$file" ---');

        // Simuler la construction d'URL comme dans PublicationMedia
        String finalUrl;
        if (file.startsWith('http')) {
          finalUrl = file;
          _addLog('✅ URL absolue détectée: $finalUrl');
        } else if (file.startsWith('/media/')) {
          finalUrl = '${AppConfig.apiBaseUrl}$file';
          _addLog('📁 URL avec /media/: $finalUrl');
        } else {
          finalUrl = '${AppConfig.apiBaseUrl}/media/$file';
          _addLog('🔧 URL construite: $finalUrl');
        }

        _addLog('🎯 URL finale: $finalUrl');
        _addLog('');
      }
    } catch (e) {
      _addLog('❌ Erreur: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testDirectMediaAccess() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addLog('=== TEST ACCÈS DIRECT MÉDIAS ===');

      final dio = Dio();

      // Test d'accès au dossier media
      final mediaUrls = [
        '${AppConfig.apiBaseUrl}/media/',
        '${AppConfig.apiBaseUrl}/media/publications/',
        '${AppConfig.apiBaseUrl}/media/publications/media/',
      ];

      for (final url in mediaUrls) {
        try {
          _addLog('Test accès: $url');
          final response = await dio.get(url);
          _addLog('✅ Status: ${response.statusCode}');
          _addLog(
              'Content-Type: ${response.headers['content-type']?.first ?? 'inconnu'}');

          if (response.data is String) {
            final content = response.data as String;
            if (content.length > 100) {
              _addLog(
                  'Contenu (100 premiers chars): ${content.substring(0, 100)}...');
            } else {
              _addLog('Contenu: $content');
            }
          }
        } catch (e) {
          _addLog('❌ Erreur accès $url: $e');
        }
        _addLog('');
      }

      // Test avec une URL spécifique
      try {
        final publications = await ContentApiService().getPublications();
        if (publications.isNotEmpty) {
          final pub = publications.firstWhere(
            (p) => p.featuredMedia != null,
            orElse: () => publications.first,
          );

          if (pub.featuredMedia != null) {
            final mediaUrl = pub.featuredMedia!.fullUrl;
            _addLog('Test image spécifique: $mediaUrl');

            final response = await dio.get(mediaUrl);
            _addLog('✅ Image accessible, status: ${response.statusCode}');
            _addLog(
                'Content-Type: ${response.headers['content-type']?.first ?? 'inconnu'}');
            _addLog(
                'Content-Length: ${response.headers['content-length']?.first ?? 'inconnu'}');
          }
        }
      } catch (e) {
        _addLog('❌ Erreur test image: $e');
      }
    } catch (e) {
      _addLog('❌ Erreur: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testUrlVariants() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addLog('=== TEST VARIANTES URLs ===');

      final dio = Dio();

      // Récupérer une publication avec média pour tester
      final publications = await ContentApiService().getPublications();
      if (publications.isEmpty) {
        _addLog('❌ Aucune publication trouvée');
        return;
      }

      final pub = publications.firstWhere(
        (p) => p.featuredMedia != null,
        orElse: () => publications.first,
      );

      if (pub.featuredMedia == null) {
        _addLog('❌ Aucune publication avec featured media trouvée');
        return;
      }

      final media = pub.featuredMedia!;
      _addLog('Publication: ${pub.title}');
      _addLog('Media file (raw): ${media.file}');
      _addLog('');

      // Tester différentes variantes d'URLs
      final filename = media.file.split('/').last;
      final testUrls = [
        '${AppConfig.apiBaseUrl}${media.file}', // URL directe
        '${AppConfig.apiBaseUrl}/media/${media.file}', // Avec /media/ en préfixe
        '${AppConfig.apiBaseUrl}/media/publications/media/$filename', // Format guide
        '${AppConfig.apiBaseUrl}/media/publications/$filename', // Sans /media/ final
        '${AppConfig.apiBaseUrl}/static/media/${media.file}', // Avec /static/
        '${AppConfig.apiBaseUrl}/media/${media.file.replaceFirst('/', '')}', // Sans slash initial
      ];

      for (int i = 0; i < testUrls.length; i++) {
        final url = testUrls[i];
        try {
          _addLog('Test ${i + 1}: $url');
          final response = await dio.get(url);
          _addLog('✅ SUCCESS! Status: ${response.statusCode}');
          _addLog(
              'Content-Type: ${response.headers['content-type']?.first ?? 'inconnu'}');
          _addLog(
              'Content-Length: ${response.headers['content-length']?.first ?? 'inconnu'}');
          _addLog('*** CETTE URL FONCTIONNE ! ***');
          break; // Arrêter au premier succès
        } catch (e) {
          _addLog(
              '❌ Status: ${e.toString().contains('404') ? '404' : 'Erreur'}');
        }
        _addLog('');
      }
    } catch (e) {
      _addLog('❌ Erreur: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testFeaturedPublications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addLog('=== TEST PUBLICATIONS MISES EN AVANT ===');

      final contentApiService = ContentApiService();
      final featuredPublications =
          await contentApiService.getFeaturedPublications();

      _addLog(
          '✅ Publications mises en avant récupérées: ${featuredPublications.length}');

      for (int i = 0; i < featuredPublications.length; i++) {
        final publication = featuredPublications[i];
        _addLog('');
        _addLog('📰 Publication ${i + 1}: ${publication.title}');
        _addLog('   - ID: ${publication.id}');
        _addLog(
            '   - Featured Media: ${publication.featuredMedia?.file ?? "null"}');
        _addLog('   - Media count: ${publication.media?.length ?? 0}');
        _addLog('   - Has media: ${publication.hasMedia}');
        _addLog(
            '   - Primary image URL: ${publication.primaryImageFullUrl ?? "null"}');

        if (publication.featuredMedia != null) {
          final media = publication.featuredMedia!;
          _addLog('   - Featured media type: ${media.mediaType}');
          _addLog('   - Featured media isImage: ${media.isImage}');
          _addLog('   - Featured media fullUrl: ${media.fullUrl}');
        }

        if (publication.media != null && publication.media!.isNotEmpty) {
          _addLog('   - Médias supplémentaires:');
          for (int j = 0; j < publication.media!.length; j++) {
            final media = publication.media![j];
            _addLog('     * Media ${j + 1}: ${media.file}');
            _addLog(
                '       Type: ${media.mediaType}, isImage: ${media.isImage}');
            _addLog('       FullUrl: ${media.fullUrl}');
          }
        }
      }
    } catch (e) {
      _addLog('❌ Erreur: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testPublicationsComparison() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addLog('=== COMPARAISON PUBLICATIONS NORMALES VS MISES EN AVANT ===');

      final contentApiService = ContentApiService();

      // Test publications normales
      _addLog('');
      _addLog('📋 PUBLICATIONS NORMALES:');
      final normalPublications = await contentApiService.getPublications();
      _addLog(
          '✅ Publications normales récupérées: ${normalPublications.length}');

      for (int i = 0;
          i < (normalPublications.length > 3 ? 3 : normalPublications.length);
          i++) {
        final publication = normalPublications[i];
        _addLog('   📰 ${i + 1}. ${publication.title}');
        _addLog(
            '      - featuredMedia: ${publication.featuredMedia?.file ?? "null"}');
        _addLog('      - media count: ${publication.media?.length ?? 0}');
        _addLog(
            '      - primaryImageFullUrl: ${publication.primaryImageFullUrl ?? "null"}');
      }

      // Test publications mises en avant
      _addLog('');
      _addLog('⭐ PUBLICATIONS MISES EN AVANT:');
      final featuredPublications =
          await contentApiService.getFeaturedPublications();
      _addLog(
          '✅ Publications mises en avant récupérées: ${featuredPublications.length}');

      for (int i = 0; i < featuredPublications.length; i++) {
        final publication = featuredPublications[i];
        _addLog('   ⭐ ${i + 1}. ${publication.title}');
        _addLog(
            '      - featuredMedia: ${publication.featuredMedia?.file ?? "null"}');
        _addLog('      - media count: ${publication.media?.length ?? 0}');
        _addLog(
            '      - primaryImageFullUrl: ${publication.primaryImageFullUrl ?? "null"}');

        if (publication.featuredMedia != null) {
          _addLog(
              '      - featuredMedia type: ${publication.featuredMedia!.mediaType}');
          _addLog(
              '      - featuredMedia isImage: ${publication.featuredMedia!.isImage}');
        }
      }

      // Comparaison
      _addLog('');
      _addLog('🔍 ANALYSE:');
      final normalWithFeatured =
          normalPublications.where((p) => p.featuredMedia != null).length;
      final featuredWithFeatured =
          featuredPublications.where((p) => p.featuredMedia != null).length;

      _addLog(
          '   - Publications normales avec featuredMedia: $normalWithFeatured/${normalPublications.length}');
      _addLog(
          '   - Publications mises en avant avec featuredMedia: $featuredWithFeatured/${featuredPublications.length}');

      final normalWithImages =
          normalPublications.where((p) => p.primaryImageFullUrl != null).length;
      final featuredWithImages = featuredPublications
          .where((p) => p.primaryImageFullUrl != null)
          .length;

      _addLog(
          '   - Publications normales avec images: $normalWithImages/${normalPublications.length}');
      _addLog(
          '   - Publications mises en avant avec images: $featuredWithImages/${featuredPublications.length}');
    } catch (e) {
      _addLog('❌ Erreur: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testCarouselSpecifically() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addLog('=== TEST CARROUSEL SPÉCIFIQUE ===');

      final contentApiService = ContentApiService();
      final publications = await contentApiService.getPublications();
      if (publications.isEmpty) {
        _addLog('❌ Aucune publication trouvée');
        return;
      }

      final pub = publications.firstWhere(
        (p) => p.featuredMedia != null,
        orElse: () => publications.first,
      );

      if (pub.featuredMedia == null) {
        _addLog('❌ Aucune publication avec featured media trouvée');
        return;
      }

      final media = pub.featuredMedia!;
      _addLog('Publication: ${pub.title}');
      _addLog('Media file (raw): ${media.file}');
      _addLog('');

      // Tester le carrousel spécifique
      final testUrls = [
        '${AppConfig.apiBaseUrl}${media.file}',
        '${AppConfig.apiBaseUrl}/media/${media.file}',
        '${AppConfig.apiBaseUrl}/media/publications/media/${media.file.split('/').last}',
        '${AppConfig.apiBaseUrl}/media/publications/${media.file.split('/').last}',
        '${AppConfig.apiBaseUrl}/static/media/${media.file}',
        '${AppConfig.apiBaseUrl}/media/${media.file.replaceFirst('/', '')}',
      ];

      for (int i = 0; i < testUrls.length; i++) {
        final url = testUrls[i];
        try {
          _addLog('Test ${i + 1}: $url');
          final response = await Dio().get(url);
          _addLog('✅ SUCCESS! Status: ${response.statusCode}');
          _addLog(
              'Content-Type: ${response.headers['content-type']?.first ?? 'inconnu'}');
          _addLog(
              'Content-Length: ${response.headers['content-length']?.first ?? 'inconnu'}');
          _addLog('*** CETTE URL FONCTIONNE ! ***');
          break; // Arrêter au premier succès
        } catch (e) {
          _addLog(
              '❌ Status: ${e.toString().contains('404') ? '404' : 'Erreur'}');
        }
        _addLog('');
      }
    } catch (e) {
      _addLog('❌ Erreur: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

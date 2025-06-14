import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:venturelink/core/config/app_config.dart';

class TestImageWidget extends StatelessWidget {
  const TestImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // URLs de test basées sur les images générées par le backend
    final testUrls = [
      '${AppConfig.apiBaseUrl}/media/projects/media/0ec995c1af3444618581294bddb91b49_1749619478.jpg',
      '${AppConfig.apiBaseUrl}/media/projects/media/fd697a19a5ce4fdd9fcaad0bb50c1b4b_1749619458.jpg',
      '${AppConfig.apiBaseUrl}/media/projects/media/639e3fffec15461c857e73c5bba1d5ec_1749619458.jpg',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Images Projets'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: testUrls.length,
        itemBuilder: (context, index) {
          final url = testUrls[index];
          return Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Image ${index + 1}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      debugPrint('❌ Test Image Error: $url - $error');
                      return Container(
                        color: Colors.red[100],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error, color: Colors.red),
                              const SizedBox(height: 8),
                              Text(
                                'Erreur: $error',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    url,
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

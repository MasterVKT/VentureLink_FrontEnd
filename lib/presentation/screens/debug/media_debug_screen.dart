import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/data/providers/project_provider.dart';
import 'package:venturelink/data/models/project_model.dart';

/// Écran de debug temporaire pour analyser les médias des projets
class MediaDebugScreen extends StatelessWidget {
  const MediaDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Médias'),
        backgroundColor: Colors.orange,
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.projects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.projects.isEmpty) {
            return const Center(
              child: Text('Aucun projet disponible pour le debug'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.projects.length,
            itemBuilder: (context, index) {
              final project = provider.projects[index];
              return _ProjectMediaDebugCard(project: project);
            },
          );
        },
      ),
    );
  }
}

class _ProjectMediaDebugCard extends StatelessWidget {
  final ProjectModel project;

  const _ProjectMediaDebugCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre du projet
            Text(
              project.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Informations générales sur les médias
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📊 Résumé des médias',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('🔗 Système utilisé', _getMediaSystemInfo()),
                  _buildInfoRow(
                      '📁 Nombre total', '${project.allMedia.length}'),
                  _buildInfoRow('📷 Images', '${project.imageMedias.length}'),
                  _buildInfoRow('🎥 Vidéos', '${project.videoMedias.length}'),
                  _buildInfoRow(
                      '📄 Documents', '${project.documentMedias.length}'),
                  _buildInfoRow('🎯 A plusieurs médias',
                      project.hasMultipleMedia ? 'Oui' : 'Non'),
                  _buildInfoRow(
                      '💬 Description', project.mediaTypesDescription),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Détail des médias via nouveau système
            if (project.mediaList.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔥 NOUVEAUX MÉDIAS (media_urls)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...project.mediaList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final media = entry.value;
                      return _buildMediaItem(media, index + 1);
                    }),
                  ],
                ),
              ),
            ],

            // Médias via ancien système (rétrocompatibilité)
            if (project.primaryImageUrl != null &&
                project.primaryImageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📸 IMAGE PRINCIPALE (legacy)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                        'URL brute', project.primaryImageUrl ?? 'null'),
                    _buildInfoRow(
                        'URL complète', project.fullImageUrl ?? 'null'),
                  ],
                ),
              ),
            ],

            // Médias via ancien système ProjectMediaModel
            if (project.media != null && project.media!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📂 ANCIENS MÉDIAS (ProjectMediaModel)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...project.media!.asMap().entries.map((entry) {
                      final index = entry.key;
                      final mediaModel = entry.value;
                      return _buildLegacyMediaItem(mediaModel, index + 1);
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaItem(ProjectMedia media, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: media.isPrimary ? Colors.yellow.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color:
              media.isPrimary ? Colors.yellow.shade600 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Média #$index ${media.isPrimary ? "⭐ PRINCIPAL" : ""}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          _buildInfoRow('ID', media.id),
          _buildInfoRow('Type', media.type),
          _buildInfoRow('URL', media.url),
          if (media.title != null) _buildInfoRow('Titre', media.title!),
          if (media.description != null)
            _buildInfoRow('Description', media.description!),
          _buildInfoRow('Ordre', media.order.toString()),
        ],
      ),
    );
  }

  Widget _buildLegacyMediaItem(ProjectMediaModel mediaModel, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ancien Média #$index',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          _buildInfoRow('ID', mediaModel.id),
          _buildInfoRow('Type', mediaModel.mediaType),
          _buildInfoRow('URL', mediaModel.fileUrl ?? 'null'),
          if (mediaModel.caption != null)
            _buildInfoRow('Caption', mediaModel.caption!),
          _buildInfoRow('Ordre', mediaModel.displayOrder.toString()),
        ],
      ),
    );
  }

  String _getMediaSystemInfo() {
    if (project.mediaList.isNotEmpty) {
      return '🔥 NOUVEAU (media_urls)';
    } else if (project.primaryImageUrl != null ||
        (project.media != null && project.media!.isNotEmpty)) {
      return '📸 LEGACY (primary_image_url + media)';
    } else {
      return '❌ Aucun média';
    }
  }
}

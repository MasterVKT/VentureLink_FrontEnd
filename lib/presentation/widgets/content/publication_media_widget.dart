import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/publication_model.dart';
import '../../../core/utils/logger.dart';

/// Widget simple pour afficher les médias de publications
class PublicationMediaWidget extends StatelessWidget {
  final PublicationMedia media;
  final bool showDescription;
  final double? height;

  const PublicationMediaWidget({
    super.key,
    required this.media,
    this.showDescription = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.info('=== DEBUT AFFICHAGE MEDIA ===');
    AppLogger.info('Media ID: ${media.id}');
    AppLogger.info('Media Type: ${media.mediaType}');
    AppLogger.info('Media File (raw): ${media.file}');
    AppLogger.info('Media FullURL: ${media.fullUrl}');
    AppLogger.info('Media Title: ${media.title}');
    AppLogger.info('Media Description: ${media.description}');
    AppLogger.info('=== FIN LOGS MEDIA ===');

    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre du média si disponible
          if (media.title != null && media.title!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                media.title!,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],

          // Contenu du média
          Expanded(child: _buildMediaContent(context)),

          // Description du média si disponible et demandée
          if (showDescription &&
              media.description != null &&
              media.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              media.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaContent(BuildContext context) {
    AppLogger.info('_buildMediaContent appelé avec type: ${media.mediaType}');

    // Utiliser les méthodes du modèle qui détectent les types MIME
    if (media.isImage) {
      AppLogger.info('🖼️ Type détecté: IMAGE');
      return _buildImageMedia(context);
    } else if (media.isVideo) {
      AppLogger.info('🎥 Type détecté: VIDEO');
      return _buildVideoMedia(context);
    } else if (media.isAudio) {
      AppLogger.info('🎵 Type détecté: AUDIO');
      return _buildAudioMedia(context);
    } else if (media.isDocument) {
      AppLogger.info('📄 Type détecté: DOCUMENT');
      return _buildDocumentMedia(context);
    } else {
      AppLogger.warning('Type de média non supporté: ${media.mediaType}');
      return _buildUnsupportedMedia(context);
    }
  }

  Widget _buildImageMedia(BuildContext context) {
    AppLogger.info('💡 *** CONSTRUCTION IMAGE MEDIA ***');
    AppLogger.info('💡 URL finale à charger: ${media.fullUrl}');

    // 🔍 Vérification de validité de l'URL
    final imageUrl = media.fullUrl;
    final isValidUrl =
        imageUrl.startsWith('http') && !imageUrl.contains('test');

    if (!isValidUrl) {
      AppLogger.warning('⚠️ URL invalide détectée: $imageUrl');
      AppLogger.info('💡 Utilisation d\'une image placeholder');
    }

    final finalImageUrl = isValidUrl
        ? imageUrl
        : 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: finalImageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) {
          AppLogger.info('💡 Chargement image: $url');
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        errorWidget: (context, url, error) {
          AppLogger.error('⛔ *** ERREUR CHARGEMENT IMAGE ***');
          AppLogger.error('⛔ URL: $url');
          AppLogger.error('⛔ Erreur: $error');

          // 🔄 Fallback vers une image placeholder en cas d'erreur
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  'Image non disponible',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (media.title != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    media.title!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoMedia(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Vidéo',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _launchUrl(media.fullUrl),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioMedia(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.audiotrack,
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  media.title ?? 'Audio',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (media.fileSize != null)
                  Text(
                    _formatFileSize(media.fileSize!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _launchUrl(media.fullUrl),
            icon: const Icon(Icons.play_arrow),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentMedia(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.description,
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  media.title ?? 'Document',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (media.fileSize != null)
                  Text(
                    _formatFileSize(media.fileSize!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _launchUrl(media.fullUrl),
            icon: const Icon(Icons.download),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedMedia(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.help_outline,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'Type de média non supporté',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            'Type: ${media.mediaType}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      AppLogger.error('Impossible d\'ouvrir l\'URL: $url');
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes == 0) return '0 Bytes';
    const k = 1024;
    final sizes = ['Bytes', 'KB', 'MB', 'GB'];
    final i = (bytes > 0 ? (bytes.bitLength - 1) ~/ 10 : 0)
        .clamp(0, sizes.length - 1);
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(i > 0 ? 2 : 0)} ${sizes[i]}';
  }
}

/// Widget pour afficher une liste de médias
class PublicationMediaList extends StatelessWidget {
  final List<PublicationMedia> mediaList;
  final bool showDescriptions;

  const PublicationMediaList({
    super.key,
    required this.mediaList,
    this.showDescriptions = true,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaList.isEmpty) return const SizedBox.shrink();

    // Trier les médias par ordre (si disponible)
    final sortedMedia = [...mediaList]
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    AppLogger.info('Affichage liste de ${sortedMedia.length} médias');

    return Column(
      children: [
        ...sortedMedia.map((media) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: PublicationMediaWidget(
                media: media,
                showDescription: showDescriptions,
                height: 200,
              ),
            )),
      ],
    );
  }
}

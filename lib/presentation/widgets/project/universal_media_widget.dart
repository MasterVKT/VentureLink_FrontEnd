import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/core/config/app_config.dart';
import 'package:url_launcher/url_launcher.dart';

/// Énumération des types de médias supportés
enum MediaType {
  image,
  video,
  document,
}

/// Widget universel pour afficher tous les types de médias
class UniversalMediaWidget extends StatelessWidget {
  final ProjectMediaModel media;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final String? debugContext;
  final VoidCallback? onTap;

  const UniversalMediaWidget({
    super.key,
    required this.media,
    this.height = 200,
    this.width,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.debugContext,
    this.onTap,
  });

  String get fullMediaUrl {
    if (media.fileUrl == null || media.fileUrl!.isEmpty) return '';

    if (media.fileUrl!.startsWith('http')) {
      return media.fileUrl!;
    }
    return '${AppConfig.apiBaseUrl}${media.fileUrl!}';
  }

  MediaType get mediaType {
    switch (media.mediaType.toUpperCase()) {
      case 'IMAGE':
        return MediaType.image;
      case 'VIDEO':
        return MediaType.video;
      case 'DOCUMENT':
        return MediaType.document;
      default:
        // Détection par extension de fichier
        final url = fullMediaUrl.toLowerCase();
        if (url.contains('.jpg') ||
            url.contains('.jpeg') ||
            url.contains('.png') ||
            url.contains('.gif') ||
            url.contains('.webp')) {
          return MediaType.image;
        } else if (url.contains('.mp4') ||
            url.contains('.avi') ||
            url.contains('.mov') ||
            url.contains('.webm')) {
          return MediaType.video;
        } else if (url.contains('.pdf') ||
            url.contains('.doc') ||
            url.contains('.docx') ||
            url.contains('.txt')) {
          return MediaType.document;
        }
        return MediaType.image; // Par défaut
    }
  }

  @override
  Widget build(BuildContext context) {
    if (fullMediaUrl.isEmpty) {
      return _buildPlaceholder(context);
    }

    return GestureDetector(
      onTap: onTap ?? () => _handleMediaTap(context),
      child: SizedBox(
        height: height,
        width: width ?? double.infinity,
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          child: _buildMediaContent(context),
        ),
      ),
    );
  }

  Widget _buildMediaContent(BuildContext context) {
    switch (mediaType) {
      case MediaType.image:
        return _buildImageContent(context);
      case MediaType.video:
        return _buildVideoContent(context);
      case MediaType.document:
        return _buildDocumentContent(context);
    }
  }

  Widget _buildImageContent(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: fullMediaUrl,
      fit: fit,
      placeholder: (context, url) => _buildLoadingPlaceholder(context),
      errorWidget: (context, url, error) => _buildErrorWidget(context, error),
    );
  }

  Widget _buildVideoContent(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Thumbnail de la vidéo
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vidéo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Badge type de média
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'VIDÉO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentContent(BuildContext context) {
    final extension = _getFileExtension(fullMediaUrl);
    final icon = _getDocumentIcon(extension);
    final color = _getDocumentColor(extension);

    return Container(
      color: color.withValues(alpha: 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: height > 150 ? 48 : 32,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            'Document',
            style: TextStyle(
              color: color,
              fontSize: height > 150 ? 14 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (extension.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              extension.toUpperCase(),
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: height > 150 ? 12 : 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file,
            color: Colors.grey[600],
            size: height > 150 ? 48 : 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Aucun média',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: height > 150 ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, dynamic error) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.grey[600],
            size: height > 150 ? 48 : 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: height > 150 ? 12 : 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleMediaTap(BuildContext context) {
    switch (mediaType) {
      case MediaType.image:
        _showImageFullScreen(context);
        break;
      case MediaType.video:
      case MediaType.document:
        _openExternalMedia();
        break;
    }
  }

  void _showImageFullScreen(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: fullMediaUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openExternalMedia() async {
    try {
      final uri = Uri.parse(fullMediaUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'ouverture du média: $e');
    }
  }

  String _getFileExtension(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return '';

    final path = uri.path.toLowerCase();
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1) return '';

    return path.substring(lastDot + 1);
  }

  IconData _getDocumentIcon(String extension) {
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getDocumentColor(String extension) {
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'txt':
        return Colors.grey;
      case 'zip':
      case 'rar':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

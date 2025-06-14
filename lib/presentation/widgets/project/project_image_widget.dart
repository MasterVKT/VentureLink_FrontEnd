import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:venturelink/data/models/project_model.dart';

/// Widget réutilisable pour l'affichage des images de projets
class ProjectImageWidget extends StatelessWidget {
  final ProjectModel project;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final String? debugContext;

  const ProjectImageWidget({
    super.key,
    required this.project,
    this.height = 200,
    this.width,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.debugContext,
  });

  @override
  Widget build(BuildContext context) {
    if (!project.hasImage) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: project.fullImageUrl!,
          fit: fit,
          placeholder: (context, url) => Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) {
            // Log de debug avec contexte
            final contextInfo = debugContext != null ? ' ($debugContext)' : '';
            debugPrint('❌ Erreur chargement image$contextInfo: $url');
            debugPrint('   Erreur: $error');
            debugPrint('   Projet: ${project.title}');

            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: borderRadius ?? BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    size: height > 150 ? 40 : 24,
                    color: Colors.grey[600],
                  ),
                  SizedBox(height: height > 150 ? 8 : 4),
                  Text(
                    'Image non disponible',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: height > 150 ? 12 : 10,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Widget spécialisé pour les images de carrousel
class CarouselProjectImageWidget extends StatelessWidget {
  final ProjectModel project;

  const CarouselProjectImageWidget({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return ProjectImageWidget(
      project: project,
      height: 115,
      borderRadius: BorderRadius.zero,
      debugContext: 'carrousel',
    );
  }
}

/// Widget spécialisé pour les images du fil d'actualité
class FeedProjectImageWidget extends StatelessWidget {
  final ProjectModel project;

  const FeedProjectImageWidget({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ProjectImageWidget(
        project: project,
        height: 200,
        borderRadius: BorderRadius.circular(8),
        debugContext: 'fil d\'actualité',
      ),
    );
  }
}

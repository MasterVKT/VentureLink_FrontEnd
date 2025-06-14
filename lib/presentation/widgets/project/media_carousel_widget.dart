import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/core/config/app_config.dart';

/// Widget carrousel pour afficher plusieurs médias d'un projet
class MediaCarouselWidget extends StatefulWidget {
  final ProjectModel project;
  final double height;
  final BorderRadius? borderRadius;
  final bool showIndicators;
  final String? debugContext;

  const MediaCarouselWidget({
    super.key,
    required this.project,
    this.height = 200,
    this.borderRadius,
    this.showIndicators = true,
    this.debugContext,
  });

  @override
  State<MediaCarouselWidget> createState() => _MediaCarouselWidgetState();
}

class _MediaCarouselWidgetState extends State<MediaCarouselWidget> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> get _mediaUrls {
    final urls = <String>[];

    // Ajouter l'image principale si disponible
    if (widget.project.primaryImageUrl != null &&
        widget.project.primaryImageUrl!.isNotEmpty) {
      final fullUrl = widget.project.primaryImageUrl!.startsWith('http')
          ? widget.project.primaryImageUrl!
          : '${AppConfig.apiBaseUrl}${widget.project.primaryImageUrl!}';
      urls.add(fullUrl);
    }

    // Ajouter les autres médias si disponibles
    if (widget.project.media != null) {
      for (final media in widget.project.media!) {
        if (media.fileUrl != null && media.fileUrl!.isNotEmpty) {
          final fullUrl = media.fileUrl!.startsWith('http')
              ? media.fileUrl!
              : '${AppConfig.apiBaseUrl}${media.fileUrl!}';
          // Éviter les doublons avec l'image principale
          if (!urls.contains(fullUrl)) {
            urls.add(fullUrl);
          }
        }
      }
    }

    return urls;
  }

  bool get _hasMultipleMedia => _mediaUrls.length > 1;

  @override
  Widget build(BuildContext context) {
    final mediaUrls = _mediaUrls;

    if (mediaUrls.isEmpty) {
      return _buildPlaceholder();
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Carrousel principal
          ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: mediaUrls.length,
              itemBuilder: (context, index) {
                return _buildMediaItem(mediaUrls[index], index);
              },
            ),
          ),

          // Indicateurs de position (si plusieurs médias)
          if (_hasMultipleMedia && widget.showIndicators)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: _buildIndicators(),
            ),

          // Compteur de médias (coin supérieur droit)
          if (_hasMultipleMedia)
            Positioned(
              top: 8,
              right: 8,
              child: _buildMediaCounter(),
            ),

          // Boutons de navigation (si plusieurs médias)
          if (_hasMultipleMedia) ...[
            // Bouton précédent
            if (_currentIndex > 0)
              Positioned(
                left: 8,
                top: widget.height / 2 - 20,
                child: _buildNavigationButton(
                  icon: Icons.chevron_left,
                  onTap: () => _previousMedia(),
                ),
              ),

            // Bouton suivant
            if (_currentIndex < mediaUrls.length - 1)
              Positioned(
                right: 8,
                top: widget.height / 2 - 20,
                child: _buildNavigationButton(
                  icon: Icons.chevron_right,
                  onTap: () => _nextMedia(),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaItem(String imageUrl, int index) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) {
        final contextInfo =
            widget.debugContext != null ? ' (${widget.debugContext})' : '';
        debugPrint('❌ Erreur chargement média$contextInfo: $url');
        debugPrint('   Index: $index');
        debugPrint('   Erreur: $error');
        debugPrint('   Projet: ${widget.project.title}');

        return Container(
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image,
                size: widget.height > 150 ? 40 : 24,
                color: Colors.grey[600],
              ),
              SizedBox(height: widget.height > 150 ? 8 : 4),
              Text(
                'Média non disponible',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: widget.height > 150 ? 12 : 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: widget.height > 150 ? 48 : 32,
            color: Colors.grey[600],
          ),
          SizedBox(height: widget.height > 150 ? 8 : 4),
          Text(
            'Aucun média',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: widget.height > 150 ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_mediaUrls.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentIndex == index
                ? Colors.white
                : Colors.white.withOpacity(0.5),
          ),
        );
      }),
    );
  }

  Widget _buildMediaCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${_currentIndex + 1}/${_mediaUrls.length}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  void _previousMedia() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextMedia() {
    if (_currentIndex < _mediaUrls.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}

/// Widget spécialisé pour le carrousel dans le fil d'actualité
class FeedMediaCarouselWidget extends StatelessWidget {
  final ProjectModel project;

  const FeedMediaCarouselWidget({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: MediaCarouselWidget(
        project: project,
        height: 200,
        borderRadius: BorderRadius.circular(8),
        debugContext: 'fil d\'actualité',
      ),
    );
  }
}

/// Widget spécialisé pour le carrousel dans le carrousel principal
class CarouselMediaWidget extends StatelessWidget {
  final ProjectModel project;

  const CarouselMediaWidget({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return MediaCarouselWidget(
      project: project,
      height: 115,
      borderRadius: BorderRadius.zero,
      showIndicators: false, // Pas d'indicateurs dans le carrousel principal
      debugContext: 'carrousel principal',
    );
  }
}

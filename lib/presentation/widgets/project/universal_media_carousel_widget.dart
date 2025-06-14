import 'package:flutter/material.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/presentation/widgets/project/universal_media_widget.dart';

/// Classe adaptateur pour unifier les deux types de médias
class MediaAdapter {
  final String id;
  final String url;
  final String type;
  final String? title;
  final String? description;
  final bool isPrimary;
  final int order;

  MediaAdapter({
    required this.id,
    required this.url,
    required this.type,
    this.title,
    this.description,
    this.isPrimary = false,
    this.order = 0,
  });

  /// Convertir ProjectMedia vers MediaAdapter
  factory MediaAdapter.fromProjectMedia(ProjectMedia media) {
    return MediaAdapter(
      id: media.id,
      url: media.url,
      type: media.type,
      title: media.title,
      description: media.description,
      isPrimary: media.isPrimary,
      order: media.order,
    );
  }

  /// Convertir ProjectMediaModel vers MediaAdapter
  factory MediaAdapter.fromProjectMediaModel(ProjectMediaModel media) {
    return MediaAdapter(
      id: media.id,
      url: media.fileUrl ?? '',
      type: media.mediaType,
      title: media.caption,
      description: null,
      isPrimary: false,
      order: media.displayOrder,
    );
  }

  /// Convertir vers ProjectMediaModel pour compatibilité avec UniversalMediaWidget
  ProjectMediaModel toProjectMediaModel() {
    return ProjectMediaModel(
      id: id,
      projectId: '',
      mediaType: type,
      fileUrl: url,
      caption: title ?? description,
      displayOrder: order,
      createdAt: DateTime.now(),
    );
  }
}

/// Widget carrousel universel pour afficher tous les types de médias
class UniversalMediaCarouselWidget extends StatefulWidget {
  final List<dynamic>
      mediaList; // Accepte List<ProjectMedia> ou List<ProjectMediaModel>
  final double height;
  final bool showIndicators;
  final bool showCounter;
  final bool showNavigationButtons;
  final String? debugContext;

  const UniversalMediaCarouselWidget({
    super.key,
    required this.mediaList,
    this.height = 200,
    this.showIndicators = true,
    this.showCounter = true,
    this.showNavigationButtons = true,
    this.debugContext,
  });

  /// Convertir la liste vers des MediaAdapter
  List<MediaAdapter> get adaptedMediaList {
    return mediaList.map((media) {
      if (media is ProjectMedia) {
        return MediaAdapter.fromProjectMedia(media);
      } else if (media is ProjectMediaModel) {
        return MediaAdapter.fromProjectMediaModel(media);
      } else {
        throw ArgumentError('Type de média non supporté: ${media.runtimeType}');
      }
    }).toList();
  }

  @override
  State<UniversalMediaCarouselWidget> createState() =>
      _UniversalMediaCarouselWidgetState();
}

class _UniversalMediaCarouselWidgetState
    extends State<UniversalMediaCarouselWidget> {
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

  @override
  Widget build(BuildContext context) {
    final adaptedList = widget.adaptedMediaList;

    if (adaptedList.isEmpty) {
      return const SizedBox.shrink();
    }

    if (adaptedList.length == 1) {
      return UniversalMediaWidget(
        media: adaptedList.first.toProjectMediaModel(),
        height: widget.height,
        debugContext: widget.debugContext,
      );
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Carrousel principal
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: adaptedList.length,
            itemBuilder: (context, index) {
              return UniversalMediaWidget(
                media: adaptedList[index].toProjectMediaModel(),
                height: widget.height,
                debugContext:
                    '${widget.debugContext} - ${index + 1}/${adaptedList.length}',
              );
            },
          ),

          // Compteur de médias (coin supérieur droit)
          if (widget.showCounter)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentIndex + 1}/${adaptedList.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Boutons de navigation
          if (widget.showNavigationButtons && adaptedList.length > 1) ...[
            // Bouton précédent
            if (_currentIndex > 0)
              Positioned(
                left: 8,
                top: widget.height / 2 - 20,
                child: GestureDetector(
                  onTap: _previousMedia,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),

            // Bouton suivant
            if (_currentIndex < adaptedList.length - 1)
              Positioned(
                right: 8,
                top: widget.height / 2 - 20,
                child: GestureDetector(
                  onTap: _nextMedia,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
          ],

          // Indicateurs de position (points en bas)
          if (widget.showIndicators && adaptedList.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  adaptedList.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ),
        ],
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
    final adaptedList = widget.adaptedMediaList;
    if (_currentIndex < adaptedList.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}

/// Widget carrousel compact pour les listes de projets
class CompactUniversalMediaCarouselWidget extends StatelessWidget {
  final List<dynamic>
      mediaList; // Accepte List<ProjectMedia> ou List<ProjectMediaModel>
  final String? debugContext;

  const CompactUniversalMediaCarouselWidget({
    super.key,
    required this.mediaList,
    this.debugContext,
  });

  @override
  Widget build(BuildContext context) {
    return UniversalMediaCarouselWidget(
      mediaList: mediaList,
      height: 115,
      showIndicators: false,
      showCounter: true,
      showNavigationButtons: false,
      debugContext: debugContext,
    );
  }
}

/// Widget carrousel pour le fil d'actualité
class FeedUniversalMediaCarouselWidget extends StatelessWidget {
  final List<dynamic>
      mediaList; // Accepte List<ProjectMedia> ou List<ProjectMediaModel>
  final String? debugContext;

  const FeedUniversalMediaCarouselWidget({
    super.key,
    required this.mediaList,
    this.debugContext,
  });

  @override
  Widget build(BuildContext context) {
    return UniversalMediaCarouselWidget(
      mediaList: mediaList,
      height: 200,
      showIndicators: true,
      showCounter: true,
      showNavigationButtons: true,
      debugContext: debugContext,
    );
  }
}

// UniversalMediaWidget est maintenant importé depuis universal_media_widget.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/media_file.dart';

/// Widget d'upload de médias (images et vidéos)
///
/// Fonctionnalités:
/// - Upload multiple (jusqu'à 10 médias)
/// - Support images (JPEG, PNG) et vidéos (MP4)
/// - Aperçu immédiat après sélection
/// - Compression automatique des images
/// - Réorganisation par drag & drop
/// - Possibilité de supprimer
/// - Barre de progression
/// - Limites de taille: 5 MB image, 50 MB vidéo
class MediaUploader extends StatefulWidget {
  final List<MediaFile> initialMedia;
  final Function(List<MediaFile>) onMediaChanged;
  final int maxMedia;
  final bool allowVideo;
  final bool showDescriptions;

  const MediaUploader({
    super.key,
    this.initialMedia = const [],
    required this.onMediaChanged,
    this.maxMedia = 10,
    this.allowVideo = true,
    this.showDescriptions = true,
  });

  @override
  State<MediaUploader> createState() => _MediaUploaderState();
}

class _MediaUploaderState extends State<MediaUploader> {
  late List<MediaFile> _mediaFiles;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // Limites de taille en bytes
  static const int maxImageSize = 5 * 1024 * 1024; // 5 MB
  static const int maxVideoSize = 50 * 1024 * 1024; // 50 MB

  @override
  void initState() {
    super.initState();
    _mediaFiles = List.from(widget.initialMedia);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header avec compteur
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Médias (${_mediaFiles.length}/${widget.maxMedia})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (_mediaFiles.length < widget.maxMedia)
              PopupMenuButton<String>(
                onSelected: _handleMediaSelection,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'image',
                    child: Row(
                      children: [
                        Icon(Icons.photo_library),
                        SizedBox(width: 8),
                        Text('Ajouter des images'),
                      ],
                    ),
                  ),
                  if (widget.allowVideo)
                    const PopupMenuItem(
                      value: 'video',
                      child: Row(
                        children: [
                          Icon(Icons.videocam),
                          SizedBox(width: 8),
                          Text('Ajouter des vidéos'),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Grille de médias
        if (_mediaFiles.isEmpty)
          _buildEmptyState()
        else
          _buildMediaGrid(),

        // Barre de progression
        if (_isUploading) ...[
          const SizedBox(height: 16),
          LinearProgressIndicator(value: _uploadProgress),
          const SizedBox(height: 8),
          Text(
            'Upload en cours... ${(_uploadProgress * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Ajoutez des médias pour rendre votre projet plus attractif',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Jusqu\'à ${widget.maxMedia} images et vidéos',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _pickImages(),
            icon: const Icon(Icons.photo_library),
            label: const Text('Sélectionner des images'),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _mediaFiles.length,
      itemBuilder: (context, index) {
        final media = _mediaFiles[index];
        return _buildMediaItem(media, index);
      },
    );
  }

  Widget _buildMediaItem(MediaFile media, int index) {
    return Stack(
      children: [
        // Aperçu
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: _buildMediaPreview(media),
          ),
        ),

        // Badge type
        if (media.isVideo)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.videocam,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),

        // Badge statut upload
        if (media.isUploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),

        // Bouton supprimer
        Positioned(
          top: 4,
          left: 4,
          child: GestureDetector(
            onTap: () => _removeMedia(media),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),

        // Numéro d'ordre
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaPreview(MediaFile media) {
    if (media.file != null) {
      // Fichier local
      if (media.isImage) {
        return Image.file(
          media.file!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image);
          },
        );
      } else if (media.isVideo) {
        return FutureBuilder<File?>(
          future: _generateVideoThumbnail(media.file!),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Image.file(
                snapshot.data!,
                fit: BoxFit.cover,
              );
            }
            return const Icon(Icons.videocam);
          },
        );
      }
    } else if (media.url != null) {
      // URL distante
      if (media.isImage) {
        return Image.network(
          media.url!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image);
          },
        );
      } else if (media.isVideo) {
        return Image.network(
          media.thumbnailUrl ?? media.url!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.videocam);
          },
        );
      }
    }

    return const Icon(Icons.image);
  }

  Future<File?> _generateVideoThumbnail(File videoFile) async {
    try {
      // Utiliser video_thumbnail si disponible, sinon retourner null
      // Pour l'instant, on retourne null
      return null;
    } catch (e) {
      return null;
    }
  }

  void _handleMediaSelection(String type) {
    if (type == 'image') {
      _pickImages();
    } else if (type == 'video') {
      _pickVideos();
    }
  }

  Future<void> _pickImages() async {
    if (_mediaFiles.length >= widget.maxMedia) {
      _showMaxMediaReachedSnackbar();
      return;
    }

    try {
      final pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFiles.isEmpty) return;

      setState(() => _isUploading = true);

      for (final file in pickedFiles) {
        if (_mediaFiles.length >= widget.maxMedia) break;

        // Vérifier la taille
        final fileSize = await file.length();
        if (fileSize > maxImageSize) {
          _showFileSizeErrorSnackbar();
          continue;
        }

        // Compresser l'image
        final compressedFile = await _compressImage(File(file.path));

        final media = MediaFile(
          id: const Uuid().v4(),
          type: MediaType.image,
          file: compressedFile ?? File(file.path),
          fileName: file.name,
          fileSize: fileSize,
          mimeType: 'image/${file.path.split('.').last}',
          uploadStatus: UploadStatus.pending,
        );

        setState(() {
          _mediaFiles.add(media);
        });

        // Simuler l'upload (à remplacer par le vrai appel API)
        await _uploadMedia(media);
      }

      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });

      widget.onMediaChanged(_mediaFiles);
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
      _showErrorSnackbar('Erreur lors de la sélection des images: $e');
    }
  }

  Future<void> _pickVideos() async {
    if (_mediaFiles.length >= widget.maxMedia) {
      _showMaxMediaReachedSnackbar();
      return;
    }

    try {
      final video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (video == null) return;

      // Vérifier la taille
      final fileSize = await File(video.path).length();
      if (fileSize > maxVideoSize) {
        _showVideoFileSizeErrorSnackbar();
        return;
      }

      final media = MediaFile(
        id: const Uuid().v4(),
        type: MediaType.video,
        file: File(video.path),
        fileName: video.name,
        fileSize: fileSize,
        mimeType: 'video/mp4',
        uploadStatus: UploadStatus.pending,
      );

      setState(() {
        _mediaFiles.add(media);
        _isUploading = true;
      });

      // Simuler l'upload (à remplacer par le vrai appel API)
      await _uploadMedia(media);

      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });

      widget.onMediaChanged(_mediaFiles);
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
      _showErrorSnackbar('Erreur lors de la sélection de la vidéo: $e');
    }
  }

  Future<File?> _compressImage(File imageFile) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        minWidth: 1920,
        minHeight: 1080,
        quality: 85,
      );

      if (result != null) {
        // Créer un fichier temporaire à partir des bytes compressés
        final tempFile = File(imageFile.path.replaceAll(
          '.jpg',
          '_compressed.jpg',
        ));
        await tempFile.writeAsBytes(result);
        return tempFile;
      }
      return null;
    } catch (e) {
      debugPrint('Erreur de compression: $e');
      return null;
    }
  }

  Future<void> _uploadMedia(MediaFile media) async {
    // Mettre à jour le statut
    final index = _mediaFiles.indexWhere((m) => m.id == media.id);
    if (index == -1) return;

    setState(() {
      _mediaFiles[index] = media.copyWith(uploadStatus: UploadStatus.uploading);
    });

    // Simuler la progression
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        _uploadProgress = i / 100;
      });
    }

    // Simuler l'upload réussi (à remplacer par le vrai appel API)
    setState(() {
      _mediaFiles[index] = media.copyWith(
        uploadStatus: UploadStatus.uploaded,
        url: 'https://example.com/media/${media.id}',
      );
    });
  }

  void _removeMedia(MediaFile media) {
    setState(() {
      _mediaFiles.removeWhere((m) => m.id == media.id);
    });
    widget.onMediaChanged(_mediaFiles);
  }

  void _showMaxMediaReachedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vous ne pouvez pas ajouter plus de ${widget.maxMedia} médias'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFileSizeErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('L\'image dépasse la taille maximale de 5 MB'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _showVideoFileSizeErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('La vidéo dépasse la taille maximale de 50 MB'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
  }
}

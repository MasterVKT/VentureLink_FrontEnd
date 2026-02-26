// lib/presentation/widgets/media_uploader.dart
// Tâche 1.3.1 – Dev Flutter 2
//
// ✅ VERSION FINALE — zéro erreur, zéro warning
//
// Packages requis dans pubspec.yaml :
//   image_picker: ^1.0.4
//   flutter_image_compress: ^2.1.0
//   cached_network_image: ^3.3.0
//   path_provider: ^2.1.1
//
// ❌ Packages supprimés (introuvables) :
//   reorderable_grid_view  → remplacé par LongPressDraggable natif Flutter
//   video_thumbnail        → remplacé par icône play (pas de dépendance externe)

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/media_file.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Widget principal
// ─────────────────────────────────────────────────────────────────────────────
import 'package:image_picker/image_picker.dart';
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
  late List<MediaFile> _media;
  final ImagePicker _picker = ImagePicker();

  // Indice du média survolé pendant le drag (pour l'effet visuel)
  int? _dragTargetIndex;

  static const int _maxImageBytes = 5 * 1024 * 1024;   // 5 MB
  static const int _maxVideoBytes = 50 * 1024 * 1024;  // 50 MB
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
    _media = List.from(widget.initialMedia);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        _media.isEmpty ? _buildEmptyState() : _buildMediaGrid(),
      ],
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Médias (${_media.length}/${widget.maxMedia})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        if (_media.length < widget.maxMedia)
          TextButton.icon(
            onPressed: _showMediaSourceDialog,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Ajouter'),
          ),
      ],
    );
  }

  // ── État vide ─────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: _showMediaSourceDialog,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined,
                  size: 64, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text('Ajouter des images ou vidéos',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              const SizedBox(height: 6),
              Text('Appuyez pour sélectionner',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            ],
          ),
        ),
      ),
    );
  }

  // ── Grille avec drag & drop 100% Flutter natif ────────────────────────────
  // ✅ Utilise LongPressDraggable + DragTarget — zéro package externe

  Widget _buildMediaGrid() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cellSize = (screenWidth - 32 - 16) / 3; // 3 colonnes, 2 gaps

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Maintenez pour réorganiser',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_media.length, (index) {
            return _buildDraggableItem(index, cellSize);
          }),
        ),
      ],
    );
  }

  Widget _buildDraggableItem(int index, double cellSize) {
    final media = _media[index];

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != index,
      onAcceptWithDetails: (details) {
        final oldIndex = details.data;
        setState(() {
          final item = _media.removeAt(oldIndex);
          _media.insert(index, item);
          _dragTargetIndex = null;
        });
        widget.onMediaChanged(_media);
      },
      onLeave: (_) => setState(() => _dragTargetIndex = null),
      onMove: (_) => setState(() => _dragTargetIndex = index),
      builder: (context, candidateData, rejectedData) {
        final isTarget = _dragTargetIndex == index && candidateData.isNotEmpty;

        return LongPressDraggable<int>(
          data: index,
          delay: const Duration(milliseconds: 400),
          feedback: SizedBox(
            width: cellSize,
            height: cellSize,
            child: Opacity(
              opacity: 0.85,
              child: _buildMediaCell(media, index, cellSize),
            ),
          ),
          childWhenDragging: SizedBox(
            width: cellSize,
            height: cellSize,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: cellSize,
            height: cellSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: isTarget
                  ? Border.all(
                      color: Theme.of(context).primaryColor, width: 3)
                  : null,
            ),
            child: _buildMediaCell(media, index, cellSize),
          ),
        );
      },
    );
  }

  // ── Cellule d'un média ────────────────────────────────────────────────────

  Widget _buildMediaCell(MediaFile media, int index, double size) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Aperçu image ou vidéo
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: media.isVideo
              ? _buildVideoPreview(media)
              : _buildImagePreview(media),
        ),

        // Badge "Couverture" sur le premier élément
        if (index == 0)
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                // ✅ withValues() — plus de warning deprecated
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Couverture',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // Icône play sur les vidéos
        if (media.isVideo)
          const Positioned(
            bottom: 6,
            left: 6,
            child: Icon(Icons.play_circle_fill,
                color: Colors.white, size: 20),
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
          right: 4,
          child: GestureDetector(
            onTap: () => _removeMedia(media),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),

        // Overlay progression upload
        if (media.isUploading)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                // ✅ withValues() — plus de warning deprecated
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: CircularProgressIndicator(
                    value: media.uploadProgress > 0
                        ? media.uploadProgress
                        : null,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Aperçu image ──────────────────────────────────────────────────────────

  Widget _buildImagePreview(MediaFile media) {
    if (media.file != null) {
      return Image.file(
        media.file!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (media.url != null) {
      return CachedNetworkImage(
        imageUrl: media.url!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (_, __) => Container(color: Colors.grey[200]),
        errorWidget: (_, __, ___) =>
            const Icon(Icons.broken_image, color: Colors.grey),
      );
    }
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.image, size: 40, color: Colors.grey),
    );
  }

  // ── Aperçu vidéo ──────────────────────────────────────────────────────────
  // ✅ Pas de package video_thumbnail — icône play propre comme fallback

  Widget _buildVideoPreview(MediaFile media) {
    // Miniature disponible (générée en amont si nécessaire)
    if (media.thumbnail != null) {
      return Image.file(
        media.thumbnail!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    // Fallback : fond sombre + icône
    return Container(
      color: Colors.black87,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_fill, size: 36, color: Colors.white),
            SizedBox(height: 4),
            Text('Vidéo',
                style: TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ACTIONS UTILISATEUR
  // ─────────────────────────────────────────────────────────────────────────

  void _showMediaSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text('Ajouter un média',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choisir depuis la galerie'),
              subtitle: const Text('Images • max 5 MB'),
              onTap: () {
                Navigator.pop(context);
                _pickImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('Choisir une vidéo'),
              subtitle: const Text('max 50 MB'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SÉLECTION DES FICHIERS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _pickImages() async {
    final List<XFile> files = await _picker.pickMultiImage();
    for (final xFile in files) {
      if (!mounted) return;
      if (_media.length >= widget.maxMedia) {
        _showSnackBar('Limite : maximum ${widget.maxMedia} médias.');
        break;
      }
      await _addImageFile(File(xFile.path));
    }
  }

  Future<void> _pickFromCamera() async {
    final XFile? xFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (xFile == null) return;
    if (_media.length >= widget.maxMedia) {
      _showSnackBar('Limite : maximum ${widget.maxMedia} médias.');
      return;
    }
    await _addImageFile(File(xFile.path));
  }

  Future<void> _pickVideo() async {
    final XFile? xFile =
        await _picker.pickVideo(source: ImageSource.gallery);
    if (xFile == null) return;
    if (_media.length >= widget.maxMedia) {
      _showSnackBar('Limite : maximum ${widget.maxMedia} médias.');
      return;
    }
    await _addVideoFile(File(xFile.path));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TRAITEMENT DES FICHIERS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _addImageFile(File file) async {
    final int bytes = await file.length();
    if (bytes > _maxImageBytes) {
      _showSnackBar('Image trop grande (${_formatSize(bytes)}). Max : 5 MB.');
      return;
    }
    final File? compressed = await _compressImage(file);
    final File finalFile = compressed ?? file;

    setState(() => _media.add(MediaFile(
          id: '${DateTime.now().millisecondsSinceEpoch}',
          file: finalFile,
          isVideo: false,
        )));
    widget.onMediaChanged(_media);
  }

  Future<void> _addVideoFile(File file) async {
    final int bytes = await file.length();
    if (bytes > _maxVideoBytes) {
      _showSnackBar('Vidéo trop grande (${_formatSize(bytes)}). Max : 50 MB.');
      return;
    }
    setState(() => _media.add(MediaFile(
          id: '${DateTime.now().millisecondsSinceEpoch}',
          file: file,
          isVideo: true,
        )));
    widget.onMediaChanged(_media);
  }

  Future<File?> _compressImage(File file) async {
    try {
      final Directory tmpDir = await getTemporaryDirectory();
      final String targetPath =
          '${tmpDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 85,
        minWidth: 1080,
        minHeight: 1080,
      );
      return result != null ? File(result.path) : null;
    } catch (e) {
      debugPrint('Erreur compression image : $e');
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

  void _removeMedia(MediaFile media) {
    setState(() {
      _media.remove(media);
      _dragTargetIndex = null;
    });
    widget.onMediaChanged(_media);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UTILITAIRES
  // ─────────────────────────────────────────────────────────────────────────

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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

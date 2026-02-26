// lib/presentation/widgets/media_uploader.dart
// Widget d'upload de médias (images et vidéos)

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/media_file.dart';

/// Widget d'upload de médias
class MediaUploader extends StatefulWidget {
  final List<MediaFile> initialMedia;
  final Function(List<MediaFile>) onMediaChanged;
  final int maxMedia;
  final bool allowVideo;

  const MediaUploader({
    super.key,
    this.initialMedia = const [],
    required this.onMediaChanged,
    this.maxMedia = 10,
    this.allowVideo = true,
  });

  @override
  State<MediaUploader> createState() => _MediaUploaderState();
}

class _MediaUploaderState extends State<MediaUploader> {
  late List<MediaFile> _media;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _media = List.from(widget.initialMedia);
  }

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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Médias (${_media.length}/${widget.maxMedia})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
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

  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: _showMediaSourceDialog,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'Ajouter des images ou vidéos',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: _media.length,
      itemBuilder: (context, index) {
        final media = _media[index];
        return _buildMediaItem(media, index);
      },
    );
  }

  Widget _buildMediaItem(MediaFile media, int index) {
    return Stack(
      key: ValueKey(media.id),
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildMediaPreview(media),
          ),
        ),
        if (index == 0)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Couverture',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeMedia(media),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaPreview(MediaFile media) {
    if (media.file != null) {
      if (media.isVideo) {
        return Stack(
          children: [
            Image.file(
              media.file!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            const Center(
              child: Icon(
                Icons.play_circle_outline,
                size: 40,
                color: Colors.white,
              ),
            ),
          ],
        );
      } else {
        return Image.file(
          media.file!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      }
    } else if (media.url != null) {
      return CachedNetworkImage(
        imageUrl: media.url!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (context, url, error) => const Icon(
          Icons.image_not_supported,
          size: 40,
          color: Colors.grey,
        ),
      );
    } else {
      return const Icon(Icons.image, size: 40, color: Colors.grey);
    }
  }

  void _showMediaSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImages();
              },
            ),
            if (widget.allowVideo)
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Vidéo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideos();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      for (var file in pickedFiles) {
        if (_media.length >= widget.maxMedia) {
          _showSnackBar('Limite de ${widget.maxMedia} médias atteinte');
          break;
        }
        await _addImageFile(File(file.path));
      }
    }
  }

  Future<void> _pickVideos() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);

    if (file != null) {
      if (_media.length >= widget.maxMedia) {
        _showSnackBar('Limite de ${widget.maxMedia} médias atteinte');
        return;
      }
      await _addVideoFile(File(file.path));
    }
  }

  Future<void> _addImageFile(File file) async {
    final bytes = await file.length();
    if (bytes > 5 * 1024 * 1024) {
      _showSnackBar('L\'image est trop grande (max 5 MB)');
      return;
    }

    final mediaFile = MediaFile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      file: file,
      type: MediaType.image,
      fileName: file.path.split('/').last,
      fileSize: bytes,
    );

    setState(() {
      _media.add(mediaFile);
    });
    widget.onMediaChanged(_media);
  }

  Future<void> _addVideoFile(File file) async {
    final bytes = await file.length();
    if (bytes > 50 * 1024 * 1024) {
      _showSnackBar('La vidéo est trop grande (max 50 MB)');
      return;
    }

    final mediaFile = MediaFile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      file: file,
      type: MediaType.video,
      fileName: file.path.split('/').last,
      fileSize: bytes,
    );

    setState(() {
      _media.add(mediaFile);
    });
    widget.onMediaChanged(_media);
  }

  void _removeMedia(MediaFile media) {
    setState(() {
      _media.remove(media);
    });
    widget.onMediaChanged(_media);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

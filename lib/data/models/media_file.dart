// lib/data/models/media_file.dart
// Modèle de données pour un fichier média (image ou vidéo)

import 'dart:io';

class MediaFile {
  final String id;
  final File? file;         // Fichier local (après sélection)
  final String? url;        // URL distante (média déjà uploadé)
  final File? thumbnail;    // Miniature pour les vidéos
  final bool isVideo;
  final bool isUploading;
  final double uploadProgress; // 0.0 → 1.0

  MediaFile({
    required this.id,
    this.file,
    this.url,
    this.thumbnail,
    required this.isVideo,
    this.isUploading = false,
    this.uploadProgress = 0.0,
  });

  MediaFile copyWith({
    String? id,
    File? file,
    String? url,
    File? thumbnail,
    bool? isVideo,
    bool? isUploading,
    double? uploadProgress,
  }) {
    return MediaFile(
      id: id ?? this.id,
      file: file ?? this.file,
      url: url ?? this.url,
      thumbnail: thumbnail ?? this.thumbnail,
      isVideo: isVideo ?? this.isVideo,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}
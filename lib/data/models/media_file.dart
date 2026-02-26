// lib/data/models/media_file.dart
// Modèle de données pour un fichier média (image ou vidéo)

import 'dart:io';
import 'dart:typed_data';

/// Types de médias supportés
enum MediaType {
  image,
  video,
}

/// Statuts d'upload
enum UploadStatus {
  pending,
  uploading,
  uploaded,
  error,
}

/// Modèle représentant un fichier média
class MediaFile {
  final String id;
  final MediaType type;
  final File? file;
  final Uint8List? bytes;
  final String? url;
  final String? thumbnailUrl;
  final String? fileName;
  final int? fileSize;
  final String? mimeType;
  final UploadStatus uploadStatus;
  final String? errorMessage;
  final int? width;
  final int? height;
  final int? duration; // Pour les vidéos en ms
  final String? description;
  final int order;

  MediaFile({
    required this.id,
    this.type = MediaType.image,
    this.file,
    this.bytes,
    this.url,
    this.thumbnailUrl,
    this.fileName,
    this.fileSize,
    this.mimeType,
    this.uploadStatus = UploadStatus.pending,
    this.errorMessage,
    this.width,
    this.height,
    this.duration,
    this.description,
    this.order = 0,
  });

  /// Créer une copie avec des modifications
  MediaFile copyWith({
    String? id,
    MediaType? type,
    File? file,
    Uint8List? bytes,
    String? url,
    String? thumbnailUrl,
    String? fileName,
    int? fileSize,
    String? mimeType,
    UploadStatus? uploadStatus,
    String? errorMessage,
    int? width,
    int? height,
    int? duration,
    String? description,
    int? order,
  }) {
    return MediaFile(
      id: id ?? this.id,
      type: type ?? this.type,
      file: file ?? this.file,
      bytes: bytes ?? this.bytes,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      width: width ?? this.width,
      height: height ?? this.height,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      order: order ?? this.order,
    );
  }

  /// Vérifier si le fichier est une image
  bool get isImage => type == MediaType.image;

  /// Vérifier si le fichier est une vidéo
  bool get isVideo => type == MediaType.video;

  /// Vérifier si l'upload est terminé
  bool get isUploaded => uploadStatus == UploadStatus.uploaded;

  /// Vérifier si l'upload est en cours
  bool get isUploading => uploadStatus == UploadStatus.uploading;

  /// Vérifier si l'upload a échoué
  bool get hasError => uploadStatus == UploadStatus.error;

  /// Obtenir l'URL d'aperçu (locale ou distante)
  String? get previewUrl {
    if (file != null) {
      return file!.path;
    }
    return url;
  }

  /// Formater la taille du fichier
  String get formattedFileSize {
    if (fileSize == null) return '';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'file_name': fileName,
      'file_size': fileSize,
      'mime_type': mimeType,
      'upload_status': uploadStatus.name,
      'width': width,
      'height': height,
      'duration': duration,
      'description': description,
      'order': order,
    };
  }

  /// Créer depuis JSON
  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      id: json['id'] ?? '',
      type: MediaType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MediaType.image,
      ),
      url: json['url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      fileName: json['file_name'] as String?,
      fileSize: json['file_size'] as int?,
      mimeType: json['mime_type'] as String?,
      uploadStatus: UploadStatus.values.firstWhere(
        (e) => e.name == json['upload_status'],
        orElse: () => UploadStatus.pending,
      ),
      width: json['width'] as int?,
      height: json['height'] as int?,
      duration: json['duration'] as int?,
      description: json['description'] as String?,
      order: json['order'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'MediaFile{id: $id, type: $type, fileName: $fileName, status: $uploadStatus}';
  }
}

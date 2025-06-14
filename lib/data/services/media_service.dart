import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/domain/services/i_api_service.dart';
import 'dart:io';

/// Service pour gérer les médias multiples des projets
class MediaService {
  final IApiService _apiService;

  MediaService(this._apiService);

  /// Obtenir tous les médias d'un projet
  Future<List<ProjectMedia>> getProjectMedia(String projectId) async {
    try {
      final response = await _apiService.get('/projects/$projectId/media/');

      if (response.data is List) {
        return (response.data as List)
            .map((json) => ProjectMedia.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('Erreur lors de la récupération des médias: $e');
      return [];
    }
  }

  /// Obtenir les limites de médias pour un projet
  Future<MediaLimits?> getMediaLimits(String projectId) async {
    try {
      final response =
          await _apiService.get('/projects/$projectId/media/limits/');
      return MediaLimits.fromJson(response.data);
    } catch (e) {
      debugPrint('Erreur lors de la récupération des limites: $e');
      return null;
    }
  }

  /// Uploader un nouveau média
  Future<ProjectMedia?> uploadMedia({
    required String projectId,
    required File file,
    required String mediaType,
    String? title,
    String? description,
    bool isPrimary = false,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'media_type': mediaType,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        'is_primary': isPrimary,
      });

      final response = await _apiService.post(
        '/projects/$projectId/media/',
        data: formData,
      );

      return ProjectMedia.fromJson(response.data);
    } catch (e) {
      debugPrint('Erreur lors de l\'upload du média: $e');
      return null;
    }
  }

  /// Supprimer un média
  Future<bool> deleteMedia(String projectId, String mediaId) async {
    try {
      await _apiService.delete('/projects/$projectId/media/$mediaId/');
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la suppression du média: $e');
      return false;
    }
  }

  /// Définir un média comme principal
  Future<bool> setPrimaryMedia(String projectId, String mediaId) async {
    try {
      await _apiService
          .post('/projects/$projectId/media/$mediaId/set-primary/');
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la définition du média principal: $e');
      return false;
    }
  }

  /// Réorganiser les médias
  Future<bool> reorderMedia(String projectId, List<String> mediaIds) async {
    try {
      await _apiService.post(
        '/projects/$projectId/media/reorder/',
        data: {'media_ids': mediaIds},
      );
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la réorganisation des médias: $e');
      return false;
    }
  }
}

/// Modèle pour les limites de médias
class MediaLimits {
  final bool canAdd;
  final int limit;
  final int current;
  final int remaining;
  final bool isPremium;
  final String upgradeMessage;

  MediaLimits({
    required this.canAdd,
    required this.limit,
    required this.current,
    required this.remaining,
    required this.isPremium,
    required this.upgradeMessage,
  });

  factory MediaLimits.fromJson(Map<String, dynamic> json) {
    return MediaLimits(
      canAdd: json['can_add'] ?? false,
      limit: json['limit'] ?? 1,
      current: json['current'] ?? 0,
      remaining: json['remaining'] ?? 0,
      isPremium: json['is_premium'] ?? false,
      upgradeMessage: json['upgrade_message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'can_add': canAdd,
      'limit': limit,
      'current': current,
      'remaining': remaining,
      'is_premium': isPremium,
      'upgrade_message': upgradeMessage,
    };
  }
}

import 'package:flutter/foundation.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/data/services/media_service.dart';
import 'dart:io';

/// Provider pour gérer les médias multiples des projets
class MediaProvider with ChangeNotifier {
  final MediaService _mediaService;

  MediaProvider(this._mediaService);

  // États
  bool _isLoading = false;
  String? _error;
  List<ProjectMedia> _projectMedias = [];
  MediaLimits? _currentLimits;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ProjectMedia> get projectMedias => _projectMedias;
  MediaLimits? get currentLimits => _currentLimits;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Charger tous les médias d'un projet
  Future<void> loadProjectMedias(String projectId) async {
    _setLoading(true);
    _setError(null);

    try {
      _projectMedias = await _mediaService.getProjectMedia(projectId);
    } catch (e) {
      _setError('Erreur lors du chargement des médias: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Charger les limites de médias pour un projet
  Future<void> loadMediaLimits(String projectId) async {
    try {
      _currentLimits = await _mediaService.getMediaLimits(projectId);
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des limites: $e');
    }
  }

  /// Uploader un nouveau média
  Future<bool> uploadMedia({
    required String projectId,
    required File file,
    required String mediaType,
    String? title,
    String? description,
    bool isPrimary = false,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final newMedia = await _mediaService.uploadMedia(
        projectId: projectId,
        file: file,
        mediaType: mediaType,
        title: title,
        description: description,
        isPrimary: isPrimary,
      );

      if (newMedia != null) {
        // Ajouter le nouveau média à la liste
        _projectMedias.add(newMedia);

        // Si c'est le média principal, mettre à jour les autres
        if (isPrimary) {
          for (int i = 0; i < _projectMedias.length - 1; i++) {
            if (_projectMedias[i].isPrimary) {
              // Créer une nouvelle instance avec isPrimary = false
              _projectMedias[i] = ProjectMedia(
                id: _projectMedias[i].id,
                url: _projectMedias[i].url,
                type: _projectMedias[i].type,
                title: _projectMedias[i].title,
                description: _projectMedias[i].description,
                isPrimary: false,
                order: _projectMedias[i].order,
              );
            }
          }
        }

        // Recharger les limites
        await loadMediaLimits(projectId);

        _setLoading(false);
        return true;
      } else {
        _setError('Erreur lors de l\'upload du média');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Erreur lors de l\'upload: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Supprimer un média
  Future<bool> deleteMedia(String projectId, String mediaId) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _mediaService.deleteMedia(projectId, mediaId);

      if (success) {
        _projectMedias.removeWhere((media) => media.id == mediaId);
        await loadMediaLimits(projectId);
        _setLoading(false);
        return true;
      } else {
        _setError('Erreur lors de la suppression du média');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Erreur lors de la suppression: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Définir un média comme principal
  Future<bool> setPrimaryMedia(String projectId, String mediaId) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _mediaService.setPrimaryMedia(projectId, mediaId);

      if (success) {
        // Mettre à jour la liste locale
        for (int i = 0; i < _projectMedias.length; i++) {
          _projectMedias[i] = ProjectMedia(
            id: _projectMedias[i].id,
            url: _projectMedias[i].url,
            type: _projectMedias[i].type,
            title: _projectMedias[i].title,
            description: _projectMedias[i].description,
            isPrimary: _projectMedias[i].id == mediaId,
            order: _projectMedias[i].order,
          );
        }

        _setLoading(false);
        return true;
      } else {
        _setError('Erreur lors de la définition du média principal');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Erreur lors de la définition du média principal: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Réorganiser les médias
  Future<bool> reorderMedias(String projectId, List<String> mediaIds) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _mediaService.reorderMedia(projectId, mediaIds);

      if (success) {
        // Réorganiser la liste locale selon le nouvel ordre
        final reorderedMedias = <ProjectMedia>[];
        for (final mediaId in mediaIds) {
          final media = _projectMedias.firstWhere((m) => m.id == mediaId);
          reorderedMedias.add(media);
        }

        _projectMedias = reorderedMedias;
        _setLoading(false);
        return true;
      } else {
        _setError('Erreur lors de la réorganisation des médias');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Erreur lors de la réorganisation: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Vérifier si on peut ajouter plus de médias
  bool canAddMedia() {
    return _currentLimits?.canAdd ?? false;
  }

  /// Obtenir le message d'upgrade si nécessaire
  String? get upgradeMessage {
    if (_currentLimits?.canAdd == false) {
      return _currentLimits?.upgradeMessage;
    }
    return null;
  }

  /// Nettoyer l'état
  void clear() {
    _projectMedias.clear();
    _currentLimits = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}

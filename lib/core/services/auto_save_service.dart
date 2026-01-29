import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoSaveService {
  static const String _keyPrefix = 'auto_save_';
  static const Duration _defaultInterval = Duration(minutes: 2);

  Timer? _timer;
  String? _currentKey;
  Map<String, dynamic>? _lastSavedData;

  /// Démarre la sauvegarde automatique pour un formulaire
  void startAutoSave({
    required String formKey,
    required Map<String, dynamic> Function() getFormData,
    Duration interval = _defaultInterval,
    VoidCallback? onSaved,
  }) {
    stopAutoSave(); // Arrêter toute sauvegarde précédente

    _currentKey = _keyPrefix + formKey;

    _timer = Timer.periodic(interval, (timer) async {
      try {
        final currentData = getFormData();

        // Ne sauvegarder que si les données ont changé
        if (!_mapsEqual(currentData, _lastSavedData)) {
          await _saveToStorage(_currentKey!, currentData);
          _lastSavedData = Map<String, dynamic>.from(currentData);

          debugPrint(
              '[AutoSave] Données sauvegardées automatiquement pour $formKey');
          onSaved?.call();
        }
      } catch (e) {
        debugPrint('[AutoSave] Erreur lors de la sauvegarde automatique: $e');
      }
    });

    debugPrint('[AutoSave] Sauvegarde automatique démarrée pour $formKey');
  }

  /// Arrête la sauvegarde automatique
  void stopAutoSave() {
    _timer?.cancel();
    _timer = null;
    _currentKey = null;
    _lastSavedData = null;
    debugPrint('[AutoSave] Sauvegarde automatique arrêtée');
  }

  /// Sauvegarde manuelle immédiate
  Future<bool> saveNow({
    required String formKey,
    required Map<String, dynamic> data,
  }) async {
    try {
      final key = _keyPrefix + formKey;
      await _saveToStorage(key, data);
      _lastSavedData = Map<String, dynamic>.from(data);
      debugPrint('[AutoSave] Sauvegarde manuelle effectuée pour $formKey');
      return true;
    } catch (e) {
      debugPrint('[AutoSave] Erreur lors de la sauvegarde manuelle: $e');
      return false;
    }
  }

  /// Récupère les données sauvegardées
  Future<Map<String, dynamic>?> getSavedData(String formKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keyPrefix + formKey;
      final jsonString = prefs.getString(key);

      if (jsonString != null) {
        final data = json.decode(jsonString) as Map<String, dynamic>;
        debugPrint('[AutoSave] Données récupérées pour $formKey');
        return data;
      }
    } catch (e) {
      debugPrint('[AutoSave] Erreur lors de la récupération des données: $e');
    }

    return null;
  }

  /// Vérifie s'il y a des données sauvegardées
  Future<bool> hasSavedData(String formKey) async {
    final data = await getSavedData(formKey);
    return data != null && data.isNotEmpty;
  }

  /// Supprime les données sauvegardées
  Future<bool> clearSavedData(String formKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keyPrefix + formKey;
      await prefs.remove(key);
      debugPrint('[AutoSave] Données supprimées pour $formKey');
      return true;
    } catch (e) {
      debugPrint('[AutoSave] Erreur lors de la suppression des données: $e');
      return false;
    }
  }

  /// Récupère toutes les sauvegardes automatiques
  Future<Map<String, Map<String, dynamic>>> getAllSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
      final result = <String, Map<String, dynamic>>{};

      for (final key in keys) {
        final jsonString = prefs.getString(key);
        if (jsonString != null) {
          try {
            final data = json.decode(jsonString) as Map<String, dynamic>;
            final formKey = key.substring(_keyPrefix.length);
            result[formKey] = data;
          } catch (e) {
            debugPrint('[AutoSave] Erreur parsing données pour $key: $e');
          }
        }
      }

      return result;
    } catch (e) {
      debugPrint(
          '[AutoSave] Erreur lors de la récupération de toutes les données: $e');
      return {};
    }
  }

  /// Nettoie les anciennes sauvegardes (plus de X jours)
  Future<void> cleanupOldSaves({int maxDays = 7}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
      final cutoffDate = DateTime.now().subtract(Duration(days: maxDays));

      for (final key in keys) {
        final jsonString = prefs.getString(key);
        if (jsonString != null) {
          try {
            final data = json.decode(jsonString) as Map<String, dynamic>;
            final savedAt = data['_savedAt'] as String?;

            if (savedAt != null) {
              final saveDate = DateTime.parse(savedAt);
              if (saveDate.isBefore(cutoffDate)) {
                await prefs.remove(key);
                debugPrint('[AutoSave] Ancienne sauvegarde supprimée: $key');
              }
            }
          } catch (e) {
            // Si on ne peut pas parser, supprimer par sécurité
            await prefs.remove(key);
            debugPrint('[AutoSave] Sauvegarde corrompue supprimée: $key');
          }
        }
      }
    } catch (e) {
      debugPrint('[AutoSave] Erreur lors du nettoyage: $e');
    }
  }

  /// Sauvegarde dans le stockage local
  Future<void> _saveToStorage(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    // Ajouter un timestamp
    final dataWithTimestamp = Map<String, dynamic>.from(data);
    dataWithTimestamp['_savedAt'] = DateTime.now().toIso8601String();

    final jsonString = json.encode(dataWithTimestamp);
    await prefs.setString(key, jsonString);
  }

  /// Compare deux maps pour détecter les changements
  bool _mapsEqual(Map<String, dynamic>? map1, Map<String, dynamic>? map2) {
    if (map1 == null && map2 == null) return true;
    if (map1 == null || map2 == null) return false;
    if (map1.length != map2.length) return false;

    for (final key in map1.keys) {
      if (!map2.containsKey(key)) return false;

      final value1 = map1[key];
      final value2 = map2[key];

      // Comparaison spéciale pour les listes
      if (value1 is List && value2 is List) {
        if (value1.length != value2.length) return false;
        for (int i = 0; i < value1.length; i++) {
          if (value1[i] != value2[i]) return false;
        }
      } else if (value1 != value2) {
        return false;
      }
    }

    return true;
  }

  /// Dispose des ressources
  void dispose() {
    stopAutoSave();
  }
}

/// Extension pour faciliter l'utilisation avec les TextEditingController
extension AutoSaveTextController on Map<String, dynamic> {
  /// Convertit les contrôleurs de texte en données sérialisables
  static Map<String, dynamic> fromControllers({
    required Map<String, TextEditingController> controllers,
    Map<String, dynamic>? additionalData,
  }) {
    final data = <String, dynamic>{};

    // Ajouter les valeurs des contrôleurs
    controllers.forEach((key, controller) {
      data[key] = controller.text;
    });

    // Ajouter les données supplémentaires
    if (additionalData != null) {
      data.addAll(additionalData);
    }

    return data;
  }

  /// Restaure les données dans les contrôleurs
  void restoreToControllers(Map<String, TextEditingController> controllers) {
    controllers.forEach((key, controller) {
      final value = this[key];
      if (value is String) {
        controller.text = value;
      }
    });
  }
}

/// Mixin pour faciliter l'intégration dans les widgets
mixin AutoSaveMixin<T extends StatefulWidget> on State<T> {
  final AutoSaveService _autoSaveService = AutoSaveService();

  /// Démarre la sauvegarde automatique
  void startAutoSave({
    required String formKey,
    required Map<String, dynamic> Function() getFormData,
    Duration interval = const Duration(minutes: 2),
    VoidCallback? onSaved,
  }) {
    _autoSaveService.startAutoSave(
      formKey: formKey,
      getFormData: getFormData,
      interval: interval,
      onSaved: onSaved,
    );
  }

  /// Arrête la sauvegarde automatique
  void stopAutoSave() {
    _autoSaveService.stopAutoSave();
  }

  /// Sauvegarde manuelle
  Future<bool> saveNow(String formKey, Map<String, dynamic> data) {
    return _autoSaveService.saveNow(formKey: formKey, data: data);
  }

  /// Récupère les données sauvegardées
  Future<Map<String, dynamic>?> getSavedData(String formKey) {
    return _autoSaveService.getSavedData(formKey);
  }

  /// Vérifie s'il y a des données sauvegardées
  Future<bool> hasSavedData(String formKey) {
    return _autoSaveService.hasSavedData(formKey);
  }

  /// Supprime les données sauvegardées
  Future<bool> clearSavedData(String formKey) {
    return _autoSaveService.clearSavedData(formKey);
  }

  @override
  void dispose() {
    _autoSaveService.dispose();
    super.dispose();
  }
}

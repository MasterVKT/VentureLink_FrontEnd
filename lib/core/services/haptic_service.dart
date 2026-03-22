// lib/core/services/haptic_service.dart

import 'package:flutter/services.dart';

/// Service centralisé pour le feedback haptique
/// Remplace les appels directs à HapticFeedback partout dans l'app
class HapticService {
  /// Clic léger — boutons, toggles, favoris
  static Future<void> lightTap() async {
    await HapticFeedback.lightImpact();
  }

  /// Clic moyen — actions importantes (investir, confirmer)
  static Future<void> mediumTap() async {
    await HapticFeedback.mediumImpact();
  }

  /// Clic fort — actions critiques (suppression, erreur)
  static Future<void> heavyTap() async {
    await HapticFeedback.heavyImpact();
  }

  /// Sélection — navigation, scroll sur items
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Succès — double vibration légère
  static Future<void> success() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Erreur — vibration forte
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
  }
}

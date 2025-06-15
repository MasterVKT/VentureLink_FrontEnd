import 'package:flutter/material.dart';

class ValidationUtils {
  /// Valide une fourchette de financement
  /// Formats acceptés: "50K-100K €", "50000-100000 €", "50K - 100K €", etc.
  static String? validateFundingRange(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer une fourchette de financement';
    }

    // Nettoyer la chaîne (supprimer espaces supplémentaires)
    final cleanValue = value.trim().replaceAll(RegExp(r'\s+'), ' ');

    // Regex pour formats acceptés
    final regex = RegExp(
      r'^\d+(?:[KMkm])?(?:\s*-\s*|\s+à\s+|\s+to\s+)\d+(?:[KMkm])?(?:\s*[€$£]?)?$',
      caseSensitive: false,
    );

    if (!regex.hasMatch(cleanValue)) {
      return 'Format invalide. Exemples: "50K-100K €", "50000-100000 €"';
    }

    // Extraire les montants pour validation logique
    try {
      final amounts = _extractAmounts(cleanValue);
      if (amounts.length == 2) {
        final min = amounts[0];
        final max = amounts[1];

        if (min >= max) {
          return 'Le montant minimum doit être inférieur au maximum';
        }

        if (min <= 0) {
          return 'Le montant minimum doit être positif';
        }

        // Vérifier des limites raisonnables
        if (max > 10000000) {
          // 10M max
          return 'Le montant maximum semble trop élevé';
        }
      }
    } catch (e) {
      return 'Format de montant invalide';
    }

    return null;
  }

  /// Extrait les montants numériques d'une fourchette
  static List<double> _extractAmounts(String value) {
    // Remplacer les séparateurs par un délimiteur standard
    final normalized = value
        .replaceAll(
            RegExp(r'\s*-\s*|\s+à\s+|\s+to\s+', caseSensitive: false), '|')
        .replaceAll(RegExp(r'[€$£]'), '')
        .trim();

    final parts = normalized.split('|');
    if (parts.length != 2) throw FormatException('Format invalide');

    final amounts = <double>[];
    for (final part in parts) {
      final cleanPart = part.trim();
      double amount;

      if (cleanPart.toLowerCase().endsWith('k')) {
        amount =
            double.parse(cleanPart.substring(0, cleanPart.length - 1)) * 1000;
      } else if (cleanPart.toLowerCase().endsWith('m')) {
        amount = double.parse(cleanPart.substring(0, cleanPart.length - 1)) *
            1000000;
      } else {
        amount = double.parse(cleanPart);
      }

      amounts.add(amount);
    }

    return amounts;
  }

  /// Valide un titre de projet
  static String? validateProjectTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un titre pour votre projet';
    }

    if (value.length < 5) {
      return 'Le titre doit contenir au moins 5 caractères';
    }

    if (value.length > 100) {
      return 'Le titre ne doit pas dépasser 100 caractères';
    }

    // Vérifier qu'il n'y a pas que des espaces
    if (value.trim().isEmpty) {
      return 'Le titre ne peut pas être vide';
    }

    return null;
  }

  /// Valide une description courte
  static String? validateShortDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer une description courte';
    }

    if (value.length < 10) {
      return 'La description courte doit contenir au moins 10 caractères';
    }

    if (value.length > 200) {
      return 'La description courte ne doit pas dépasser 200 caractères';
    }

    if (value.trim().isEmpty) {
      return 'La description ne peut pas être vide';
    }

    return null;
  }

  /// Valide une description détaillée
  static String? validateFullDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer une description détaillée';
    }

    if (value.length < 50) {
      return 'La description détaillée doit contenir au moins 50 caractères';
    }

    if (value.length > 5000) {
      return 'La description détaillée ne doit pas dépasser 5000 caractères';
    }

    if (value.trim().isEmpty) {
      return 'La description ne peut pas être vide';
    }

    return null;
  }

  /// Valide une liste de tags
  static String? validateTags(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Les tags sont optionnels
    }

    final tags = value
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    if (tags.length > 10) {
      return 'Maximum 10 tags autorisés';
    }

    for (final tag in tags) {
      if (tag.length < 2) {
        return 'Chaque tag doit contenir au moins 2 caractères';
      }
      if (tag.length > 30) {
        return 'Chaque tag ne doit pas dépasser 30 caractères';
      }
    }

    return null;
  }

  /// Valide une URL vidéo
  static String? validateVideoUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL vidéo optionnelle
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?(youtube\.com\/watch\?v=|youtu\.be\/|vimeo\.com\/|dailymotion\.com\/video\/)',
      caseSensitive: false,
    );

    if (!urlRegex.hasMatch(value)) {
      return 'URL vidéo invalide. Supporté: YouTube, Vimeo, Dailymotion';
    }

    return null;
  }

  /// Valide un email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer une adresse email';
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(value)) {
      return 'Adresse email invalide';
    }

    return null;
  }

  /// Valide un mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    }

    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins une majuscule';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins une minuscule';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }

    return null;
  }

  /// Valide un numéro de téléphone
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Téléphone optionnel
    }

    // Supprimer tous les espaces et caractères spéciaux sauf + et chiffres
    final cleanValue = value.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleanValue.length < 8) {
      return 'Numéro de téléphone trop court';
    }

    if (cleanValue.length > 15) {
      return 'Numéro de téléphone trop long';
    }

    // Vérifier le format international ou national
    final phoneRegex = RegExp(r'^\+?[1-9]\d{7,14}$');

    if (!phoneRegex.hasMatch(cleanValue)) {
      return 'Format de téléphone invalide';
    }

    return null;
  }

  /// Valide un montant financier
  static String? validateAmount(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un montant';
    }

    final amount = double.tryParse(value.replaceAll(',', '.'));

    if (amount == null) {
      return 'Montant invalide';
    }

    if (amount <= 0) {
      return 'Le montant doit être positif';
    }

    if (min != null && amount < min) {
      return 'Le montant minimum est ${min.toStringAsFixed(2)} €';
    }

    if (max != null && amount > max) {
      return 'Le montant maximum est ${max.toStringAsFixed(2)} €';
    }

    return null;
  }

  /// Valide que des éléments sont sélectionnés dans une liste
  static String? validateSelection(List<dynamic>? selectedItems,
      {int? minItems, int? maxItems}) {
    if (selectedItems == null || selectedItems.isEmpty) {
      if (minItems != null && minItems > 0) {
        return 'Veuillez sélectionner au moins ${minItems} élément${minItems > 1 ? 's' : ''}';
      }
      return null;
    }

    if (minItems != null && selectedItems.length < minItems) {
      return 'Veuillez sélectionner au moins ${minItems} élément${minItems > 1 ? 's' : ''}';
    }

    if (maxItems != null && selectedItems.length > maxItems) {
      return 'Vous ne pouvez sélectionner que ${maxItems} élément${maxItems > 1 ? 's' : ''} maximum';
    }

    return null;
  }
}

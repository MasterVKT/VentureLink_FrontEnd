import '../../core/config/app_config.dart';

/// Classe utilitaire pour la validation des entrées utilisateur
class Validators {
  /// Valide une adresse email
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final regex = RegExp(AppConfig.emailRegex);
    return regex.hasMatch(email);
  }

  /// Valide un mot de passe selon les critères de sécurité
  static bool isValidPassword(String password) {
    if (password.isEmpty) return false;
    if (password.length < AppConfig.minPasswordLength) return false;
    if (password.length > AppConfig.maxPasswordLength) return false;
    final regex = RegExp(AppConfig.passwordRegex);
    return regex.hasMatch(password);
  }

  /// Vérifie si une chaîne est vide ou ne contient que des espaces
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Vérifie si une valeur est un nombre entier positif
  static bool isPositiveInteger(String value) {
    if (value.isEmpty) return false;
    return int.tryParse(value) != null && int.parse(value) > 0;
  }

  /// Vérifie si une valeur est un nombre décimal positif
  static bool isPositiveDouble(String value) {
    if (value.isEmpty) return false;
    return double.tryParse(value) != null && double.parse(value) > 0;
  }

  /// Valide un numéro de téléphone (format international)
  static bool isValidPhoneNumber(String phone) {
    if (phone.isEmpty) return false;
    // Format international +XX XXXXXXXXXX
    final regex = RegExp(r'^\+?[0-9]{1,4}[-\s]?[0-9]{6,14}$');
    return regex.hasMatch(phone);
  }

  /// Vérifie si une URL est valide
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;
    final regex = RegExp(
      r'^(https?:\/\/)?([\w\-])+\.{1}([a-zA-Z]{2,63})([\/\w-]*)*\/?\??([^#\n\r]*)?#?([^\n\r]*)$',
    );
    return regex.hasMatch(url);
  }

  /// Vérifie si une date est valide et respecte les contraintes
  static bool isValidDate(String date, {DateTime? minDate, DateTime? maxDate}) {
    if (date.isEmpty) return false;
    try {
      final dateTime = DateTime.parse(date);
      if (minDate != null && dateTime.isBefore(minDate)) return false;
      if (maxDate != null && dateTime.isAfter(maxDate)) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Vérifie la longueur d'une chaîne de caractères
  static bool hasValidLength(String value, int min, int max) {
    return value.length >= min && value.length <= max;
  }

  /// Vérifie si deux valeurs sont identiques (ex: confirmation de mot de passe)
  static bool areEqual(String value1, String value2) {
    return value1 == value2;
  }

  /// Valide un code d'accès numérique (PIN)
  static bool isValidPin(String pin, int length) {
    if (pin.isEmpty) return false;
    if (pin.length != length) return false;
    return RegExp(r'^[0-9]+$').hasMatch(pin);
  }

  /// Vérifie si une valeur est un nombre entre min et max
  static bool isInRange(String value, num min, num max) {
    if (value.isEmpty) return false;
    final number = num.tryParse(value);
    if (number == null) return false;
    return number >= min && number <= max;
  }
}

/// Validation de numéros de téléphone pour My-CoolPay
class PhoneNumberValidation {
  final bool isValid;
  final String? message;
  final String? formatted;

  const PhoneNumberValidation({
    required this.isValid,
    this.message,
    this.formatted,
  });
}

/// Validateur de numéros de téléphone
class PhoneValidator {
  /// Valide et formate un numéro de téléphone selon les exigences My-CoolPay
  static PhoneNumberValidation validatePhoneNumber(String phone) {
    // Nettoyer le numéro (supprimer espaces, tirets, parenthèses)
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]+'), '');

    if (cleaned.isEmpty) {
      return const PhoneNumberValidation(
        isValid: false,
        message: 'Le numéro de téléphone est requis',
      );
    }

    // Vérifier la longueur minimum (au moins 9 chiffres)
    final digitsOnly = cleaned.replaceAll(RegExp(r'\+'), '');
    if (digitsOnly.length < 9) {
      return const PhoneNumberValidation(
        isValid: false,
        message: 'Le numéro doit contenir au moins 9 chiffres',
      );
    }

    // Vérifier le format avec regex
    final phoneRegex = RegExp(r'^\+?[1-9]\d{8,14}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return const PhoneNumberValidation(
        isValid: false,
        message: 'Format de numéro invalide',
      );
    }

    // Formater le numéro
    String formatted = cleaned;
    if (!formatted.startsWith('+')) {
      // Ajouter le préfixe Cameroun par défaut
      formatted = '+237$formatted';
    }

    return PhoneNumberValidation(
      isValid: true,
      formatted: formatted,
    );
  }

  /// Formate un numéro de téléphone pour l'affichage
  static String formatForDisplay(String phone) {
    final validation = validatePhoneNumber(phone);
    return validation.formatted ?? phone;
  }

  /// Vérifie si un numéro est valide rapidement
  static bool isValid(String phone) {
    return validatePhoneNumber(phone).isValid;
  }
}

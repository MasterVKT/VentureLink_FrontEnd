/// Classe stub pour imiter l'API Platform sur le web
class Platform {
  /// Toujours faux sur le web
  static bool get isAndroid => false;

  /// Toujours faux sur le web
  static bool get isIOS => false;

  /// Toujours 'web' sur le web
  static String get operatingSystem => 'web';
}

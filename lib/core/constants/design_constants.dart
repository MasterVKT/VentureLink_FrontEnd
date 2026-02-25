import 'package:flutter/material.dart';

class DesignConstants {
  // Espacements
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Rayons de bordure
  static const double borderRadiusS = 4.0;
  static const double borderRadiusM = 8.0;
  static const double borderRadiusL = 12.0;
  static const double borderRadiusXL = 16.0;

  // Tailles d'icônes
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;

  // Tailles de texte
  static const double fontSizeXS = 12.0;
  static const double fontSizeS = 14.0;
  static const double fontSizeM = 16.0;
  static const double fontSizeL = 18.0;
  static const double fontSizeXL = 20.0;
  static const double fontSizeXXL = 24.0;

  // Durées d'animation
  static const Duration animationDurationS = Duration(milliseconds: 150);
  static const Duration animationDurationM = Duration(milliseconds: 300);
  static const Duration animationDurationL = Duration(milliseconds: 500);

  // Ombres
  static List<BoxShadow> shadowS = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowM = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowL = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // Opacités
  static const double opacityS = 0.3;
  static const double opacityM = 0.5;
  static const double opacityL = 0.7;

  // Z-index
  static const int zIndexS = 1;
  static const int zIndexM = 2;
  static const int zIndexL = 3;
  static const int zIndexXL = 4;
}

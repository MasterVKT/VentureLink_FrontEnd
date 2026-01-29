import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:io';

class LogoGenerator {
  static Future<void> generateLogo() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Fond bleu
    final paint = Paint()
      ..color = const Color(0xFF1877F2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(100, 100), 90, paint);

    // V stylisé
    final vPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(60, 40)
      ..lineTo(100, 160)
      ..lineTo(140, 40);
    canvas.drawPath(path, vPaint);

    // Point
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(100, 160), 8, dotPaint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(200, 200);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    // Créer le dossier assets/images s'il n'existe pas
    final assetsDir = Directory('assets/images');
    if (!await assetsDir.exists()) {
      await assetsDir.create(recursive: true);
    }

    // Sauvegarder le logo
    final file = File('assets/images/logo.png');
    await file.writeAsBytes(buffer);
  }
}

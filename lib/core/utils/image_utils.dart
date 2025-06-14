import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageUtils {
  static const int maxImageSize = 2 * 1024 * 1024; // 2MB
  static const int imageQuality = 85;
  static const int maxWidth = 1024;
  static const int maxHeight = 1024;

  /// Sélectionner une image depuis la galerie
  static Future<File?> pickImageFromGallery() async {
    try {
      // Vérifier les permissions
      final permission = await Permission.photos.request();
      if (!permission.isGranted) {
        throw Exception('Permission d\'accès à la galerie refusée');
      }

      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (image == null) return null;

      final file = File(image.path);
      return await _processImage(file);
    } catch (e) {
      throw Exception('Erreur lors de la sélection de l\'image: $e');
    }
  }

  /// Prendre une photo avec la caméra
  static Future<File?> takePhotoWithCamera() async {
    try {
      // Vérifier les permissions
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        throw Exception('Permission d\'accès à la caméra refusée');
      }

      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (image == null) return null;

      final file = File(image.path);
      return await _processImage(file);
    } catch (e) {
      throw Exception('Erreur lors de la capture de l\'image: $e');
    }
  }

  /// Traiter et compresser l'image
  static Future<File> _processImage(File imageFile) async {
    try {
      // Vérifier la taille du fichier
      final fileSize = await imageFile.length();

      if (fileSize <= maxImageSize) {
        // Si la taille est acceptable, retourner le fichier tel quel
        return imageFile;
      }

      // Sinon, compresser l'image
      return await _compressImage(imageFile);
    } catch (e) {
      throw Exception('Erreur lors du traitement de l\'image: $e');
    }
  }

  /// Compresser une image
  static Future<File> _compressImage(File imageFile) async {
    try {
      // Obtenir le répertoire temporaire
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Compresser l'image
      final Uint8List? compressedBytes =
          await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 512,
        minHeight: 512,
        quality: imageQuality,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes == null) {
        throw Exception('Échec de la compression de l\'image');
      }

      // Sauvegarder l'image compressée
      final compressedFile = File(targetPath);
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      throw Exception('Erreur lors de la compression de l\'image: $e');
    }
  }

  /// Valider un fichier image
  static bool isValidImageFile(File file) {
    final extension = path.extension(file.path).toLowerCase();
    const allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
    return allowedExtensions.contains(extension);
  }

  /// Obtenir la taille d'un fichier en MB
  static Future<double> getFileSizeInMB(File file) async {
    final size = await file.length();
    return size / (1024 * 1024);
  }

  /// Afficher un bottom sheet pour sélectionner la source de l'image
  static Future<File?> showImageSourceBottomSheet(BuildContext context) async {
    return await showModalBottomSheet<File?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Poignée
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Titre
            Text(
              'Choisir une photo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),

            // Options
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.photo_camera,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: const Text('Prendre une photo'),
              subtitle: const Text('Utiliser l\'appareil photo'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final file = await takePhotoWithCamera();
                  if (context.mounted) {
                    Navigator.pop(context, file);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),

            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.photo_library,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: const Text('Choisir dans la galerie'),
              subtitle: const Text('Sélectionner une photo existante'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final file = await pickImageFromGallery();
                  if (context.mounted) {
                    Navigator.pop(context, file);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  /// Nettoyer les fichiers temporaires d'images
  static Future<void> cleanupTemporaryImages() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();

      for (final file in files) {
        if (file is File && file.path.contains('compressed_')) {
          await file.delete();
        }
      }
    } catch (e) {
      // Ignorer les erreurs de nettoyage
    }
  }
}

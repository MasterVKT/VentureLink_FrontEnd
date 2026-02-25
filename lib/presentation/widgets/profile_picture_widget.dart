import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:venturelink/data/providers/profile_provider.dart';
import 'package:venturelink/data/providers/auth_provider.dart';
import 'package:venturelink/core/utils/image_utils.dart';
import 'dart:io';

class ProfilePictureWidget extends StatelessWidget {
  final double radius;
  final bool showEditButton;
  final VoidCallback? onTap;

  const ProfilePictureWidget({
    super.key,
    this.radius = 50,
    this.showEditButton = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ProfileProvider>(
      builder: (context, authProvider, profileProvider, child) {
        final user = profileProvider.user ?? authProvider.currentUser;

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: onTap,
                child: CircleAvatar(
                  radius: radius,
                  backgroundImage: user?.profile?.profilePicture != null
                      ? CachedNetworkImageProvider(
                          user!.profile!.profilePicture!)
                      : null,
                  child: user?.profile?.profilePicture == null
                      ? Text(
                          user?.firstName[0].toUpperCase() ?? '?',
                          style: TextStyle(
                            fontSize: radius * 0.6,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            if (showEditButton)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: profileProvider.isUploadingProfilePicture
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: radius * 0.3,
                            height: radius * 0.3,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : IconButton(
                          icon:
                              const Icon(Icons.camera_alt, color: Colors.white),
                          onPressed: () => _showImagePicker(context),
                          iconSize: radius * 0.3,
                          padding: EdgeInsets.all(radius * 0.15),
                        ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showImagePicker(BuildContext context) async {
    final profileProvider = context.read<ProfileProvider>();

    if (profileProvider.isUploadingProfilePicture) return;

    showModalBottomSheet(
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

            Text(
              'Photo de profil',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),

            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.photo_camera,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: const Text('Prendre une photo'),
              subtitle: const Text('Utiliser l\'appareil photo'),
              onTap: () {
                Navigator.pop(context);
                _takePicture(context);
              },
            ),

            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.photo_library,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: const Text('Choisir dans la galerie'),
              subtitle: const Text('Sélectionner une photo existante'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery(context);
              },
            ),

            if (context
                    .read<AuthProvider>()
                    .currentUser
                    ?.profile
                    ?.profilePicture !=
                null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),
                title: const Text('Supprimer la photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePicture(context);
                },
              ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _takePicture(BuildContext context) async {
    try {
      final file = await ImageUtils.takePhotoWithCamera();
      if (file != null && context.mounted) {
        await _uploadProfilePicture(context, file);
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
  }

  void _pickFromGallery(BuildContext context) async {
    try {
      final file = await ImageUtils.pickImageFromGallery();
      if (file != null && context.mounted) {
        await _uploadProfilePicture(context, file);
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
  }

  Future<void> _uploadProfilePicture(
      BuildContext context, File imageFile) async {
    final profileProvider = context.read<ProfileProvider>();
    final authProvider = context.read<AuthProvider>();

    final success = await profileProvider.uploadProfilePicture(imageFile);

    if (success && context.mounted) {
      // Mettre à jour l'AuthProvider avec les nouvelles données
      authProvider.updateUser(profileProvider.user!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil mise à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(profileProvider.error ?? 'Erreur lors de l\'upload'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeProfilePicture(BuildContext context) async {
    final profileProvider = context.read<ProfileProvider>();
    final authProvider = context.read<AuthProvider>();

    final success = await profileProvider.removeProfilePicture();

    if (success && context.mounted) {
      // Mettre à jour l'AuthProvider avec les nouvelles données
      authProvider.updateUser(profileProvider.user!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil supprimée'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(profileProvider.error ?? 'Erreur lors de la suppression'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/data/providers/auth_provider.dart';
import 'package:venturelink/data/providers/profile_provider.dart';
import 'package:venturelink/core/config/app_config.dart';
import 'package:venturelink/core/utils/image_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';

@RoutePage()
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _titleController;
  late TextEditingController _bioShortController;
  late TextEditingController _bioLongController;
  late TextEditingController _websiteController;
  late TextEditingController _linkedinController;
  late TextEditingController _twitterController;
  late TextEditingController _locationController;

  String? _selectedUserType;
  String? _selectedIndustry;
  bool _isLoading = false;

  final List<String> _userTypes = [
    'ENTREPRENEUR',
    'INVESTOR',
    'MENTOR',
    'BOTH',
  ];

  final List<String> _industries = [
    'TECH',
    'FINANCE',
    'HEALTH',
    'EDUCATION',
    'ENERGY',
    'AGRICULTURE',
    'TRANSPORT',
    'REAL_ESTATE',
    'RETAIL',
    'MEDIA',
    'OTHER',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;

    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _titleController = TextEditingController(text: user?.profile?.title ?? '');
    _bioShortController =
        TextEditingController(text: user?.profile?.bioShort ?? '');
    _bioLongController =
        TextEditingController(); // Pas disponible dans le modèle actuel
    _websiteController =
        TextEditingController(text: user?.profile?.website ?? '');
    _linkedinController =
        TextEditingController(text: user?.profile?.socialLinkedin ?? '');
    _twitterController =
        TextEditingController(text: user?.profile?.socialTwitter ?? '');
    _locationController =
        TextEditingController(text: user?.location ?? ''); // Champ du UserModel

    _selectedUserType =
        _userTypes.contains(user?.userType) ? user?.userType : null;
    _selectedIndustry = null; // Pas disponible dans le modèle actuel
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _titleController.dispose();
    _bioShortController.dispose();
    _bioLongController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enregistrer'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo de profil
              Center(
                child: _buildProfilePictureSection(),
              ),

              const SizedBox(height: 32),

              // Informations personnelles
              _buildSectionTitle('Informations personnelles'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _firstNameController,
                      label: 'Prénom',
                      validator: (value) =>
                          value?.isEmpty == true ? 'Prénom requis' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _lastNameController,
                      label: 'Nom',
                      validator: (value) =>
                          value?.isEmpty == true ? 'Nom requis' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Email requis';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value!)) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _phoneController,
                label: 'Téléphone',
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 24),

              // Type d'utilisateur et industrie
              _buildSectionTitle('Profil professionnel'),
              const SizedBox(height: 16),

              _buildDropdownField(
                value: _selectedUserType,
                label: 'Type d\'utilisateur',
                items: _userTypes,
                onChanged: (value) => setState(() => _selectedUserType = value),
                itemBuilder: (value) => _getUserTypeLabel(value),
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _titleController,
                label: 'Titre/Poste',
                hint:
                    'Ex: Founder & CEO, Venture Capitalist, Serial Entrepreneur',
              ),

              const SizedBox(height: 16),

              _buildDropdownField(
                value: _selectedIndustry,
                label: 'Secteur d\'activité',
                items: _industries,
                onChanged: (value) => setState(() => _selectedIndustry = value),
                itemBuilder: (value) => _getIndustryLabel(value),
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _locationController,
                label: 'Localisation',
                hint: 'Ex: Paris, France',
              ),

              const SizedBox(height: 24),

              // Biographie
              _buildSectionTitle('À propos'),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _bioShortController,
                label: 'Description courte',
                hint: 'Une phrase qui vous décrit (120 caractères max)',
                maxLength: 120,
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _bioLongController,
                label: 'Biographie détaillée',
                hint:
                    'Décrivez votre expérience, vos objectifs et votre vision',
                maxLines: 5,
                maxLength: 1000,
              ),

              const SizedBox(height: 24),

              // Réseaux sociaux
              _buildSectionTitle('Réseaux sociaux'),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _websiteController,
                label: 'Site web',
                hint: 'https://www.example.com',
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _linkedinController,
                label: 'LinkedIn',
                hint: 'https://linkedin.com/in/username',
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _twitterController,
                label: 'Twitter',
                hint: 'https://twitter.com/username',
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final user =
            profileProvider.user ?? context.read<AuthProvider>().currentUser;

        return Column(
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: user?.profile?.profilePicture != null
                        ? CachedNetworkImageProvider(
                            user!.profile!.profilePicture!)
                        : null,
                    child: user?.profile?.profilePicture == null
                        ? Text(
                            user?.firstName[0].toUpperCase() ?? '?',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 3,
                      ),
                    ),
                    child: profileProvider.isUploadingProfilePicture
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.camera_alt,
                                color: Colors.white),
                            onPressed: _changeProfilePicture,
                            iconSize: 20,
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: profileProvider.isUploadingProfilePicture
                  ? null
                  : _changeProfilePicture,
              icon: profileProvider.isUploadingProfilePicture
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.edit),
              label: Text(profileProvider.isUploadingProfilePicture
                  ? 'Upload en cours...'
                  : 'Changer la photo'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLines = 1,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        counterText: maxLength != null ? null : '',
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String Function(String) itemBuilder,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(itemBuilder(item)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  String _getUserTypeLabel(String userType) {
    switch (userType) {
      case 'ENTREPRENEUR':
        return 'Entrepreneur';
      case 'INVESTOR':
        return 'Investisseur';
      case 'MENTOR':
        return 'Mentor';
      case 'BOTH':
        return 'Entrepreneur & Investisseur';
      default:
        return userType;
    }
  }

  String _getIndustryLabel(String industry) {
    switch (industry) {
      case 'TECH':
        return 'Technologie';
      case 'FINANCE':
        return 'Finance';
      case 'HEALTH':
        return 'Santé';
      case 'EDUCATION':
        return 'Éducation';
      case 'ENERGY':
        return 'Énergie';
      case 'AGRICULTURE':
        return 'Agriculture';
      case 'TRANSPORT':
        return 'Transport';
      case 'REAL_ESTATE':
        return 'Immobilier';
      case 'RETAIL':
        return 'Commerce';
      case 'MEDIA':
        return 'Médias';
      case 'OTHER':
        return 'Autre';
      default:
        return industry;
    }
  }

  void _changeProfilePicture() async {
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
              leading: const Icon(Icons.photo_camera),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _takePicture();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir dans la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            if (profileProvider.user?.profile?.profilePicture != null ||
                context
                        .read<AuthProvider>()
                        .currentUser
                        ?.profile
                        ?.profilePicture !=
                    null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Supprimer la photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePicture();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _takePicture() async {
    try {
      final file = await ImageUtils.takePhotoWithCamera();
      if (file != null && mounted) {
        await _uploadProfilePicture(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _pickFromGallery() async {
    try {
      final file = await ImageUtils.pickImageFromGallery();
      if (file != null && mounted) {
        await _uploadProfilePicture(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadProfilePicture(File imageFile) async {
    final profileProvider = context.read<ProfileProvider>();
    final authProvider = context.read<AuthProvider>();

    final success = await profileProvider.uploadProfilePicture(imageFile);

    if (success && mounted) {
      // Mettre à jour l'AuthProvider avec les nouvelles données
      authProvider.updateUser(profileProvider.user!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil mise à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(profileProvider.error ?? 'Erreur lors de l\'upload'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeProfilePicture() async {
    final profileProvider = context.read<ProfileProvider>();
    final authProvider = context.read<AuthProvider>();

    final success = await profileProvider.removeProfilePicture();

    if (success && mounted) {
      // Mettre à jour l'AuthProvider avec les nouvelles données
      authProvider.updateUser(profileProvider.user!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil supprimée'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(profileProvider.error ?? 'Erreur lors de la suppression'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final profileProvider = context.read<ProfileProvider>();
    final authProvider = context.read<AuthProvider>();

    try {
      final success = await profileProvider.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        title: _titleController.text.trim(),
        bioShort: _bioShortController.text.trim(),
        website: _websiteController.text.trim(),
        socialLinkedin: _linkedinController.text.trim(),
        socialTwitter: _twitterController.text.trim(),
        socialFacebook: '', // Pas de champ pour Facebook dans l'UI actuelle
      );

      if (success && mounted) {
        // Mettre à jour l'AuthProvider avec les nouvelles données
        authProvider.updateUser(profileProvider.user!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        context.router.maybePop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(profileProvider.error ?? 'Erreur lors de la mise à jour'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

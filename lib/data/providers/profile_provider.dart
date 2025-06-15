import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:venturelink/data/models/user_model.dart';
import 'package:venturelink/data/services/user_api_service.dart';

class ProfileProvider extends ChangeNotifier {
  final UserApiService _userApiService;
  final ImagePicker _imagePicker = ImagePicker();

  ProfileProvider(this._userApiService);

  UserModel? _user;
  bool _isLoading = false;
  bool _isUploadingProfilePicture = false;
  bool _isUploadingCoverPicture = false;
  String? _error;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isUploadingProfilePicture => _isUploadingProfilePicture;
  bool get isUploadingCoverPicture => _isUploadingCoverPicture;
  String? get error => _error;

  /// Initialiser avec un utilisateur
  void setUser(UserModel? user) {
    _user = user;
    notifyListeners();
  }

  /// Récupérer le profil utilisateur
  Future<void> loadUserProfile() async {
    _setLoading(true);
    try {
      _user = await _userApiService.getCurrentUser();
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Mettre à jour le profil
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? location,
    String? title,
    String? bioShort,
    String? website,
    String? socialLinkedin,
    String? socialTwitter,
    String? socialFacebook,
  }) async {
    _setLoading(true);
    try {
      // Mettre à jour les informations de base de l'utilisateur
      final Map<String, dynamic> userData = {};
      if (firstName != null) userData['first_name'] = firstName;
      if (lastName != null) userData['last_name'] = lastName;
      if (email != null) userData['email'] = email;
      if (phoneNumber != null) userData['phone_number'] = phoneNumber;

      if (userData.isNotEmpty) {
        _user = await _userApiService.updateUserProfile(userData);
      }

      // Mettre à jour les détails du profil
      final Map<String, dynamic> profileData = {};
      if (location != null) profileData['location'] = location;
      if (title != null) profileData['title'] = title;
      if (bioShort != null) profileData['bio_short'] = bioShort;
      if (website != null) profileData['website'] = website;
      if (socialLinkedin != null) {
        profileData['social_linkedin'] = socialLinkedin;
      }
      if (socialTwitter != null) profileData['social_twitter'] = socialTwitter;
      if (socialFacebook != null) {
        profileData['social_facebook'] = socialFacebook;
      }

      if (profileData.isNotEmpty) {
        _user = await _userApiService.updateProfileDetails(profileData);
      }

      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Upload photo de profil depuis la caméra
  Future<bool> updateProfilePictureFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return false;

      return await uploadProfilePicture(File(image.path));
    } catch (e) {
      _setError('Erreur lors de la prise de photo: ${e.toString()}');
      return false;
    }
  }

  /// Upload photo de profil depuis la galerie
  Future<bool> updateProfilePictureFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return false;

      return await uploadProfilePicture(File(image.path));
    } catch (e) {
      _setError('Erreur lors de la sélection d\'image: ${e.toString()}');
      return false;
    }
  }

  /// Upload photo de profil
  Future<bool> uploadProfilePicture(File imageFile) async {
    _setUploadingProfilePicture(true);
    try {
      // Validation de la taille du fichier (max 5MB)
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('Le fichier est trop volumineux (max 5MB)');
      }

      _user = await _userApiService.uploadProfilePicture(imageFile);
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setUploadingProfilePicture(false);
    }
  }

  /// Upload photo de couverture
  Future<bool> uploadCoverPicture(File imageFile) async {
    _setUploadingCoverPicture(true);
    try {
      // Validation de la taille du fichier (max 5MB)
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('Le fichier est trop volumineux (max 5MB)');
      }

      _user = await _userApiService.uploadCoverPicture(imageFile);
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setUploadingCoverPicture(false);
    }
  }

  /// Supprimer photo de profil
  Future<bool> removeProfilePicture() async {
    _setUploadingProfilePicture(true);
    try {
      _user =
          await _userApiService.removeProfilePicture({'profile_picture': null});
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setUploadingProfilePicture(false);
    }
  }

  /// Supprimer photo de couverture
  Future<bool> removeCoverPicture() async {
    _setUploadingCoverPicture(true);
    try {
      _user = await _userApiService.removeCoverPicture({'cover_picture': null});
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setUploadingCoverPicture(false);
    }
  }

  /// Changer le mot de passe
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    try {
      await _userApiService.changePassword({
        'old_password': oldPassword,
        'new_password': newPassword,
      });
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Méthodes privées pour la gestion de l'état
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setUploadingProfilePicture(bool uploading) {
    _isUploadingProfilePicture = uploading;
    notifyListeners();
  }

  void _setUploadingCoverPicture(bool uploading) {
    _isUploadingCoverPicture = uploading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Nettoyer les données
  void clear() {
    _user = null;
    _isLoading = false;
    _isUploadingProfilePicture = false;
    _isUploadingCoverPicture = false;
    _error = null;
    notifyListeners();
  }
}

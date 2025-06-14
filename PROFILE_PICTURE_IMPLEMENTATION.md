# Implémentation de la Fonctionnalité Photo de Profil

## Vue d'ensemble

La fonctionnalité de photo de profil est maintenant 100% fonctionnelle dans l'application Flutter VentureLink. Elle permet aux utilisateurs de :

- Prendre une photo avec l'appareil photo
- Sélectionner une image depuis la galerie
- Supprimer leur photo de profil actuelle
- Voir un indicateur de progression pendant l'upload
- Compression automatique des images pour optimiser les performances

## Architecture

### Services

#### 1. `UserApiService` (`lib/data/services/user_api_service.dart`)
Service responsable des appels API pour la gestion des profils utilisateur :
- `uploadProfilePicture(File imageFile)` - Upload d'une photo de profil
- `uploadCoverPicture(File imageFile)` - Upload d'une photo de couverture
- `removeProfilePicture()` - Suppression de la photo de profil
- `removeCoverPicture()` - Suppression de la photo de couverture
- `updateProfile()` - Mise à jour des informations du profil
- `getCurrentUser()` - Récupération du profil utilisateur

#### 2. `ImageUtils` (`lib/core/utils/image_utils.dart`)
Utilitaire pour la gestion des images :
- Sélection d'images depuis la galerie
- Capture de photos avec l'appareil photo
- Compression automatique des images
- Validation des fichiers image
- Gestion des permissions
- Interface utilisateur pour la sélection de source

### Providers

#### 1. `ProfileProvider` (`lib/data/providers/profile_provider.dart`)
Provider pour la gestion de l'état des profils :
- Gestion de l'état de chargement
- Gestion des erreurs
- Upload et suppression de photos
- Mise à jour des informations de profil
- Synchronisation avec l'AuthProvider

### Widgets

#### 1. `ProfilePictureWidget` (`lib/presentation/widgets/profile_picture_widget.dart`)
Widget réutilisable pour l'affichage et la gestion des photos de profil :
- Affichage de la photo de profil avec fallback sur les initiales
- Bouton d'édition optionnel
- Interface de sélection d'image (bottom sheet)
- Indicateur de progression pendant l'upload
- Gestion des erreurs avec SnackBar

### Écrans

#### 1. `ProfileEditScreen` (`lib/presentation/screens/profile/profile_edit_screen.dart`)
Écran d'édition du profil avec fonctionnalité complète de photo de profil

#### 2. `ProfileScreen` (`lib/presentation/screens/profile/profile_screen.dart`)
Écran principal du profil avec possibilité de changer la photo

## Fonctionnalités

### Upload de Photo de Profil

1. **Sélection de Source** : L'utilisateur peut choisir entre :
   - Prendre une photo avec l'appareil photo
   - Sélectionner une image depuis la galerie

2. **Compression Automatique** :
   - Redimensionnement à 1024x1024 pixels maximum
   - Compression JPEG avec qualité 85%
   - Limite de taille à 2MB

3. **Validation** :
   - Formats supportés : JPG, JPEG, PNG, WEBP
   - Vérification des permissions d'accès

4. **Upload** :
   - Envoi via FormData à l'endpoint `/profiles/me/upload_profile_picture/`
   - Indicateur de progression visuel
   - Gestion des erreurs avec messages utilisateur

### Suppression de Photo de Profil

- Suppression via PATCH à `/profiles/me/` avec `profile_picture: null`
- Confirmation visuelle avec SnackBar
- Mise à jour immédiate de l'interface

### Gestion des États

- **Loading States** : Indicateurs visuels pendant les opérations
- **Error Handling** : Messages d'erreur contextuels
- **Success Feedback** : Confirmations des actions réussies

## Configuration

### Dépendances

Les dépendances suivantes sont requises dans `pubspec.yaml` :

```yaml
dependencies:
  image_picker: ^1.0.7
  flutter_image_compress: ^2.1.0
  permission_handler: ^11.1.0
  cached_network_image: ^3.3.1
  path_provider: ^2.1.2
```

### Permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>Cette application a besoin d'accéder à l'appareil photo pour prendre des photos de profil.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Cette application a besoin d'accéder à la galerie photo pour sélectionner des images de profil.</string>
```

### Injection de Dépendances

Le `ProfileProvider` et `UserApiService` sont configurés dans :
- `lib/core/di/service_locator.dart`
- `lib/main.dart`

## Utilisation

### Widget Réutilisable

```dart
ProfilePictureWidget(
  radius: 60,
  showEditButton: true,
  onTap: () {
    // Action personnalisée au tap
  },
)
```

### Dans un Écran

```dart
Consumer<ProfileProvider>(
  builder: (context, profileProvider, child) {
    return Column(
      children: [
        ProfilePictureWidget(
          radius: 50,
          showEditButton: true,
        ),
        if (profileProvider.isUploadingProfilePicture)
          const Text('Upload en cours...'),
        if (profileProvider.error != null)
          Text(
            profileProvider.error!,
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  },
)
```

## API Endpoints

### Upload Photo de Profil
- **Endpoint** : `POST /profiles/me/upload_profile_picture/`
- **Method** : FormData avec champ `profile_picture`
- **Response** : Profil utilisateur mis à jour

### Suppression Photo de Profil
- **Endpoint** : `PATCH /profiles/me/`
- **Body** : `{"profile_picture": null}`
- **Response** : Profil utilisateur mis à jour

## Tests

Pour tester la fonctionnalité :

1. **Test d'Upload** :
   - Ouvrir l'écran de profil
   - Appuyer sur le bouton caméra
   - Sélectionner "Prendre une photo" ou "Choisir dans la galerie"
   - Vérifier l'upload et la mise à jour de l'interface

2. **Test de Suppression** :
   - Avec une photo de profil existante
   - Appuyer sur le bouton caméra
   - Sélectionner "Supprimer la photo"
   - Vérifier la suppression et le retour aux initiales

3. **Test de Compression** :
   - Utiliser une image de grande taille (>2MB)
   - Vérifier que l'image est compressée automatiquement

## Maintenance

### Nettoyage des Fichiers Temporaires

Le système nettoie automatiquement les fichiers temporaires créés lors de la compression :

```dart
await ImageUtils.cleanupTemporaryImages();
```

### Gestion des Erreurs

Toutes les erreurs sont capturées et affichées à l'utilisateur via des SnackBar avec des messages contextuels en français.

## Sécurité

- Validation des types de fichiers
- Limitation de la taille des fichiers
- Compression automatique pour éviter les uploads trop volumineux
- Gestion sécurisée des permissions système 
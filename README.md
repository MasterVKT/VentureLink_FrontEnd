# VentureLink

Application Flutter pour connecter entrepreneurs et investisseurs.

## Configuration Google Sign-In

### Problème actuel
Google Sign-In échoue avec l'erreur `ApiException: 7` sur l'émulateur.

### Solutions

#### 1. Utiliser un émulateur avec Google Play Store
L'émulateur doit avoir Google Play Services installé :
```bash
# Créer un émulateur avec Google Play Store
flutter emulators --create --name PlayStore_API_30
flutter emulators --launch PlayStore_API_30
```

#### 2. Ajouter le SHA-1 de debug à Firebase
```bash
# Obtenir le SHA-1 du certificat de debug
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Ou sur Windows
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Ensuite, dans la [Console Firebase](https://console.firebase.google.com/) :
1. Aller dans **Paramètres du projet** > **Vos applications**
2. Sélectionner l'application Android
3. Ajouter l'empreinte SHA-1 dans **Empreintes de certificat SHA**

#### 3. Vérifier google-services.json
Le fichier `android/app/google-services.json` doit être à jour et correspondre à votre projet Firebase.

#### 4. Utiliser un appareil physique
Google Sign-In fonctionne toujours mieux sur un appareil physique avec Google Play Services.

### Émulateurs recommandés
- **Pixel 6 API 33** avec Google Play Store
- **Pixel 4 API 30** avec Google Play Store
- Éviter les émulateurs "AOSP" sans Google Play Services

### Test de la configuration
```bash
flutter run -d <device_id>
```

## Débogage Google Sign-In

### Erreur de Cast Pigeon (`List<Object?> is not a subtype of type PigeonUserDetails?`)

Cette erreur est liée à un problème de typage entre les packages Google Sign-In et les types Pigeon générés.

#### Solutions implementées dans le code :
1. **Gestion automatique de récupération** : Le code détecte automatiquement cette erreur et tente une récupération
2. **Nettoyage de l'état** : L'état Google Sign-In est nettoyé avant une nouvelle tentative
3. **Création d'instance isolée** : Une nouvelle instance GoogleSignIn est créée en cas d'erreur

#### Solutions manuelles si le problème persiste :

1. **Redémarrer l'application complètement**
2. **Utiliser un appareil physique** au lieu de l'émulateur
3. **Vérifier la configuration SHA-1** dans Firebase Console
4. **Mettre à jour Google Play Services** sur l'appareil/émulateur

#### Vérification de la configuration :
```bash
# Vérifier que le fichier google-services.json est au bon endroit
ls android/app/google-services.json

# Vérifier les empreintes SHA-1
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

## Installation

```bash
flutter pub get
flutter pub run build_runner build
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

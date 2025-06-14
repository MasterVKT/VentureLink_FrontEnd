import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venturelink/data/services/user_preferences_service.dart';

@GenerateMocks([SharedPreferences])
import 'user_preferences_service_test.mocks.dart';

void main() {
  group('UserPreferencesService Tests', () {
    late MockSharedPreferences mockPrefs;
    late UserPreferencesService service;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      service = UserPreferencesService(mockPrefs);
    });

    group('Currency Preferences', () {
      test('getPreferredCurrency - should return default when not set', () {
        // Arrange
        when(mockPrefs.getString(any)).thenReturn(null);

        // Act
        final result = service.getPreferredCurrency();

        // Assert
        expect(result, equals('XAF'));
        verify(mockPrefs.getString('preferred_currency')).called(1);
      });

      test('getPreferredCurrency - should return stored value', () {
        // Arrange
        when(mockPrefs.getString(any)).thenReturn('EUR');

        // Act
        final result = service.getPreferredCurrency();

        // Assert
        expect(result, equals('EUR'));
        verify(mockPrefs.getString('preferred_currency')).called(1);
      });

      test('setPreferredCurrency - should save valid currency', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

        // Act
        final result = await service.setPreferredCurrency('EUR');

        // Assert
        expect(result, isTrue);
        verify(mockPrefs.setString('preferred_currency', 'EUR')).called(1);
      });

      test('setPreferredCurrency - should throw on invalid currency', () async {
        // Act & Assert
        expect(
            () => service.setPreferredCurrency('INVALID'), throwsArgumentError);
        verifyNever(mockPrefs.setString(any, any));
      });
    });

    group('Language Preferences', () {
      test('getPreferredLanguage - should return default when not set', () {
        // Arrange
        when(mockPrefs.getString(any)).thenReturn(null);

        // Act
        final result = service.getPreferredLanguage();

        // Assert
        expect(result, equals('fr'));
        verify(mockPrefs.getString('preferred_language')).called(1);
      });

      test('getPreferredLanguage - should return stored value', () {
        // Arrange
        when(mockPrefs.getString(any)).thenReturn('en');

        // Act
        final result = service.getPreferredLanguage();

        // Assert
        expect(result, equals('en'));
        verify(mockPrefs.getString('preferred_language')).called(1);
      });

      test('setPreferredLanguage - should save valid language', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

        // Act
        final result = await service.setPreferredLanguage('en');

        // Assert
        expect(result, isTrue);
        verify(mockPrefs.setString('preferred_language', 'en')).called(1);
      });

      test('setPreferredLanguage - should throw on invalid language', () async {
        // Act & Assert
        expect(
            () => service.setPreferredLanguage('invalid'), throwsArgumentError);
        verifyNever(mockPrefs.setString(any, any));
      });
    });

    group('Theme Preferences', () {
      test('getThemeMode - should return default when not set', () {
        // Arrange
        when(mockPrefs.getInt(any)).thenReturn(null);

        // Act
        final result = service.getThemeMode();

        // Assert
        expect(result, equals(0)); // Automatique par défaut
        verify(mockPrefs.getInt('theme_mode')).called(1);
      });

      test('getThemeMode - should return stored value', () {
        // Arrange
        when(mockPrefs.getInt(any)).thenReturn(2); // Mode sombre

        // Act
        final result = service.getThemeMode();

        // Assert
        expect(result, equals(2));
        verify(mockPrefs.getInt('theme_mode')).called(1);
      });

      test('setThemeMode - should save valid theme mode', () async {
        // Arrange
        when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);

        // Act
        final result = await service.setThemeMode(1); // Mode clair

        // Assert
        expect(result, isTrue);
        verify(mockPrefs.setInt('theme_mode', 1)).called(1);
      });

      test('setThemeMode - should throw on invalid mode', () async {
        // Act & Assert
        expect(() => service.setThemeMode(5), throwsArgumentError);
        verifyNever(mockPrefs.setInt(any, any));
      });
    });

    group('Notification Preferences', () {
      test('getNotificationsEnabled - should return default when not set', () {
        // Arrange
        when(mockPrefs.getBool(any)).thenReturn(null);

        // Act
        final result = service.getNotificationsEnabled();

        // Assert
        expect(result, isTrue); // Activées par défaut
        verify(mockPrefs.getBool('notifications_enabled')).called(1);
      });

      test('getNotificationsEnabled - should return stored value', () {
        // Arrange
        when(mockPrefs.getBool(any)).thenReturn(false);

        // Act
        final result = service.getNotificationsEnabled();

        // Assert
        expect(result, isFalse);
        verify(mockPrefs.getBool('notifications_enabled')).called(1);
      });

      test('setNotificationsEnabled - should save preference', () async {
        // Arrange
        when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);

        // Act
        final result = await service.setNotificationsEnabled(false);

        // Assert
        expect(result, isTrue);
        verify(mockPrefs.setBool('notifications_enabled', false)).called(1);
      });
    });

    test('clearPreferences - should clear all preferences', () async {
      // Arrange
      when(mockPrefs.clear()).thenAnswer((_) async => true);

      // Act
      final result = await service.clearPreferences();

      // Assert
      expect(result, isTrue);
      verify(mockPrefs.clear()).called(1);
    });
  });
}

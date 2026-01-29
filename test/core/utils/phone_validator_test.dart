import 'package:flutter_test/flutter_test.dart';
import 'package:venturelink/core/utils/phone_validator.dart';

void main() {
  group('PhoneValidator', () {
    group('validatePhoneNumber', () {
      test('should accept valid Cameroonian phone number with +237', () {
        const phone = '+237699999999';
        final result = PhoneValidator.validatePhoneNumber(phone);

        expect(result.isValid, true);
        expect(result.formatted, '+237699999999');
        expect(result.message, null);
      });

      test('should accept valid phone number without + prefix', () {
        const phone = '699999999';
        final result = PhoneValidator.validatePhoneNumber(phone);

        expect(result.isValid, true);
        expect(result.formatted, '+237699999999');
        expect(result.message, null);
      });

      test('should accept valid international phone number', () {
        const phone = '+33123456789';
        final result = PhoneValidator.validatePhoneNumber(phone);

        expect(result.isValid, true);
        expect(result.formatted, '+33123456789');
        expect(result.message, null);
      });

      test('should reject empty phone number', () {
        const phone = '';
        final result = PhoneValidator.validatePhoneNumber(phone);

        expect(result.isValid, false);
        expect(result.formatted, null);
        expect(result.message, 'Le numéro de téléphone est requis');
      });

      test('should reject phone number with less than 9 digits', () {
        const phone = '12345678';
        final result = PhoneValidator.validatePhoneNumber(phone);

        expect(result.isValid, false);
        expect(result.formatted, null);
        expect(result.message, 'Le numéro doit contenir au moins 9 chiffres');
      });

      test('should reject phone number with invalid format', () {
        const phone = '0699999999';
        final result = PhoneValidator.validatePhoneNumber(phone);

        expect(result.isValid, false);
        expect(result.formatted, null);
        expect(result.message, 'Format de numéro invalide');
      });

      test('should clean phone number with spaces and dashes', () {
        const phone = '+237 699-999-999';
        final result = PhoneValidator.validatePhoneNumber(phone);

        expect(result.isValid, true);
        expect(result.formatted, '+237699999999');
        expect(result.message, null);
      });

      test('should clean phone number with parentheses', () {
        const phone = '+237 (699) 999 999';
        final result = PhoneValidator.validatePhoneNumber(phone);

        expect(result.isValid, true);
        expect(result.formatted, '+237699999999');
        expect(result.message, null);
      });
    });

    group('formatForDisplay', () {
      test('should format valid phone number', () {
        const phone = '699999999';
        final result = PhoneValidator.formatForDisplay(phone);

        expect(result, '+237699999999');
      });

      test('should return original phone if invalid', () {
        const phone = '123';
        final result = PhoneValidator.formatForDisplay(phone);

        expect(result, '123');
      });
    });

    group('isValid', () {
      test('should return true for valid phone number', () {
        const phone = '+237699999999';
        final result = PhoneValidator.isValid(phone);

        expect(result, true);
      });

      test('should return false for invalid phone number', () {
        const phone = '123';
        final result = PhoneValidator.isValid(phone);

        expect(result, false);
      });
    });
  });
}

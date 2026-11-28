import 'package:flutter_test/flutter_test.dart';
import 'package:lumad_lingua/utils/level_helper.dart';
import 'package:lumad_lingua/utils/validators.dart';
import 'package:lumad_lingua/services/local_ml_service.dart';

void main() {
  group('LevelHelper Unit Tests', () {
    test('Calculate level correctly based on XP', () {
      expect(LevelHelper.calculateLevel(0), 1);
      expect(LevelHelper.calculateLevel(100), 2);
      expect(LevelHelper.calculateLevel(250), 3); // 100 + 150 = 250
    });

    test('Get level titles correctly', () {
      expect(LevelHelper.getLevelTitle(1), 'Beginning Learner 📚');
      expect(LevelHelper.getLevelTitle(2), 'Mansaka Explorer 🌿');
      expect(LevelHelper.getLevelTitle(8), 'Datu Honor Elder 👑');
    });

    test('Calculate level progress ratio correctly', () {
      expect(LevelHelper.getLevelProgressRatio(0), 0.0);
      expect(LevelHelper.getLevelProgressRatio(50), 0.5);
    });
  });

  group('AppValidators Unit Tests', () {
    test('Email validator works correctly', () {
      expect(AppValidators.validateEmail(''), 'Email is required');
      expect(AppValidators.validateEmail('invalid-email'), 'Please enter a valid email address');
      expect(AppValidators.validateEmail('test@example.com'), null);
      expect(AppValidators.validateEmail('user@subdomain.photography'), null);
      expect(AppValidators.validateEmail('user.name+tag@example.co.uk'), null);
    });

    test('Password validator works correctly', () {
      expect(AppValidators.validatePassword(''), 'Password is required');
      expect(AppValidators.validatePassword('12345'), 'Password must be at least 6 characters long');
      expect(AppValidators.validatePassword('123456'), null);
    });

    test('Confirm password validator works correctly', () {
      expect(AppValidators.validateConfirmPassword('', 'secret'), 'Please confirm your password');
      expect(AppValidators.validateConfirmPassword('wrong', 'secret'), 'Passwords do not match');
      expect(AppValidators.validateConfirmPassword('secret', 'secret'), null);
    });

    test('Name validator works correctly', () {
      expect(AppValidators.validateName(''), 'Full name is required');
      expect(AppValidators.validateName('A'), 'Name must be at least 2 characters long');
      expect(AppValidators.validateName('Datu Ali'), null);
    });
  });

  group('Pitch Contour Extraction Unit Tests', () {
    test('generateReferencePitchContour produces non-empty valid pitch points', () {
      final points = LocalMlService.generateReferencePitchContour('Madyaw na masurom');
      expect(points.isNotEmpty, true);
      expect(points.length, 16);
      for (final p in points) {
        expect(p >= 0.0 && p <= 100.0, true);
      }
    });

    test('extractPitchContourFromMfcc handles empty and populated MFCC frames', () {
      final emptyPoints = LocalMlService.extractPitchContourFromMfcc([]);
      expect(emptyPoints.length, 16);

      final dummyMfcc = List.generate(20, (i) => List.generate(13, (j) => 0.5));
      final points = LocalMlService.extractPitchContourFromMfcc(dummyMfcc);
      expect(points.length, 16);
    });

    test('calculateAutocorrelationPitch produces valid 16 pitch points from dummy PCM bytes', () {
      final dummyBytes = List.generate(1000, (i) => (i % 256));
      final points = LocalMlService.calculateAutocorrelationPitch(dummyBytes);
      expect(points.length, 16);
      for (final p in points) {
        expect(p >= 0.0 && p <= 100.0, true);
      }
    });
  });
}

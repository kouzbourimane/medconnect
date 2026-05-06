import 'package:flutter_test/flutter_test.dart';
import 'package:medconnect_app/models/auth_response.dart';
import 'package:medconnect_app/models/utilisateur.dart';
import 'package:medconnect_app/repositories/auth_repository.dart';
import 'package:medconnect_app/view_models/patient_auth_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_auth_service.dart';

void main() {
  group('PatientAuthViewModel', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'login stores token and patient user information on success',
      () async {
        final viewModel = PatientAuthViewModel(
          AuthRepository(
            FakeAuthService(
              patientLoginResponse: AuthResponse(
                token: 'patient-token',
                user: Utilisateur(
                  id: 7,
                  username: 'patient1',
                  email: 'patient@example.com',
                  role: 'PATIENT',
                  isActive: true,
                ),
              ),
            ),
          ),
        );

        final success = await viewModel.login('patient@example.com', 'secret');
        final prefs = await SharedPreferences.getInstance();

        expect(success, isTrue);
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.errorMessage, isNull);
        expect(prefs.getString('auth_token'), 'patient-token');
        expect(prefs.getString('user_id'), '7');
        expect(prefs.getString('username'), 'patient1');
        expect(prefs.getString('user_role'), 'PATIENT');
      },
    );

    test('login exposes a readable error message on failure', () async {
      final viewModel = PatientAuthViewModel(
        AuthRepository(
          FakeAuthService(loginError: Exception('Identifiants invalides')),
        ),
      );

      final success = await viewModel.login('bad@example.com', 'wrong');

      expect(success, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, 'Identifiants invalides');
    });
  });
}

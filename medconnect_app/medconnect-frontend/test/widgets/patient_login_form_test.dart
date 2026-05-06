import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medconnect_app/repositories/auth_repository.dart';
import 'package:medconnect_app/view_models/patient_auth_view_model.dart';
import 'package:medconnect_app/views/auth/widgets/patient_login_form.dart';
import 'package:provider/provider.dart';

import '../support/fake_auth_service.dart';

Widget _buildPatientLoginForm({PatientAuthViewModel? viewModel}) {
  return ChangeNotifierProvider<PatientAuthViewModel>(
    create: (_) =>
        viewModel ?? PatientAuthViewModel(AuthRepository(FakeAuthService())),
    child: const MaterialApp(home: Scaffold(body: PatientLoginForm())),
  );
}

void main() {
  group('PatientLoginForm', () {
    testWidgets('shows validation errors when submitted empty', (tester) async {
      await tester.pumpWidget(_buildPatientLoginForm());

      await tester.tap(find.text('Se connecter'));
      await tester.pump();

      expect(find.text('Veuillez entrer votre email'), findsOneWidget);
      expect(find.text('Veuillez entrer votre mot de passe'), findsOneWidget);
    });

    testWidgets('validates email format', (tester) async {
      await tester.pumpWidget(_buildPatientLoginForm());

      await tester.enterText(find.byType(TextFormField).at(0), 'email');
      await tester.enterText(find.byType(TextFormField).at(1), 'secret');
      await tester.tap(find.text('Se connecter'));
      await tester.pump();

      expect(find.text('Email invalide'), findsOneWidget);
    });

    testWidgets('toggles password visibility icon', (tester) async {
      await tester.pumpWidget(_buildPatientLoginForm());

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });
}

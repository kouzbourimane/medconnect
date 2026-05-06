import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medconnect_app/repositories/auth_repository.dart';
import 'package:medconnect_app/view_models/doctor_auth_view_model.dart';
import 'package:medconnect_app/view_models/patient_auth_view_model.dart';
import 'package:medconnect_app/views/auth/combined_login_screen.dart';
import 'package:provider/provider.dart';

import '../support/fake_auth_service.dart';

Widget _buildCombinedLoginScreen() {
  final authRepository = AuthRepository(FakeAuthService());

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => PatientAuthViewModel(authRepository),
      ),
      ChangeNotifierProvider(
        create: (_) => DoctorAuthViewModel(authRepository),
      ),
    ],
    child: const MaterialApp(home: CombinedLoginScreen()),
  );
}

void main() {
  testWidgets('switches between patient and doctor login forms', (
    tester,
  ) async {
    await tester.pumpWidget(_buildCombinedLoginScreen());

    expect(find.text('MedConnect'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Email Professionnel'), findsNothing);

    await tester.tap(find.textContaining('decin'));
    await tester.pumpAndSettle();

    expect(find.text('Email'), findsNothing);
    expect(find.text('Email Professionnel'), findsOneWidget);
  });
}

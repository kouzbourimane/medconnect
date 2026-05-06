import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:medconnect_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login UI displays patient form and switches to doctor form', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('MedConnect'), findsOneWidget);
    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);

    await tester.tap(find.text('Se connecter'));
    await tester.pump();

    expect(find.text('Veuillez entrer votre email'), findsOneWidget);
    expect(find.text('Veuillez entrer votre mot de passe'), findsOneWidget);

    await tester.tap(find.textContaining('decin'));
    await tester.pumpAndSettle();

    expect(find.text('Email Professionnel'), findsOneWidget);
  });
}

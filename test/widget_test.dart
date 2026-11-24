import 'package:flutter_test/flutter_test.dart';
import 'package:cv_flutter_elisabeth/main.dart';

void main() {
  testWidgets('Connexion s’affiche au lancement', (tester) async {
    await tester.pumpWidget(const CvApp());
    expect(find.text('Bienvenue'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Mot de passe'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Créer un compte'), findsOneWidget);
  });
}

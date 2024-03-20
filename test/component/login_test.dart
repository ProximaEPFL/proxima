import "package:firebase_core/firebase_core.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/views/pages/home_page.dart";
import "package:proxima/views/pages/login_page.dart";

import "../utils/setup_firebase_mocks.dart";
import "../utils/testing_widgets.dart";

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group("Login Page Tests", () {
    testWidgets("Basic Login Screen test", (tester) async {
      await tester.pumpWidget(testingApp());
      await tester.pumpAndSettle();

      final loginButton = find.byKey(LoginPage.loginKey);

      // Check that the login button is displayed and contains the "Login" text
      expect(
        find.descendant(of: loginButton, matching: find.text("Login")),
        findsOneWidget,
      );

      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Check that pressing login redirects to the homepage
      final homePage = find.byType(HomePage);
      expect(homePage, findsOneWidget);
    });
  });
}

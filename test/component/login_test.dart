import "package:firebase_core/firebase_core.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/main.dart";
import "package:proxima/views/home/top_bar/home_top_bar.dart";
import "package:proxima/views/pages/home_page.dart";
import "package:proxima/views/pages/login_page.dart";

import "utils/firebase/setup_firebase_mocks.dart";
import "utils/firebase/testing_login_providers.dart";

void main() {
  setupFirebaseAuthMocks();

  final mockedProxima = ProviderScope(
    overrides: firebaseMocksOverrides,
    child: const ProximaApp(),
  );

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets("Login to Home Page", (tester) async {
    await tester.pumpWidget(mockedProxima);
    await tester.pumpAndSettle();

    final loginButton = find.byKey(LoginPage.loginButtonKey);

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

  testWidgets("Login and Logout", (tester) async {
    await tester.pumpWidget(mockedProxima);
    await tester.pumpAndSettle();

    final loginButton = find.byKey(LoginPage.loginButtonKey);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    final logoutButton = find.byKey(HomeTopBar.logoutButtonKey);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    // Check that pressing logout redirects to the login page
    final loginPage = find.byType(LoginPage);
    expect(loginPage, findsOneWidget);
  });
}

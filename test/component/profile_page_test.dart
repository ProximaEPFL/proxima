import "package:firebase_core/firebase_core.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/main.dart";
import "package:proxima/views/pages/create_account_page.dart";
import "package:proxima/views/pages/home_page.dart";
import "package:proxima/views/pages/login/login_button.dart";
import "package:proxima/views/pages/login/login_page.dart";
import "package:proxima/views/pages/profile/profile_page.dart";

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

  testWidgets("Show profile page", (tester) async {
    await tester.pumpWidget(mockedProxima);
    await tester.pumpAndSettle();

    // Check for the logo on the Login Page
    final logoFinder = find.byKey(LoginPage.logoKey);
    expect(logoFinder, findsOneWidget);

    // Check for the slogan on the Login Page
    final sloganFinder = find.text(LoginPage.tagLineText);
    expect(sloganFinder, findsOneWidget);

    final loginButton = find.byKey(LoginButton.loginButtonKey);
    // Check that the login button is displayed and contains the "Login" text
    expect(
      find.descendant(
        of: loginButton,
        matching: find.text("Sign in with Google"),
      ),
      findsOneWidget,
    );

    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Check that pressing login redirects to the create account page
    final createAccountPage = find.byType(CreateAccountPage);
    expect(createAccountPage, findsOneWidget);

    // And that pushing the confirm button redirects to the home page
    final confirmButton = find.byKey(CreateAccountPage.confirmButtonKey);
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    // We must now be on the home page
    final homePage = find.byType(HomePage);
    expect(homePage, findsOneWidget);

    // Go to the profile page
    final profileButton = find.byKey(HomePage.profilePageButtonKey);
    await tester.tap(profileButton);
    await tester.pumpAndSettle();

    // Check that the unique username field is displayed
    final profilePage = find.byType(ProfilePage);
    expect(profilePage, findsOneWidget);
  });
}

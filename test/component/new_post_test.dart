import "package:firebase_core/firebase_core.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/main.dart";
import "package:proxima/views/pages/home_page.dart";
import "package:proxima/views/pages/login_page.dart";
import "package:proxima/views/pages/new_post_page.dart";

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

  // TODO find a way to test only the new post page without changing main.dart

  testWidgets("Create post contains title, body and post button", (tester) async {
    await tester.pumpWidget(mockedProxima);
    await tester.pumpAndSettle();

    final loginButton = find.byKey(LoginPage.loginButtonKey);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    final newPostButton = find.byKey(HomePage.newPostKey);
    await tester.tap(newPostButton);
    await tester.pumpAndSettle();

    final titleFinder = find.text("Title");
    final bodyFinder = find.text("Body");
    final postButtonFinder = find.text("Post");

    expect(titleFinder, findsOneWidget);
    expect(bodyFinder, findsOneWidget);
    expect(postButtonFinder, findsOneWidget);
  });
}

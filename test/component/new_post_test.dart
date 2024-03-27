import "package:firebase_core/firebase_core.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/main.dart";
import "package:proxima/views/pages/home_page.dart";
import "package:proxima/views/pages/login_page.dart";
import "package:proxima/views/pages/new_post_page.dart";

import "utils/firebase/setup_firebase_mocks.dart";
import "utils/firebase/testing_login_providers.dart";

Future<void> loginAndNavigateToNewPost(WidgetTester tester) async {
  final loginButton = find.byKey(LoginPage.loginButtonKey);
  await tester.tap(loginButton);
  await tester.pumpAndSettle();

  final newPostButton = find.byKey(HomePage.newPostKey);
  await tester.tap(newPostButton);
  await tester.pumpAndSettle();
}

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

  testWidgets("Create post contains title, body and post button",
      (tester) async {
    await tester.pumpWidget(mockedProxima);
    await tester.pumpAndSettle();

    await loginAndNavigateToNewPost(tester);

    final titleFinder = find.text(NewPostPage.titleHint);
    final bodyFinder = find.text(NewPostPage.bodyHint);
    final postButtonFinder = find.text(NewPostPage.postButtonText);

    expect(titleFinder, findsOneWidget);
    expect(bodyFinder, findsOneWidget);
    expect(postButtonFinder, findsOneWidget);
  });

  testWidgets("Back button works", (widgetTester) async {
    await widgetTester.pumpWidget(mockedProxima);
    await widgetTester.pumpAndSettle();

    await loginAndNavigateToNewPost(widgetTester);

    final backButton = find.byKey(NewPostPage.backButtonKey);
    await widgetTester.tap(backButton);
    await widgetTester.pumpAndSettle();

    // check that we are no longer on the new post page
    final titleFinder = find.text(NewPostPage.titleHint);
    expect(titleFinder, findsNothing);
  });

  testWidgets("Post button works", (widgetTester) async {
    await widgetTester.pumpWidget(mockedProxima);
    await widgetTester.pumpAndSettle();

    await loginAndNavigateToNewPost(widgetTester);

    final postButtonFinder = find.text(NewPostPage.postButtonText);
    await widgetTester.tap(postButtonFinder);
    await widgetTester.pumpAndSettle();

    // check that we are no longer on the new post page
    final titleFinder = find.text(NewPostPage.titleHint);
    expect(titleFinder, findsNothing);
  });
}

import "package:firebase_core/firebase_core.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/main.dart";
import "package:proxima/views/pages/create_account_page.dart";
import "package:proxima/views/pages/home_page.dart";
import "package:proxima/views/pages/login/login_button.dart";
import "package:proxima/views/pages/new_post_page.dart";

import "utils/firebase/setup_firebase_mocks.dart";
import "utils/firebase/testing_login_providers.dart";

Future<void> loginAndNavigateToNewPost(WidgetTester tester) async {
  final loginButton = find.byKey(LoginButton.loginButtonKey);
  await tester.tap(loginButton);
  await tester.pumpAndSettle();

  // And that pushing the confirm button redirects to the home page
  final confirmButton = find.byKey(CreateAccountPage.confirmButtonKey);
  await tester.tap(confirmButton);
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

    final titleFinder = find.text(NewPostForm.titleHint);
    final bodyFinder = find.text(NewPostForm.bodyHint);
    final postButtonFinder = find.text(NewPostForm.postButtonText);

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
    final titleFinder = find.text(NewPostForm.titleHint);
    expect(titleFinder, findsNothing);
  });

  testWidgets("Accepts non empty post", (widgetTester) async {
    await widgetTester.pumpWidget(mockedProxima);
    await widgetTester.pumpAndSettle();

    await loginAndNavigateToNewPost(widgetTester);

    final titleFinder = find.byKey(NewPostForm.titleFieldKey);
    await widgetTester.enterText(titleFinder, "I like turtles");
    await widgetTester.pumpAndSettle();

    final bodyFinder = find.byKey(NewPostForm.bodyFieldKey);
    await widgetTester.enterText(bodyFinder, "Look at them go!");
    await widgetTester.pumpAndSettle();

    final postButtonFinder = find.text(NewPostForm.postButtonText);
    await widgetTester.tap(postButtonFinder);
    await widgetTester.pumpAndSettle();

    // check that we are no longer on the new post page
    expect(titleFinder, findsNothing);
  });

  testWidgets("Refuses empty post", (widgetTester) async {
    await widgetTester.pumpWidget(mockedProxima);
    await widgetTester.pumpAndSettle();

    await loginAndNavigateToNewPost(widgetTester);

    final postButtonFinder = find.text(NewPostForm.postButtonText);
    await widgetTester.tap(postButtonFinder);
    await widgetTester.pumpAndSettle();

    // check that we are still on the new post page
    final titleFinder = find.text(NewPostForm.titleHint);
    expect(titleFinder, findsOne);
  });
}

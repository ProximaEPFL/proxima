import "package:firebase_core/firebase_core.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/main.dart";
import "package:proxima/views/pages/create_account_page.dart";
import "package:proxima/views/pages/home_page.dart";
import "package:proxima/views/pages/login/login_button.dart";
import "package:proxima/views/pages/new_post_page.dart";

import "utils/firebase/setup_firebase_mocks.dart";
import "utils/firebase/testing_login_providers.dart";

void main() {
  setupFirebaseAuthMocks();

  final mockedPage = ProviderScope(
    overrides: firebaseMocksOverrides,
    child: const MaterialApp(
      home: NewPostPage(),
    ),
  );

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets("Create post contains title, body and post button",
      (tester) async {
    await tester.pumpWidget(mockedPage);
    await tester.pumpAndSettle();

    final titleFinder = find.byKey(NewPostForm.titleFieldKey);
    final bodyFinder = find.byKey(NewPostForm.bodyFieldKey);
    final postButtonFinder = find.byKey(NewPostForm.postButtonKey);

    expect(titleFinder, findsOneWidget);
    expect(bodyFinder, findsOneWidget);
    expect(postButtonFinder, findsOneWidget);
  });

  testWidgets("Back button works", (widgetTester) async {
    await widgetTester.pumpWidget(mockedPage);
    await widgetTester.pumpAndSettle();

    final backButton = find.byKey(NewPostPage.backButtonKey);
    await widgetTester.tap(backButton);
    await widgetTester.pumpAndSettle();

    // check that we are no longer on the new post page
    final titleFinder = find.byKey(NewPostForm.titleFieldKey);
    expect(titleFinder, findsNothing);
  });

  testWidgets("Accepts non empty post", (widgetTester) async {
    await widgetTester.pumpWidget(mockedPage);
    await widgetTester.pumpAndSettle();

    final titleFinder = find.byKey(NewPostForm.titleFieldKey);
    await widgetTester.enterText(titleFinder, "I like turtles");
    await widgetTester.pumpAndSettle();

    final bodyFinder = find.byKey(NewPostForm.bodyFieldKey);
    await widgetTester.enterText(bodyFinder, "Look at them go!");
    await widgetTester.pumpAndSettle();

    final postButtonFinder = find.byKey(NewPostForm.postButtonKey);
    await widgetTester.tap(postButtonFinder);
    await widgetTester.pumpAndSettle();

    // check that we are no longer on the new post page
    expect(titleFinder, findsNothing);
  });

  testWidgets("Refuses empty post", (widgetTester) async {
    await widgetTester.pumpWidget(mockedPage);
    await widgetTester.pumpAndSettle();

    final postButtonFinder = find.byKey(NewPostForm.postButtonKey);
    await widgetTester.tap(postButtonFinder);
    await widgetTester.pumpAndSettle();

    // check that we are still on the new post page
    final titleFinder = find.byKey(NewPostForm.titleFieldKey);
    expect(titleFinder, findsOne);
  });
}

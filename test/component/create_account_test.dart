import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/pages/create_account_page.dart";

void main() {
  const mockedPage =
      ProviderScope(child: MaterialApp(home: CreateAccountPage()));

  testWidgets("Text fields are visible", (tester) async {
    await tester.pumpWidget(mockedPage);
    await tester.pumpAndSettle();

    // Check that the unique username field is displayed
    final uniqueUsernameField =
        find.byKey(CreateAccountPage.uniqueUsernameFieldKey);
    expect(uniqueUsernameField, findsOneWidget);

    // Check that the pseudo field is displayed
    final pseudoField = find.byKey(CreateAccountPage.pseudoFieldKey);
    expect(pseudoField, findsOneWidget);
  });
}

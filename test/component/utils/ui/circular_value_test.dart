import "dart:math";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/utils/ui/circular_value.dart";
import "package:proxima/utils/ui/error_alert.dart";

void main() {
  Widget testCircularValue(AsyncValue<void> value) => CircularValue(
        value: value,
        builder: (context, data) => const Text("Completed"),
        fallbackBuilder: (context, error) => const Text("Strange Error"),
      );

  testWidgets(
      "CircularValue should show CircularProgressIndicator when loading", (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: testCircularValue(const AsyncValue.loading()),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets("CicularValue should build with value when finished", (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: testCircularValue(const AsyncValue.data(null)),
        ),
      ),
    );

    expect(find.text("Completed"), findsOneWidget);
  });

  testWidgets("CicularValue should build error when error", (
    tester,
  ) async {
    final testException = Exception("Blue moon");

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: testCircularValue(
              AsyncValue.error(testException, StackTrace.empty)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // expect to find a popup dialog
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining("Blue moon"), findsOneWidget);
    // find ok button
    final okButton = find.byKey(ErrorAlert.okButtonKey);
    expect(okButton, findsOneWidget);
    await tester.tap(okButton);
    await tester.pumpAndSettle();

    expect(find.text("Strange Error"), findsOneWidget);
  });
}

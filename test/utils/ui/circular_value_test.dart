import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/components/async/error_alert.dart";
import "package:proxima/views/components/async/logo_progress_indicator.dart";

import "../../mocks/providers/provider_circular_value.dart";

void main() {
  testWidgets("CircularValue should show a LogoProgressIndicator when loading",
      (
    tester,
  ) async {
    await tester.pumpWidget(circularValueProvider(const AsyncValue.loading()));

    expect(find.byType(LogoProgressIndicator), findsOneWidget);
  });

  testWidgets("CicularValue should build with value when finished", (
    tester,
  ) async {
    await tester.pumpWidget(circularValueProvider(const AsyncValue.data(null)));

    await tester.pumpAndSettle();
    expect(find.text("Completed"), findsOneWidget);
  });

  testWidgets("CicularValue should build error when error", (
    tester,
  ) async {
    final testException = Exception("Blue moon");

    await tester.pumpWidget(
      circularValueProvider(
        AsyncValue.error(testException, StackTrace.empty),
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

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/views/components/async/error_alert.dart";

import "../../mocks/providers/provider_circular_value.dart";

void main() {
  testWidgets(
      "CircularValue should show CircularProgressIndicator when loading", (
    tester,
  ) async {
    await tester.pumpWidget(
      circularValueProvider(
        () async {
          await Future.delayed(Durations.long1);
          return 1;
        },
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets("CicularValue should build with value when finished", (
    tester,
  ) async {
    await tester.pumpWidget(
      circularValueProvider(
        () => Future.value(1),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text("Completed"), findsOneWidget);
  });

  testWidgets("CicularValue should build error when error", (
    tester,
  ) async {
    await tester.pumpWidget(
      circularValueProvider(
        () async {
          await Future.delayed(Durations.long1);
          throw Exception("Blue moon");
        },
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

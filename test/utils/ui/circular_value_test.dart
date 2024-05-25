import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/views/components/async/error_alert.dart";
import "package:proxima/views/components/async/logo_progress_indicator.dart";

import "../../mocks/providers/provider_circular_value.dart";
import "../delay_async_func.dart";

void main() {
  testWidgets("CircularValue should show a LogoProgressIndicator when loading",
      (tester) async {
    // Pump a future with short waiting time
    await tester.pumpWidget(
      circularValueProvider(
        () async {
          await Future.delayed(Durations.short1);
          return 1;
        },
      ),
    );
    await tester.pump();

    // Check loading state
    expect(find.byType(LogoProgressIndicator), findsOneWidget);

    // Clear flutter timers (pending timeout)
    await tester.pumpAndSettle(delayNeededForAsyncFunctionExecution);
  });

  testWidgets("CicularValue should build with value when finished",
      (tester) async {
    // Pump an instantaneous future value
    await tester.pumpWidget(
      circularValueProvider(
        () => Future.value(1),
      ),
    );

    await tester.pumpAndSettle();

    // Check value state
    expect(find.text("Completed"), findsOneWidget);
  });

  testWidgets("CicularValue should build error when error", (tester) async {
    // Pump a future that throws an error
    await tester.pumpWidget(
      circularValueProvider(
        () async {
          await Future.delayed(Durations.short1);
          throw Exception("Blue moon");
        },
      ),
    );

    await tester.pumpAndSettle(delayNeededForAsyncFunctionExecution);

    // Expect to find a popup dialog
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining("Blue moon"), findsOneWidget);

    // Find ok button
    final okButton = find.byKey(ErrorAlert.okButtonKey);
    expect(okButton, findsOneWidget);
    await tester.tap(okButton);

    await tester.pumpAndSettle();

    expect(find.text("Strange Error"), findsOneWidget);
  });
}

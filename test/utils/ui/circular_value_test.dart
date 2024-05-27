import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/views/components/async/circular_value.dart";
import "package:proxima/views/components/async/error_alert.dart";
import "package:proxima/views/components/async/logo_progress_indicator.dart";
import "package:proxima/views/components/async/offline_alert.dart";

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
    const fallbackErrorMessage = "Strange Error";

    // Pump a future that throws an error
    await tester.pumpWidget(
      circularValueProvider(
        () async {
          await Future.delayed(Durations.short1);
          throw Exception("Blue moon");
        },
        fallbackBuilder: (context, error) => const Text(fallbackErrorMessage),
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

    expect(find.text(fallbackErrorMessage), findsOneWidget);
  });

  testWidgets("CicularValue should timeout and display offile error message",
      (tester) async {
    const fallbackMessage = "fake retry button";

    // Pump a future that will timeout
    await tester.pumpWidget(
      circularValueProvider(
        () async {
          await Future.delayed(
            CircularValue.offlineTimeout + const Duration(seconds: 5),
          );
          return 1;
        },
        fallbackBuilder: (context, error) => const Text(fallbackMessage),
      ),
    );

    await tester.pumpAndSettle(CircularValue.offlineTimeout + Durations.short1);

    // Expect to find the offline alert popup dialog
    expect(find.byType(OfflineAlert), findsOneWidget);

    // Expect to find the offline error message
    expect(find.textContaining(OfflineAlert.errorMessage), findsOneWidget);

    // Click on diaglog dissmiss ok button
    final okButton = find.byKey(OfflineAlert.okButtonKey);
    expect(okButton, findsOneWidget);
    await tester.tap(okButton);

    await tester.pumpAndSettle();

    expect(find.text(fallbackMessage), findsOneWidget);
  });
}

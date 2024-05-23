import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/views/components/async/error_refresh_page.dart";

void main() {
  testWidgets(
      "ErrorRefreshPage should show the correct text and have a refresh button",
      (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ErrorRefreshPage(
          onRefresh: () {},
        ),
      ),
    );

    expect(find.text("An error occurred"), findsOneWidget);
    expect(find.byKey(ErrorRefreshPage.refreshButtonKey), findsOneWidget);
  });

  testWidgets("Refresh button calls callback", (
    tester,
  ) async {
    var called = false;
    await tester.pumpWidget(
      MaterialApp(
        home: ErrorRefreshPage(
          onRefresh: () {
            called = true;
          },
        ),
      ),
    );

    await tester.tap(find.byKey(ErrorRefreshPage.refreshButtonKey));
    await tester.pumpAndSettle();
    expect(called, isTrue);
  });
}

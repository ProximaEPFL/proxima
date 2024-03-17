import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/main.dart";
import "package:proxima/views/components/todo_view.dart";
import "package:proxima/views/routes/overview.dart";
import "package:proxima/views/routes/todo_edit_page.dart";

Widget appFrom(Widget wut) {
  return ProviderScope(child: MaterialApp(home: wut));
}

void main() {
  testWidgets("Overview correctly displays first element", (tester) async {
    await tester.pumpWidget(appFrom(const OverviewPage()));
    await tester.pumpAndSettle();

    expect(find.text("hey"), findsOneWidget);
    expect(find.textContaining(DateTime.now().year.toString()), findsOneWidget);
  });

  group("Full app testing", () {
    testWidgets("Create a new Todo", (tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.text("hey"), findsOneWidget);

      final fab = find.byKey(OverviewPage.addKey);

      expect(fab, findsOneWidget);

      await tester.tap(fab);
      await tester.pumpAndSettle();

      final delete = find.byKey(TodoEditPage.deleteKey);
      await tester.tap(delete);
      await tester.pumpAndSettle();

      final list = find.byKey(OverviewPage.listKey);
      final todos = find.descendant(of: list, matching: find.byType(TodoView));
      expect(todos, findsOneWidget);

      final edit =
          find.descendant(of: todos, matching: find.byType(IconButton));
      await tester.tap(edit);
      await tester.pumpAndSettle();

      expect(find.byType(TodoEditPage), findsOneWidget);
    });
  });
}

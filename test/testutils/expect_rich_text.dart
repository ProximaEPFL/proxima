import "package:flutter/widgets.dart";
import "package:flutter_test/flutter_test.dart";

void expectOneRichText(String text) {
  // The parameter findRichText from find.text does not appear to work
  // so I'm forced to use this uglier method.
  expect(
    find.byWidgetPredicate(
      (widget) =>
          widget is RichText && widget.text.toPlainText().contains(text),
    ),
    findsOneWidget,
  );
}

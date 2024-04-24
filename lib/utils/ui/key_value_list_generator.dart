import "package:flutter/material.dart";

/// A class to generate a [RichText] containing a list of key-value pairs.
class KeyValueListGenerator {
  List<TextSpan> content = [];
  TextStyle? style;

  /// Creates a new instance of [KeyValueListGenerator].
  /// The [style] is the style of the text. [RichText] does not
  /// inherit its parent style by default. If you want to inherit
  /// the parent style, you can set the [style] to [DefaultTextStyle.of(context).style].
  /// If you want to use the default style, you can set the [style] to `null`.
  KeyValueListGenerator({required this.style});

  /// Adds a new line to the text, if its content is not empty.
  KeyValueListGenerator _newLine() {
    if (content.isNotEmpty) {
      content.add(const TextSpan(text: "\n"));
    }
    return this;
  }

  /// Adds a new [key]-[value] pair to the text. The value will be bold.
  KeyValueListGenerator addPair(String key, String value) {
    _newLine();
    content.add(TextSpan(text: "$key: ", style: style));
    content.add(
      TextSpan(
        text: value,
        style: style?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
    return this;
  }

  /// Adds a new [line] to the text.
  KeyValueListGenerator addLine(String line) {
    _newLine();
    content.add(TextSpan(text: line));
    return this;
  }

  /// Generates the created [RichText] widget.
  Widget generate() {
    return RichText(
      text: TextSpan(
        children: content,
      ),
    );
  }
}

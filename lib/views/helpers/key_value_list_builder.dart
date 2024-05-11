import "package:flutter/material.dart";

/// A class to generate a [RichText] containing a list of key-value pairs.
/// Uses the Builder design pattern (see https://en.wikipedia.org/wiki/Builder_pattern)
class KeyValueListBuilder {
  List<TextSpan> content = [];
  TextStyle? style;

  /// Creates a new instance of [KeyValueListBuilder].
  /// The [style] is the style of the text. [RichText] does not
  /// inherit its parent style by default. If you want to inherit
  /// the parent style, you can set the [style] to [DefaultTextStyle.of(context).style].
  /// If you want to use the default style, you can set the [style] to `null`.
  KeyValueListBuilder({required this.style});

  /// Adds a new line to the text, if its content is not empty.
  KeyValueListBuilder _newLine() {
    if (content.isNotEmpty) {
      content.add(const TextSpan(text: "\n"));
    }
    return this;
  }

  /// Adds a new [key]-[value] pair to the text. The value will be bold.
  KeyValueListBuilder addPair(String key, String value) {
    _newLine();
    content.add(TextSpan(text: "$key: ", style: style));
    content.add(
      TextSpan(
        text: value,
        style: style?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
    return this;
  }

  /// Adds a new [line] to the text.
  KeyValueListBuilder addLine(String line) {
    _newLine();
    content.add(TextSpan(text: line));
    return this;
  }

  /// Generates the created [RichText] widget.
  Widget generate() {
    return RichText(
      text: TextSpan(
        children: content,
        style: style,
      ),
    );
  }
}

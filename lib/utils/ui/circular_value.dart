import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/utils/ui/error_alert.dart";

/// Utilitiy widget used to display a [CircularProgressIndicator] while waiting
/// for an [AsyncValue] to complete; and another widget once the data resolves.
/// In case the data resolves to an error, an [ErrorAlert] dialog is shown, and
/// a fallback widget is displayed. The default fallback widget is empty, but it
/// can be overridden.
class CircularValue<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context, Object error) fallbackBuilder;

  /// Tag to be placed inside of an error message to display the
  /// message directly instead of the widget.
  /// Does not trigger a pop up dialog. Useful for debug error messages
  /// that should never occur for a real user of the app (not front facing errors).
  static const debugErrorTag = "DEBUG";

  /// Constructor for the [CircularValue] widget.
  /// [value] is the underlying [AsyncValue] that controls the display.
  /// [builder] is the widget to display when the [value] is [AsyncValue.data].
  /// [fallbackBuilder] is the widget to display when the [value] is [AsyncValue.error].
  /// The default [fallbackBuilder] is an empty [SizedBox].
  const CircularValue({
    super.key,
    required this.value,
    required this.builder,
    this.fallbackBuilder = _defaultFallback,
  });

  static Widget _defaultFallback(BuildContext context, Object error) =>
      const SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (data) => builder(context, data),
      error: (error, _) {
        final errorText = error.toString();

        if (errorText.contains(debugErrorTag)) {
          return Text(errorText);
        }

        final dialog = ErrorAlert(error: error);
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          showDialog(context: context, builder: dialog.build);
        });

        return fallbackBuilder(context, error);
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

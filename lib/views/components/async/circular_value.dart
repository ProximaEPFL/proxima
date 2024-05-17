import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/components/async/error_alert.dart";
import "package:proxima/views/helpers/types.dart";

/// Utilitiy widget used to display a [CircularProgressIndicator] while waiting
/// for an [AsyncValue] to complete; and another widget once the data resolves.
/// In case the data resolves to an error, an [ErrorAlert] dialog is shown, and
/// a fallback widget is displayed. The default fallback widget is empty, but it
/// can be overridden.
class CircularValue<T> extends HookWidget {
  final Future<FutureRes<T, Object?>> future;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context, Object error) fallbackBuilder;

  /// Tag to be placed inside of an error message to display the
  /// message directly instead of the widget.
  /// Does not trigger a pop up dialog. Useful for debug error messages
  /// that should never occur for a real user of the app (not front facing errors).
  static const debugErrorTag = "DEBUG";

  /// Time after what the circular value will display an error message instead
  /// of spinning for ever.
  static const offlineTimeout = Duration(seconds: 6);

  /// Constructor for the [CircularValue] widget.
  /// [value] is the underlying [AsyncValue] that controls the display.
  /// [builder] is the widget to display when the [value] is [AsyncValue.data].
  /// [fallbackBuilder] is the widget to display when the [value] is [AsyncValue.error].
  /// The default [fallbackBuilder] is an empty [SizedBox].
  CircularValue({
    super.key,
    required Future<FutureRes<T, Object?>> future,
    required this.builder,
    this.fallbackBuilder = _defaultFallback,
  }) : future = future
            .timeout(offlineTimeout)
            // TODO handle timeout properly
            .onError((error, stackTrace) => FutureRes.error("timeout"));

  static Widget _defaultFallback(BuildContext _, Object __) =>
      const SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    final showedError = useState(false);

    useEffect(
      () {
        future.then((value) {
          if (value.isError) {
            showedError.value = false;
          }

          return future;
        });
        return null;
      },
      [future],
    );

    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData && !snapshot.data!.isError) {
          final data = snapshot.data!;
          return builder(context, data.value as T);
        } else if (snapshot.hasError ||
            (snapshot.hasData && snapshot.data!.isError)) {
          final error = snapshot.error ?? snapshot.data!.error!;

          final errorText = error.toString();

          if (errorText.contains(debugErrorTag)) {
            return Text(errorText);
          }

          if (!showedError.value) {
            final dialog = ErrorAlert(error: error);

            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              if (context.mounted) {
                showedError.value = true;
              }

              showDialog(context: context, builder: (context) => dialog);
            });
          }

          return fallbackBuilder(context, error);
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

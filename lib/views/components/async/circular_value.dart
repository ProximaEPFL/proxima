import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/components/async/error_alert.dart";
import "package:proxima/views/components/async/logo_progress_indicator.dart";
import "package:proxima/views/components/async/offline_alert.dart";
import "package:proxima/views/helpers/types.dart";

/// Utilitiy widget used to display a [LogoProgressIndicator] while waiting
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

  /// Tag to be placed inside of an error message to inform
  /// the circular value of an TIMEOUT (due to bad internet connectivity).
  /// **Note**: the [debugErrorTag] takes precedence over [timeoutErrorTag].
  static const timeoutErrorTag = "TIMEOUT";

  /// Time after what the circular value will display an error message instead
  /// of spinning for ever.
  static const offlineTimeout = Duration(seconds: 8);

  static Widget _defaultFallback(BuildContext _, Object __) =>
      const SizedBox.shrink();

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
            .onError((error, stackTrace) => FutureRes.error(timeoutErrorTag));

  @override
  Widget build(BuildContext context) {
    // Avoids showing the error dialog twice
    final showedError = useState(false);

    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        const loading = Center(
          child: LogoProgressIndicator(),
        );

        final data = snapshot.data;

        // Loading state
        if (snapshot.connectionState != ConnectionState.done) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if (context.mounted) {
              showedError.value = false;
            }
          });

          return loading;
        }

        // Recieved some valid data which isn't an error (proceed normaly, call builder)
        if (data != null && !data.isError) {
          return builder(context, data.value as T);
        }

        // Future errored or recieved data which is an error
        if (snapshot.hasError || (data != null && data.isError)) {
          final error = snapshot.error ?? data!.error!;

          final errorText = error.toString();

          if (errorText.contains(debugErrorTag)) {
            return Text(errorText);
          }

          if (!showedError.value) {
            final isTimeout = errorText.contains(timeoutErrorTag);

            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              if (context.mounted) {
                showedError.value = true;
              }

              final dialog = isTimeout
                  ? const OfflineAlert()
                  : ErrorAlert(
                      error: error,
                    );

              showDialog(context: context, builder: (context) => dialog);
            });
          }

          // Use the fallback builder to display alternative error widget
          return fallbackBuilder(context, error);
        }

        // Should never reach here, display loading just in case
        return loading;
      },
    );
  }
}

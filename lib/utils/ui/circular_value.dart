import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/utils/ui/error_alert.dart";

/// Utilitiy widget used to display a [CircularProgressIndicator] while waiting
/// for an [AsyncValue] to complete; and another widget once the data resolves.
class CircularValue<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context, Object error) fallbackBuilder;

  static Widget _defaultFallback(BuildContext context, Object error) =>
      const SizedBox.shrink();

  const CircularValue({
    super.key,
    required this.value,
    required this.builder,
    this.fallbackBuilder = _defaultFallback,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (data) => builder(context, data),
      error: (error, _) {
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

import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

/// Utilitiy widget used to display a [CircularProgressIndicator] while waiting
/// for an [AsyncValue] to complete; and another widget once the data resolves.
class CircularValue<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) builder;

  const CircularValue({
    super.key,
    required this.value,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return value.maybeWhen(
      data: (data) => builder(context, data),
      orElse: () {
        return const Expanded(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

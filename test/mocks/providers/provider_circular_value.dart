import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/components/async/circular_value.dart";
import "package:proxima/views/helpers/types/result.dart";

Widget _defaultBuilder(BuildContext context, int value) {
  return const Text("Completed");
}

ProviderScope circularValueProvider(
  Future<int> Function() future, {
  Widget Function(BuildContext, int)? builder,
  Widget Function(BuildContext, Object)? fallbackBuilder,
}) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: CircularValue(
          future: future().mapRes(),
          builder: builder ?? _defaultBuilder,
          fallbackBuilder: fallbackBuilder ?? CircularValue.defaultFallback,
        ),
      ),
    ),
  );
}

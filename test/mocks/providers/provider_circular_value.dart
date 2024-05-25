import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/components/async/circular_value.dart";
import "package:proxima/views/helpers/types.dart";

ProviderScope circularValueProvider(
  Future<int> Function() future, [
  Widget Function(BuildContext, Object)? fallbackBuilder,
]) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: CircularValue(
          future: future().mapRes(),
          builder: (context, data) => const Text("Completed"),
          fallbackBuilder: fallbackBuilder ?? CircularValue.defaultFallback,
        ),
      ),
    ),
  );
}

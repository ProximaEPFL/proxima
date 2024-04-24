import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/utils/ui/circular_value.dart";

ProviderScope circularValueProvider(AsyncValue<void> value) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: CircularValue(
          value: value,
          builder: (context, data) => const Text("Completed"),
          fallbackBuilder: (context, error) => const Text("Strange Error"),
        ),
      ),
    ),
  );
}

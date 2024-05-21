import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/map_pin_details.dart";
import "package:proxima/viewmodels/map/map_pin_view_model.dart";

import "../data/map_pin.dart";

// A mock implementation of the [MapPinViewModel] class.
class MockPinViewModel extends AutoDisposeAsyncNotifier<List<MapPinDetails>>
    implements MapPinViewModel {
  final Future<List<MapPinDetails>> Function() _build;
  final Function(BuildContext context) _setContext;

  MockPinViewModel({
    Future<List<MapPinDetails>> Function()? build,
    Function(BuildContext)? setContext,
  })  : _build = build ?? (() async => List.empty()),
        _setContext = setContext ?? ((_) => {});

  @override
  Future<List<MapPinDetails>> build() => _build();

  @override
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  @override
  void setContext(BuildContext context) => _setContext(context);

  @override
  BuildContext? context;
}

final mockPinViewModelOverride = mapPinViewModelProvider.overrideWith(
  () => MockPinViewModel(
    build: () async => MapPinGenerator.generateMapPins(5),
  ),
);

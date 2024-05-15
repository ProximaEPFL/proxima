import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/map_pin_details.dart";
import "package:proxima/viewmodels/map/map_pin_view_model.dart";

import "../data/map_pin.dart";

// A mock implementation of the [MapPinViewModel] class.
class MockPinViewModel extends AsyncNotifier<List<MapPinDetails>>
    implements MapPinViewModel {
  final Future<List<MapPinDetails>> Function() _build;

  MockPinViewModel({
    Future<List<MapPinDetails>> Function()? build,
  }) : _build = build ?? (() async => List.empty());

  @override
  Future<List<MapPinDetails>> build() => _build();
}

final mockPinViewModelOverride = mapPinViewModelProvider.overrideWith(
  () => MockPinViewModel(
    build: () async => MapPinGenerator.generateMapPins(5),
  ),
);

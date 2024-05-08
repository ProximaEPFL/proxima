import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/map_pin.dart";
import "package:proxima/viewmodels/map_pin_view_model.dart";

import "../data/map_pin.dart";

class MockPinViewModel extends AsyncNotifier<List<MapPin>>
    implements MapPinViewModel {
  final Future<List<MapPin>> Function() _build;

  MockPinViewModel({
    Future<List<MapPin>> Function()? build,
  }) : _build = build ?? (() async => List.empty());

  @override
  Future<List<MapPin>> build() => _build();
}

final mockPinViewModelOverride = mapPinProvider.overrideWith(
  () => MockPinViewModel(
    build: () async => MapPinGenerator.generateMapPins(5),
  ),
);

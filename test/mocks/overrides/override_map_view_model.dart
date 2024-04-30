import "package:flutter_test/flutter_test.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/map_info.dart";
import "package:proxima/viewmodels/map_view_model.dart";

class MockMapViewModel extends AsyncNotifier<MapInfo> implements MapViewModel {
  final Future<MapInfo> Function() _build;
  final Future<void> Function() _onRefresh;
  final Future<void> Function(LatLng) _animateCamera;
  final void Function(GoogleMapController) _onMapCreated;

  MockMapViewModel({
    Future<MapInfo> Function()? build,
    Future<void> Function()? onRefresh,
    Future<void> Function(LatLng)? animateCamera,
    void Function(GoogleMapController)? onMapCreated,
  })  : _build = build ??
            (() async => throw Exception("Location services are disabled.")),
        _onRefresh = onRefresh ?? (() async {}),
        _animateCamera = animateCamera ?? ((_) async {}),
        _onMapCreated = onMapCreated ?? ((_) {});

  @override
  Future<MapInfo> build() => _build();

  @override
  Future<void> refresh() => _onRefresh();

  @override
  Future<void> animateCamera(LatLng target) => _animateCamera(target);

  @override
  void onMapCreated(GoogleMapController controller) =>
      _onMapCreated(controller);
}

final mockNoGPSMapViewModelOverride = [
  mapProvider.overrideWith(() => MockMapViewModel()),
];

import "dart:async";

import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/map_details.dart";
import "package:proxima/viewmodels/map_view_model.dart";

class MockMapViewModel extends AutoDisposeAsyncNotifier<MapDetails>
    implements MapViewModel {
  final Future<MapDetails> Function() _build;
  final Future<void> Function() _onRefresh;
  final void Function(GoogleMapController) _onMapCreated;
  final Set<Circle> _circles;
  final Future<void> Function(LatLng) _redrawCircle;
  final Completer<GoogleMapController> _mapController;

  MockMapViewModel({
    Future<MapDetails> Function()? build,
    Future<void> Function()? onRefresh,
    Future<void> Function(LatLng)? animateCamera,
    void Function(GoogleMapController)? onMapCreated,
    Future<void> Function(LatLng)? redrawCircle,
    Set<Circle>? circles,
    Completer<GoogleMapController>? mapController,
  })  : _build = build ??
            (() async => throw Exception("Location services are disabled.")),
        _onRefresh = onRefresh ?? (() async {}),
        _onMapCreated = onMapCreated ?? ((_) {}),
        _circles = circles ?? {},
        _redrawCircle = redrawCircle ?? ((_) async {}),
        _mapController = mapController ?? Completer();

  @override
  Future<MapDetails> build() => _build();

  @override
  Future<void> refresh() => _onRefresh();

  @override
  void onMapCreated(GoogleMapController controller) =>
      _onMapCreated(controller);

  @override
  Set<Circle> get circles => _circles;

  @override
  Future<void> redrawCircle(LatLng target) => _redrawCircle(target);

  @override
  Completer<GoogleMapController> get mapController => _mapController;
}

final mockNoGPSMapViewModelOverride = [
  mapViewModelProvider.overrideWith(() => MockMapViewModel()),
];

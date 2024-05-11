import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/home/content/map/map_screen.dart";

import "../overrides/override_map_view_model.dart";
import "../overrides/override_pin_view_model.dart";

const mapPage = MaterialApp(
  onGenerateRoute: generateRoute,
  title: "Map page",
  home: MapScreen(),
);

ProviderScope newMapPageProvider(
  GeolocationService geoLocationService,
  Set<GeoPoint?> geoPoints,
) {
  return ProviderScope(
    overrides: [
      geolocationServiceProvider.overrideWithValue(geoLocationService),
      livePositionStreamProvider
          .overrideWith((ref) => Stream.fromIterable(geoPoints)),
    ],
    child: mapPage,
  );
}

ProviderScope newMapPageNoGPS() {
  return ProviderScope(
    overrides: mockNoGPSMapViewModelOverride,
    child: mapPage,
  );
}

ProviderScope newMapPageWithPins(
  GeolocationService geoLocationService,
) {
  return ProviderScope(
    overrides: [
      geolocationServiceProvider.overrideWithValue(geoLocationService),
      mockPinViewModelOverride,
    ],
    child: mapPage,
  );
}

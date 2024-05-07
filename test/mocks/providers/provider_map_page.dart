import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/viewmodels/map_pin_view_model.dart";
import "package:proxima/views/home_content/map/map_screen.dart";
import "package:proxima/views/navigation/routes.dart";

import "../data/map_pin.dart";
import "../overrides/override_map_view_model.dart";

const mapPage = MaterialApp(
  onGenerateRoute: generateRoute,
  title: "Map page",
  home: MapScreen(),
);

ProviderScope newMapPageProvider(
  GeoLocationService geoLocationService,
  Set<GeoPoint?> geoPoints,
) {
  return ProviderScope(
    overrides: [
      geoLocationServiceProvider.overrideWithValue(geoLocationService),
      liveLocationServiceProvider
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
  GeoLocationService geoLocationService,
) {
  return ProviderScope(
    overrides: [
      geoLocationServiceProvider.overrideWithValue(geoLocationService),
      mapPinProvider.overrideWithValue(testPins),
    ],
    child: mapPage,
  );
}

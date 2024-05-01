import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/views/home_content/map/map_screen.dart";
import "package:proxima/views/navigation/routes.dart";

import "../overrides/override_map_view_model.dart";

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
    child: const MaterialApp(
      onGenerateRoute: generateRoute,
      title: "Map page",
      home: MapScreen(),
    ),
  );
}

ProviderScope newMapPageNoGPS() {
  return ProviderScope(
    overrides: mockNoGPSMapViewModelOverride,
    child: const MaterialApp(
      onGenerateRoute: generateRoute,
      title: "Map page",
      home: MapScreen(),
    ),
  );
}

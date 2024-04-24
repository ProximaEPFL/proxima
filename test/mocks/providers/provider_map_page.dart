import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/views/home_content/map_feed/map_screen.dart";
import "package:proxima/views/navigation/routes.dart";

import "../services/mock_geo_location_service.dart";

ProviderScope newMapPageProvider(
  MockGeoLocationService geoLocationService,
) {
  return ProviderScope(
    overrides: [
      geoLocationServiceProvider.overrideWithValue(geoLocationService),
    ],
    child: const MaterialApp(
      onGenerateRoute: generateRoute,
      title: "Map page",
      home: MapScreen(),
    ),
  );
}

import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/home_content/map/map_screen.dart";
import "package:proxima/views/navigation/routes.dart";

import "../overrides/override_map_view_model.dart";

ProviderScope newMapPageProvider() {
  return const ProviderScope(
    child: MaterialApp(
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

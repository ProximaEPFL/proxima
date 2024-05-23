import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/home/content/map/map_screen.dart";

import "../overrides/override_map_view_model.dart";
import "../overrides/override_pin_view_model.dart";
import "../services/mock_user_repository_service.dart";

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

ProviderScope newMapPageWithPinsRealMapPinViewmodel(
  GeolocationService geoLocationService,
  FakeFirebaseFirestore fakeFireStore,
  UserIdFirestore testingUserFirestoreId,
  MockUserRepositoryService userRepositoryService,
) {
  return ProviderScope(
    overrides: [
      geolocationServiceProvider.overrideWithValue(geoLocationService),
      firestoreProvider.overrideWithValue(fakeFireStore),
      loggedInUserIdProvider.overrideWithValue(testingUserFirestoreId),
      userRepositoryServiceProvider.overrideWithValue(userRepositoryService),
    ],
    child: mapPage,
  );
}

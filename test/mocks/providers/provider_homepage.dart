import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/home/home_page.dart";

import "../overrides/override_auth_providers.dart";
import "../overrides/override_challenges_view_model.dart";
import "../overrides/override_home_view_model.dart";
import "../services/mock_geo_location_service.dart";

const homePageApp = MaterialApp(
  onGenerateRoute: generateRoute,
  home: HomePage(),
);

final emptyHomePageProvider = ProviderScope(
  overrides: mockEmptyHomeViewModelOverride,
  child: homePageApp,
);

final nonEmptyHomePageProvider = ProviderScope(
  overrides: [...mockNonEmptyHomeViewModelOverride, ...mockChallengeOverride],
  child: homePageApp,
);

final loadingHomePageProvider = ProviderScope(
  overrides: mockLoadingHomeViewModelOverride,
  child: homePageApp,
);

ProviderScope homePageFakeFirestoreProvider(
  FakeFirebaseFirestore firestore,
  MockGeoLocationService geoLocationService,
) {
  return ProviderScope(
    overrides: [
      ...loggedInUserOverrides,
      firestoreProvider.overrideWithValue(firestore),
      geoLocationServiceProvider.overrideWithValue(geoLocationService),
    ],
    child: homePageApp,
  );
}

ProviderScope emptyHomePageProviderGPS(
    MockGeoLocationService geoLocationService) {
  return ProviderScope(
    overrides: [
      ...mockEmptyHomeViewModelOverride,
      geoLocationServiceProvider.overrideWithValue(geoLocationService),
    ],
    child: homePageApp,
  );
}

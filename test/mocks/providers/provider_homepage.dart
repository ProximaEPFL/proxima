import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/home/home_page.dart";

import "../overrides/override_auth_providers.dart";
import "../overrides/override_comments_view_model.dart";
import "../overrides/override_dynamic_user_avatar_view_model.dart";
import "../overrides/override_firestore.dart";
import "../overrides/override_posts_feed_view_model.dart";
import "../services/mock_geo_location_service.dart";

const homePageApp = MaterialApp(
  onGenerateRoute: generateRoute,
  home: HomePage(),
);

final emptyHomePageProvider = ProviderScope(
  overrides: [
    ...mockEmptyHomeViewModelOverride,
    ...mockDynamicUserAvatarViewModelEmptyDisplayNameOverride,
  ],
  child: homePageApp,
);

final nonEmptyHomePageProvider = ProviderScope(
  overrides: [
    ...mockNonEmptyHomeViewModelOverride,
    ...mockNonEmptyCommentViewModelOverride,
    ...mockDynamicUserAvatarViewModelEmptyDisplayNameOverride,
    ...firebaseMocksOverrides,
    ...loggedInUserOverrides,
  ],
  child: homePageApp,
);

final loadingHomePageProvider = ProviderScope(
  overrides: mockLoadingHomeViewModelOverride,
  child: homePageApp,
);

ProviderScope _homePageFakeFirestoreProviderAddOverrides(
  FakeFirebaseFirestore firestore,
  MockGeolocationService geoLocationService, {
  List<Override> additionalOverrides = const [],
}) {
  return ProviderScope(
    overrides: [
      ...additionalOverrides,
      ...loggedInUserOverrides,
      ...mockDynamicUserAvatarViewModelEmptyDisplayNameOverride,
      firestoreProvider.overrideWithValue(firestore),
      geolocationServiceProvider.overrideWithValue(geoLocationService),
    ],
    child: homePageApp,
  );
}

/// This provider is used to test the home page with a fake [firestore]
/// and a fake [geoLocationService].
ProviderScope homePageFakeFirestoreProvider(
  FakeFirebaseFirestore firestore,
  MockGeolocationService geoLocationService,
) =>
    _homePageFakeFirestoreProviderAddOverrides(firestore, geoLocationService);

/// This provider is used to test the home page with a fake [firestore]
/// and a fake [geoLocationService], while mocking the view-model of the
/// home page with a non-empty view-model. This is useful if the database
/// has posts which user do not exist in the database, and that the goal
/// of the test is not to test the feed view-model.
ProviderScope homePageFakeFirestoreProviderMockHomeVM(
  FakeFirebaseFirestore firestore,
  MockGeolocationService geoLocationService,
) =>
    _homePageFakeFirestoreProviderAddOverrides(
      firestore,
      geoLocationService,
      additionalOverrides: mockNonEmptyHomeViewModelOverride,
    );

ProviderScope emptyHomePageProviderGPS(
  MockGeolocationService geoLocationService,
) {
  return ProviderScope(
    overrides: [
      ...mockDynamicUserAvatarViewModelTestLoginUserOverride,
      ...mockEmptyHomeViewModelOverride,
      geolocationServiceProvider.overrideWithValue(geoLocationService),
    ],
    child: homePageApp,
  );
}

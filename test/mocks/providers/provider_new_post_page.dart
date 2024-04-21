import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/views/pages/new_post/new_post_page.dart";

import "../../services/firestore/testing_firestore_provider.dart";
import "../data/mock_firestore_user.dart";
import "../services/mock_geo_location_service.dart";
import "../services/mock_post_repository_service.dart";

ProviderScope newPostPageProvider(
  MockPostRepositoryService postRepository,
  MockGeoLocationService geoLocationService,
) {
  return ProviderScope(
    overrides: [
      ...firebaseMocksOverrides,
      postRepositoryProvider.overrideWithValue(postRepository),
      geoLocationServiceProvider.overrideWithValue(geoLocationService),
      uidProvider.overrideWithValue(testingUserFirestoreId),
    ],
    child: const MaterialApp(
      title: "New post page",
      home: NewPostPage(),
    ),
  );
}

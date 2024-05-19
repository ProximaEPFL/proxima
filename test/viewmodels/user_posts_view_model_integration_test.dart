import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/viewmodels/user_posts_view_model.dart";

import "../mocks/data/firestore_post.dart";
import "../mocks/data/firestore_user.dart";
import "../mocks/data/geopoint.dart";
import "../mocks/services/mock_geo_location_service.dart";

void main() {
  group("Testing user posts viewmodel", () {
    late FirebaseFirestore firestore;
    late FirestorePostGenerator postGenerator;

    late ProviderContainer container;
    late GeoPoint userPosition;
    late UserIdFirestore userId;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      postGenerator = FirestorePostGenerator();
      userPosition = userPosition0;
      userId = testingUserFirestoreId;

      final mockGeoLocationService = MockGeolocationService();
      when(mockGeoLocationService.getCurrentPosition()).thenAnswer(
        (_) async => userPosition,
      );

      container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(firestore),
          geolocationServiceProvider.overrideWithValue(mockGeoLocationService),
          loggedInUserIdProvider.overrideWithValue(userId),
        ],
      );
    });

    group("Ordering test", () {
      test("User Posts are ordered from latest to oldest", () async {
        const nbPosts = 50;

        // Generate and add posts for the user
        final firestorePosts = List.generate(
          nbPosts,
          (_) => postGenerator.createUserPost(userId, userPosition),
        );
        await setPostsFirestore(firestorePosts, firestore);

        // Get the user posts
        final userPosts =
            await container.read(userPostsViewModelProvider.future);
        expect(userPosts.length, nbPosts);

        // Check that the posts are ordered from latest to oldest
        for (var i = 0; i < nbPosts - 1; i++) {
          expect(
            userPosts[i].publicationTime.microsecondsSinceEpoch,
            greaterThanOrEqualTo(
              userPosts[i + 1].publicationTime.microsecondsSinceEpoch,
            ),
          );
        }
      });
    });
  });
}

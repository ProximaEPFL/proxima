import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/services/sorting/post/post_sort_option.dart";
import "package:proxima/services/sorting/post/post_sorting_service.dart";
import "package:proxima/viewmodels/feed_sort_options_view_model.dart";
import "package:proxima/viewmodels/home_view_model.dart";
import "package:proxima/views/components/options/feed/feed_sort_option_chips.dart";
import "package:proxima/views/pages/home/home_page.dart";

import "../../../mocks/data/firestore_post.dart";
import "../../../mocks/data/firestore_user.dart";
import "../../../mocks/data/geopoint.dart";
import "../../../mocks/providers/provider_homepage.dart";
import "../../../mocks/services/mock_geo_location_service.dart";

void main() {
  const position = userPosition0;

  late FakeFirebaseFirestore firestore;
  late MockGeoLocationService geoLocationService;
  late ProviderScope homepageWidget;
  late List<PostFirestore> posts;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    geoLocationService = MockGeoLocationService();
    homepageWidget = homePageFakeFirestoreProvider(
      firestore,
      geoLocationService,
    );

    when(geoLocationService.getCurrentPosition()).thenAnswer(
      (_) => Future.value(position),
    );

    final locations = GeoPointGenerator.generatePositions(position, 20, 0);

    final postGenerator = FirestorePostGenerator();
    posts = postGenerator.generatePostsAtDifferentLocations(
      locations,
    );
    await setPostsFirestore(posts, firestore);

    final users = FirestoreUserGenerator.generateUserFirestoreWithId(
      posts.map((post) => post.data.ownerId).toList(),
    );
    await setUsersFirestore(firestore, users);
  });

  group("Sort options", () {
    testWidgets(
      "Pushing the sort option button sets the correct order to the posts",
      (tester) async {
        await tester.pumpWidget(homepageWidget);
        await tester.pumpAndSettle();

        final element = tester.element(find.byType(HomePage));
        final container = ProviderScope.containerOf(element);

        final sortingService = PostSortingService();

        // Twice to be sure there is some navigation and it is not just the default
        // sorting option that is set.
        for (int i = 0; i < 2; ++i) {
          for (final sortOption in PostSortOption.values) {
            final sortOptionChip =
                find.byKey(FeedSortOptionChips.optionChipKeys[sortOption]!);
            expect(sortOptionChip, findsOneWidget);

            await tester.tap(sortOptionChip);
            await tester.pumpAndSettle();

            // Expect to be in the correct state
            expect(container.read(feedSortOptionsProvider), equals(sortOption));

            // Expect the list to be in correct order
            // We compare the post id values for an easier debugging.
            final actualPostsOverview = await container.read(
              postOverviewProvider.future,
            );
            final actualPostsId = actualPostsOverview.map(
              (post) => post.postId.value,
            );

            final sortedPosts = sortingService.sort(
              posts,
              sortOption,
              position,
            );
            final expectedPostId = sortedPosts.map((post) => post.id.value);
            expect(actualPostsId, equals(expectedPostId));
          }
        }
      },
    );
  });
}

import "package:collection/collection.dart";
import "package:flutter_test/flutter_test.dart";
import "package:geolocator/geolocator.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/services/sorting/post_sort_option.dart";
import "package:proxima/services/sorting/post_sorting_service.dart";

import "../../mocks/data/firestore_post.dart";
import "../../mocks/data/geopoint.dart";

void expectSorted(Iterable<double> iterable, bool ascending) {
  final factor = ascending ? 1 : -1;
  expect(iterable.isSorted((a, b) => factor * a.compareTo(b)), true);
}

void main() {
  final sortingService = PostSortingService();

  final postGenerator = FirestorePostGenerator();
  final positions = GeoPointGenerator.generatePositions(userPosition0, 10, 0);
  final posts = postGenerator.generatePostsAtDifferentLocations(positions);

  group("Score functions are meaningful", () {
    double dayDifference(PostFirestore referencePost, PostFirestore post) {
      final referenceDate = referencePost.data.publicationTime.toDate();
      final date = post.data.publicationTime.toDate();

      // Need to get the result in miliseconds to have a good precision
      return referenceDate.difference(date).inMilliseconds /
          (1000.0 * 60.0 * 60.0 * 24.0);
    }

    double upvoteDifference(PostFirestore referencePost, PostFirestore post) {
      final referenceScore = referencePost.data.voteScore;
      final score = post.data.voteScore;

      return (referenceScore - score).toDouble();
    }

    double positionDifference(PostFirestore referencePost, PostFirestore post) {
      final referencePosition = referencePost.location.geoPoint;
      final position = post.location.geoPoint;

      return Geolocator.distanceBetween(
        referencePosition.latitude,
        referencePosition.longitude,
        position.latitude,
        position.longitude,
      );
    }

    void testOption(
      PostSortOption option,
      String expectedBehaviourStr,
      double Function(PostFirestore, PostFirestore) expectedBehaviour, {
      bool forcePositiveScore = false,
    }) {
      test(
        "${option.name} score $expectedBehaviourStr",
        () {
          final referencePost = postGenerator.generatePostAt(userPosition0);
          final referenceScore =
              option.scoreFunction(referencePost, userPosition0);

          final actualScoreDifference = posts
              .map(
                (post) =>
                    referenceScore - option.scoreFunction(post, userPosition0),
              )
              .map(
                (difference) =>
                    forcePositiveScore ? difference.abs() : difference,
              );

          final expectedScoreDifference = posts.map(
            (post) => expectedBehaviour(referencePost, post),
          );
          expect(actualScoreDifference, expectedScoreDifference);
        },
      );
    }

    testOption(
      PostSortOption.hottest,
      "increases by 1 every upvote, decreases by 1 every day",
      (referencePost, post) =>
          upvoteDifference(referencePost, post) -
          dayDifference(referencePost, post),
    );

    testOption(
      PostSortOption.latest,
      "increases by 1 every every day",
      dayDifference,
    );

    testOption(
      PostSortOption.nearest,
      "decreases by 1 every meter",
      positionDifference,
      forcePositiveScore: true,
    );

    testOption(
      PostSortOption.top,
      "increases by 1 every upvote",
      upvoteDifference,
    );
  });

  group("Empty onTop attribute", () {
    for (final option in PostSortOption.values) {
      test("Correct sort on option ${option.name}", () {
        final sorted = sortingService.sort(
          posts,
          option,
          userPosition0,
        );

        expect(sorted, unorderedEquals(posts));

        final scores = sorted.map(
          (post) => option.scoreFunction(post, userPosition0),
        );
        expectSorted(scores, option.sortIncreasing);
      });
    }
  });

  group("Nonempty onTop attribute", () {
    final positionsToPutOnTop =
        GeoPointGenerator.generatePositions(userPosition0, 5, 0);

    /// The posts that we will ask to put on top, if in the list
    final postsToPutOnTop =
        postGenerator.generatePostsAtDifferentLocations(positionsToPutOnTop);

    /// The posts that will actually be in the list to be sorted
    final existingPostsToPutOnTop = postsToPutOnTop.take(3).toList();

    for (final option in PostSortOption.values) {
      test("Correct sort on option ${option.name}", () {
        final allPosts = posts + existingPostsToPutOnTop;
        allPosts.shuffle();

        final sorted = sortingService.sort(
          allPosts,
          option,
          userPosition0,
          putOnTop: postsToPutOnTop.toSet(),
        );

        // Test for the global structure
        expect(sorted, unorderedEquals(allPosts));
        final top = sorted.take(existingPostsToPutOnTop.length);
        expect(
          top,
          unorderedEquals(existingPostsToPutOnTop),
        );
        final bottom = sorted.skip(existingPostsToPutOnTop.length);
        expect(
          bottom,
          unorderedEquals(posts),
        );

        // Also verify the substructure
        final scoresTop = top.map(
          (post) => option.scoreFunction(post, userPosition0),
        );
        expectSorted(scoresTop, option.sortIncreasing);
        final scoresBottom = bottom.map(
          (post) => option.scoreFunction(post, userPosition0),
        );
        expectSorted(scoresBottom, option.sortIncreasing);
      });
    }
  });
}

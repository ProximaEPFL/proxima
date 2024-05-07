import "package:cloud_firestore/cloud_firestore.dart";
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
  late PostSortingService sortingService;

  late FirestorePostGenerator postGenerator;
  late List<PostFirestore> posts;

  setUp(() {
    sortingService = PostSortingService();

    postGenerator = FirestorePostGenerator();
    final positions = GeoPointGenerator.generatePositions(userPosition0, 10, 0);
    posts = postGenerator.generatePostsAtDifferentLocations(positions);
  });

  group("Score functions are meaningful", () {
    /// Compute the difference between the number of days since creation
    /// of [referencePost] and the one of the [post]. The formula
    /// is (currentDate - referencePostCreation) - (currentDate - postCreation)
    /// = postCreation - referencePostCreation. It therefore does not
    /// depend on the currentDate.
    double dayDifference(PostFirestore referencePost, PostFirestore post) {
      final referenceDate = referencePost.data.publicationTime.toDate();
      final date = post.data.publicationTime.toDate();

      // Need to get the result in miliseconds to have a good precision
      return date.difference(referenceDate).inMilliseconds /
          (1000.0 * 60.0 * 60.0 * 24.0);
    }

    /// Compute the difference between the vote score of the [referencePost]
    /// and the one of the [post].
    double upvoteDifference(PostFirestore referencePost, PostFirestore post) {
      final referenceScore = referencePost.data.voteScore;
      final score = post.data.voteScore;

      return (referenceScore - score).toDouble();
    }

    /// Compute the (always positive) distance between the [referencePost] and the [post].
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

    /// Test the behaviour for [option] with a given [expectedBehaviour].
    /// The expected behaviour can for instance be that a post with 3 more
    /// upvotes should have a score 3 greater. See examples below for more
    /// clarity.
    /// The [expectedBehaviourStr] is used to describe the expected behaviour
    /// in the test name. If [forcePositiveScore] is true, the score difference
    /// will be forced to be positive. This is used for distances for instance
    /// (it matters which post has 3 more upvotes, the order in which the posts
    /// are given matters; it however does not matter for distances).
    void testOption(
      PostSortOption option,
      String expectedBehaviourStr,
      double Function(PostFirestore, PostFirestore) expectedBehaviour, {
      bool forcePositiveScore = false,
    }) {
      test(
        "${option.name} score $expectedBehaviourStr",
        () {
          // The idea of this test is that this referencePost, which a
          // our referential for all scores. For instance, a post which has
          // 3 more upvotes than this one should have a vote score 3 greater.
          final referencePost = postGenerator.generatePostAt(userPosition0);
          final referenceScore =
              option.scoreFunction(referencePost, userPosition0);

          // Get the relative score to the referencePost given by the sorting option.
          final actualScoreDifference = posts
              .map(
                (post) =>
                    referenceScore - option.scoreFunction(post, userPosition0),
              )
              .map(
                (difference) =>
                    forcePositiveScore ? difference.abs() : difference,
              );

          // Get the relative score to the referencePost we should get by
          // applying the expected behaviour. As before, a post which has
          // 3 more upvotes than the referencePost should have a vote score
          // 3 greater.
          final expectedScoreDifference = posts.map(
            (post) => expectedBehaviour(referencePost, post),
          );

          // Those are supposed to be equivalent ways to compute the same
          // thing.
          expect(actualScoreDifference, expectedScoreDifference);
        },
      );
    }

    /// For the option `hottest`, we want that the score increases by 1
    /// every upvote and decreases by 1 every day. Therefore, the expected
    /// behaviour is that the score difference between two posts is the
    /// difference in upvotes (it increases by 1 every times the first post
    /// has 1 more upvote) minus the difference in their creation date (it decreases
    /// by 1 if the first post is published 1 day later).
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

    test("Sort by latest sorts by increasing time since creation", () {
      final sorted = sortingService.sort(
        posts,
        PostSortOption.latest,
        userPosition0,
      );

      final currentTime = Timestamp.now();
      final timesSinceCreation = sorted
          .map(
            (post) =>
                currentTime.millisecondsSinceEpoch -
                post.data.publicationTime.millisecondsSinceEpoch,
          )
          .map((value) => value.toDouble());
      expectSorted(timesSinceCreation, true);
    });

    test("Sort by nearest sorts by increasing distance", () {
      final sorted = sortingService.sort(
        posts,
        PostSortOption.nearest,
        userPosition0,
      );

      final distances = sorted.map((post) {
        final postPos = post.location.geoPoint;
        return Geolocator.distanceBetween(
          postPos.latitude,
          postPos.longitude,
          userPosition0.latitude,
          userPosition0.longitude,
        );
      });
      expectSorted(distances, true);
    });

    test("Sort by top sorts by decreasing upvotes", () {
      final sorted = sortingService.sort(
        posts,
        PostSortOption.top,
        userPosition0,
      );

      final upvotes = sorted.map((post) => post.data.voteScore.toDouble());
      expectSorted(upvotes, false);
    });

    // Sorting by hottest has a less easy to understand behaviour, so there
    // is no such test for it.
  });

  group("Empty onTop attribute", () {
    for (final option in PostSortOption.values) {
      /// Those tests sort a list of post using the [option] and checks
      /// that the scores are sorted in the correct order.
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
    /// The posts that we will ask to put on top, if in the list
    late List<PostFirestore> postsToPutOnTop;

    /// The posts that will actually be in the list to be sorted
    late List<PostFirestore> existingPostsToPutOnTop;

    setUp(() {
      final positionsToPutOnTop =
          GeoPointGenerator.generatePositions(userPosition0, 5, 0);
      postsToPutOnTop =
          postGenerator.generatePostsAtDifferentLocations(positionsToPutOnTop);
      existingPostsToPutOnTop = postsToPutOnTop.take(3).toList();
    });

    /// Those tests sort a list of post using the [option] and checks
    /// that the first posts are the one that were asked to be put on top,
    /// that their scores are sorted in the correct order, and that the
    /// other posts are also sorted in correct order.
    for (final option in PostSortOption.values) {
      test("Correct sort on option ${option.name}", () {
        final allPosts = posts + existingPostsToPutOnTop;
        allPosts.shuffle();

        final sorted = sortingService.sort(
          allPosts,
          option,
          userPosition0,
          putOnTop: postsToPutOnTop.map((post) => (post.id)).toSet(),
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

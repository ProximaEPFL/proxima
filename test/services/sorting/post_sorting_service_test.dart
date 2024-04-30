import "package:flutter_test/flutter_test.dart";
import "package:geolocator/geolocator.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/services/sorting/post_sort_option.dart";

import "../../mocks/data/firestore_post.dart";
import "../../mocks/data/geopoint.dart";

void main() {
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
}

import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/ui/user_post_details.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/viewmodels/user_posts_view_model.dart";

import "../mocks/data/firestore_post.dart";
import "../mocks/data/firestore_user.dart";
import "../mocks/data/geopoint.dart";

void main() {
  group("Testing user posts viewmodel", () {
    late FakeFirebaseFirestore firestore;
    late FirestorePostGenerator postGenerator;

    late ProviderContainer container;
    late GeoPoint userPosition;
    late UserIdFirestore userId;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      postGenerator = FirestorePostGenerator();
      userPosition = userPosition0;
      userId = testingUserFirestoreId;

      container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(firestore),
          loggedInUserIdProvider.overrideWithValue(userId),
        ],
      );
    });

    group("Ordering test", () {
      /// Get the [PostFirestore] from the list [posts] that corresponds
      /// to the [userPostDetails]
      PostFirestore getCorrespondingPost(
        UserPostDetails userPostDetails,
        List<PostFirestore> posts,
      ) {
        // Check that the posts list contains exactly one post with the same id
        final correspondingPosts = posts.where(
          (post) => post.id == userPostDetails.postId,
        );
        expect(correspondingPosts, hasLength(1));

        return correspondingPosts.first;
      }

      test("User Posts are ordered from latest to oldest", () async {
        const nbPosts = 50;

        // Generate and add posts for the user
        final firestorePosts = List.generate(
          nbPosts,
          (_) => postGenerator.createUserPost(userId, userPosition),
        );
        await setPostsFirestore(firestorePosts, firestore);

        // Get the user posts
        final userPostDetails =
            await container.read(userPostsViewModelProvider.future);
        expect(userPostDetails.length, nbPosts);

        // Check that the posts are ordered from latest to oldest
        for (var i = 0; i < nbPosts - 1; i++) {
          final postDetailsAbove = userPostDetails[i];
          final postDetailsBelow = userPostDetails[i + 1];

          final postAbove =
              getCorrespondingPost(postDetailsAbove, firestorePosts);
          final postBelow =
              getCorrespondingPost(postDetailsBelow, firestorePosts);

          expect(
            postAbove.data.publicationTime.microsecondsSinceEpoch,
            greaterThanOrEqualTo(
              postBelow.data.publicationTime.microsecondsSinceEpoch,
            ),
          );
        }
      });
    });

    test("Single user post is exposed correctly", () async {
      // Generate and add a post for the user
      final firestorePost = postGenerator.createUserPost(userId, userPosition);
      await setPostFirestore(firestorePost, firestore);

      // Get the user posts
      final userPostDetails =
          await container.read(userPostsViewModelProvider.future);
      expect(userPostDetails, hasLength(1));

      // Check that the post is exposed correctly
      final userPost = userPostDetails.first;
      expect(userPost.postId, firestorePost.id);
      expect(userPost.title, firestorePost.data.title);
      expect(userPost.description, firestorePost.data.description);
    });
  });
}

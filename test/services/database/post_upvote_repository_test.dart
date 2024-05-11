import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/database/vote/vote_state.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/database/post_upvote_repository_service.dart";
import "package:proxima/services/database/upvote_repository_service.dart";

import "../../mocks/data/geopoint.dart";
import "../../mocks/data/post_data.dart";

void main() {
  late FakeFirebaseFirestore firestore;
  late PostRepositoryService postRepository;
  late UpvoteRepositoryService<PostIdFirestore> postUpvoteRepository;

  Future<int> getUpvoteCount(PostIdFirestore postId) async {
    final post = await postRepository.getPost(postId);
    return post.data.voteScore;
  }

  final postData = PostDataGenerator().emptyPost;
  const postLocation = userPosition1;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    postRepository = PostRepositoryService(firestore: firestore);

    final container = ProviderContainer(
      overrides: [
        firestoreProvider.overrideWithValue(firestore),
        postRepositoryProvider.overrideWithValue(postRepository),
      ],
    );

    postUpvoteRepository = container.read(postUpvoteRepositoryProvider);
  });

  Future<void> assertPostUpvoteState(
    UserIdFirestore userId,
    PostIdFirestore postId,
    VoteState expectedState, {
    testScore = true,
  }) async {
    final upvoteState = await postUpvoteRepository.getUpvoteState(
      userId,
      postId,
    );
    expect(upvoteState, expectedState);

    if (testScore) {
      final expectedScore = expectedState.increment;
      expect(await getUpvoteCount(postId), expectedScore);
    }
  }

  group(
    "Operation combination work for a single user with a single post",
    () {
      late PostFirestore post;
      const userId = UserIdFirestore(value: "user_id");

      setUp(() async {
        final id = await postRepository.addPost(postData, postLocation);
        post = await postRepository.getPost(id);
      });

      /// Those tests run a sequence of actions, given by [states],
      /// for a single user on a single post. Everything is done atomically.
      void testActions(List<VoteState> states) {
        final stateNames = states.map((state) => state.name).join(", ");
        test(
          "User can use actions [$stateNames] correctly",
          () async {
            await assertPostUpvoteState(userId, post.id, VoteState.none);

            for (final state in states) {
              await postUpvoteRepository.setUpvoteState(
                userId,
                post.id,
                state,
              );

              await assertPostUpvoteState(userId, post.id, state);
            }
          },
        );
      }

      for (final state in VoteState.values) {
        testActions([state]);
      }

      for (final firstState in VoteState.values) {
        for (final secondState in VoteState.values) {
          testActions([firstState, secondState]);
        }
      }
      testActions([
        VoteState.upvoted,
        VoteState.downvoted,
        VoteState.none,
        VoteState.upvoted,
        VoteState.none,
        VoteState.upvoted,
        VoteState.upvoted,
        VoteState.downvoted,
        VoteState.none,
      ]);
    },
  );

  group(
    "Operations work for a single user on multiple posts",
    () {
      const nPosts = 100;
      late List<PostFirestore> posts;
      const userId = UserIdFirestore(value: "user_id");

      setUp(() async {
        posts = [];
        for (int i = 0; i < nPosts; ++i) {
          final id = await postRepository.addPost(postData, postLocation);
          posts.add(await postRepository.getPost(id));
        }
      });

      /// In this tests, a single user applies the same action, [newState], to multiple posts
      for (final newState in VoteState.values) {
        test(
          "User can apply action ${newState.name} on $nPosts different posts",
          () async {
            for (final post in posts) {
              await assertPostUpvoteState(userId, post.id, VoteState.none);
            }

            final futures = posts.map(
              (post) => postUpvoteRepository.setUpvoteState(
                userId,
                post.id,
                newState,
              ),
            );
            await Future.wait(futures);

            for (final post in posts) {
              await assertPostUpvoteState(userId, post.id, newState);
            }
          },
        );
      }
    },
  );
}

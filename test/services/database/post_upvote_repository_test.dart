import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/upvote_state.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/database/post_upvote_service.dart";

void main() {
  late FakeFirebaseFirestore firestore;
  late PostRepositoryService postRepository;
  late PostUpvoteRepositoryService postUpvoteRepository;

  Future<int> getUpvoteCount(PostIdFirestore postId) async {
    final post = await postRepository.getPost(postId);
    return post.data.voteScore;
  }

  const ownerId = UserIdFirestore(value: "owner_id");
  final postData = PostData(
    ownerId: ownerId,
    title: "",
    description: "",
    publicationTime: Timestamp.fromMillisecondsSinceEpoch(0),
    voteScore: 0,
  );
  const postLocation = GeoPoint(40, 20);

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    postRepository = PostRepositoryService(firestore: firestore);
    postUpvoteRepository = PostUpvoteRepositoryService(firestore: firestore);
  });

  int stateToValue(UpvoteState state) {
    switch (state) {
      case UpvoteState.none:
        return 0;
      case UpvoteState.upvoted:
        return 1;
      case UpvoteState.downvoted:
        return -1;
    }
  }

  Future<void> assertPostUpvoteState(
    UserIdFirestore userId,
    PostIdFirestore postId,
    UpvoteState expectedState, {
    testScore = true,
  }) async {
    final upvoteState = await postUpvoteRepository.getUpvoteState(
      userId,
      postId,
    );
    expect(upvoteState, expectedState);

    if (testScore) {
      final expectedScore = stateToValue(expectedState);
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

      void testActions(List<UpvoteState> states) async {
        final stateNames = states.map((state) => state.name).join(", ");
        test(
          "User can use actions [$stateNames] correctly",
          () async {
            await assertPostUpvoteState(userId, post.id, UpvoteState.none);

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

      for (final state in UpvoteState.values) {
        testActions([state]);
      }

      for (final firstState in UpvoteState.values) {
        for (final secondState in UpvoteState.values) {
          testActions([firstState, secondState]);
        }
      }
      testActions([
        UpvoteState.upvoted,
        UpvoteState.downvoted,
        UpvoteState.none,
        UpvoteState.upvoted,
        UpvoteState.none,
        UpvoteState.upvoted,
        UpvoteState.upvoted,
        UpvoteState.downvoted,
        UpvoteState.none,
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

      for (final newState in UpvoteState.values) {
        test(
          "User can apply action ${newState.name} on $nPosts different posts",
          () async {
            for (final post in posts) {
              assertPostUpvoteState(userId, post.id, UpvoteState.none);
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
              assertPostUpvoteState(userId, post.id, newState);
            }
          },
        );
      }
    },
  );
}

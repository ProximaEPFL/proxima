import "dart:math";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:collection/collection.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/database/vote/upvote_state.dart";
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

      void testActions(List<UpvoteState> states) {
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

  group(
    "Operation combination work for multiple users on a single post",
    () {
      late PostFirestore post;
      const nUsers = 900; // Divisible by 2, 3 and 4
      final usersIds = List.generate(
        nUsers,
        (val) => UserIdFirestore(value: "user_id$val"),
      );
      late Random rng;

      setUp(() async {
        final id = await postRepository.addPost(postData, postLocation);
        post = await postRepository.getPost(id);
        // All tests always have the same seed, no matter the order in which it is run
        rng = Random(0);
      });

      /// Tests the input sequence given by [testCases], where each test case
      /// is a tuple of (nUpvoter, nUnvoters, nDownvoters). The other users
      /// are considered to idle.
      void testInputSequence(List<(int, int, int)> testCases) {
        final sequenceName = testCases
            .map(
              (tuple) =>
                  "(${tuple.$1} upvoters, ${tuple.$2} unvoters, ${tuple.$3} downvoters, "
                  "${nUsers - tuple.$1 - tuple.$2 - tuple.$3} idlers)",
            )
            .join(", ");

        test(
            "$nUsers users can successively act as $sequenceName on the same post at the same time",
            () async {
          // What each user is currently doing
          List<UpvoteState> currentState =
              List.filled(nUsers, UpvoteState.none);

          for (int i = 0; i < nUsers; ++i) {
            await assertPostUpvoteState(usersIds[i], post.id, currentState[i]);
          }

          for (int i = 0; i < testCases.length; ++i) {
            final (nUpvoters, nUnvoters, nDownvoters) = testCases[i];
            final idlers = nUsers - (nUpvoters + nUnvoters + nDownvoters);
            assert(
              idlers >= 0,
              "Invalid test case. The sum of the number of upvoters ($nUnvoters), unvoters ($nUnvoters) and "
              "downvoters ($nDownvoters), must be less than or equal to the total number of users ($nUsers).",
            );

            // Make the current actions and update the state
            final List<UpvoteState?> actions =
                List<UpvoteState?>.filled(nUpvoters, UpvoteState.upvoted) +
                    List.filled(nUnvoters, UpvoteState.none) +
                    List.filled(nDownvoters, UpvoteState.downvoted) +
                    List.filled(idlers, null);
            // the rng attribute is necessary for tests to be deterministic
            actions.shuffle(rng);

            // Make all users perform their actions at the same time
            final futures = usersIds.mapIndexed((i, id) async {
              if (actions[i] != null) {
                return await postUpvoteRepository.setUpvoteState(
                  id,
                  post.id,
                  actions[i]!,
                );
              } else {
                return Future.value(null);
              }
            });

            // Wait until they have all finished their action
            await Future.wait(futures);

            // Check that the state is correct
            for (int i = 0; i < nUsers; ++i) {
              if (actions[i] != null) {
                currentState[i] = actions[i]!;
              }
            }

            for (int i = 0; i < nUsers; ++i) {
              await assertPostUpvoteState(
                usersIds[i],
                post.id,
                currentState[i],
                testScore: false,
              );
            }

            // Check that the score is correct
            final expectedScore =
                currentState.map((state) => state.increment).sum;
            expect(await getUpvoteCount(post.id), expectedScore);
          }
        });
      }

      List<int> possibilities = [0, 1];
      for (final hasUpvoters in possibilities) {
        for (final hasUnvoters in possibilities) {
          for (final hasDownvoters in possibilities) {
            for (final hasIdlers in possibilities) {
              if (hasUpvoters + hasUnvoters + hasDownvoters + hasIdlers == 0) {
                continue;
              }
              final usersPerGroup = nUsers ~/
                  (hasUpvoters + hasUnvoters + hasDownvoters + hasIdlers);

              testInputSequence(
                [
                  (
                    // could use a multiplication, but more readable that way
                    hasUpvoters == 1 ? usersPerGroup : 0,
                    hasUnvoters == 1 ? usersPerGroup : 0,
                    hasDownvoters == 1 ? usersPerGroup : 0,
                  ),
                ],
              );
            }
          }
        }
      }
      testInputSequence(
        List.filled(
          5,
          (nUsers ~/ 4, nUsers ~/ 4, nUsers ~/ 4),
        ),
      );
      testInputSequence(
        List.filled(
          5,
          (nUsers ~/ 4 + 30, nUsers ~/ 4 - 10, nUsers ~/ 4 - 10),
        ),
      );
    },
  );
}

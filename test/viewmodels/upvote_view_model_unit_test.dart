import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/database/vote/vote_state.dart";
import "package:proxima/models/ui/votes_details.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/database/post_upvote_repository_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/viewmodels/post_votes_view_model.dart";

import "../mocks/data/firestore_post.dart";
import "../mocks/data/firestore_user.dart";
import "../mocks/data/geopoint.dart";
import "../mocks/services/mock_post_repository_service.dart";
import "../mocks/services/mock_upvote_repository_service.dart";

void main() {
  group("UpVote ViewModel unit testing", () {
    late MockPostRepositoryService postRepository;
    late MockUpvoteRepositoryService<PostIdFirestore> voteRepository;
    late UserIdFirestore userId;
    late PostFirestore testingPost;
    late AutoDisposeFamilyAsyncNotifierProvider<PostVotesViewModel, VotesDetails,
        PostIdFirestore> voteViewModelProvider;

    late ProviderContainer container;

    setUp(() {
      postRepository = MockPostRepositoryService();
      voteRepository = MockUpvoteRepositoryService<PostIdFirestore>();
      userId = testingUserFirestoreId;
      testingPost =
          FirestorePostGenerator().createUserPost(userId, userPosition0);
      voteViewModelProvider = postVotesProvider(testingPost.id);

      container = ProviderContainer(
        overrides: [
          postRepositoryServiceProvider.overrideWithValue(postRepository),
          postUpvoteRepositoryServiceProvider.overrideWithValue(voteRepository),
          loggedInUserIdProvider.overrideWithValue(userId),
        ],
      );
    });

    group("Initial build testing", () {
      test("The correct initial state is returned correctly (UpVote)",
          () async {
        when(voteRepository.getUpvoteState(userId, testingPost.id))
            .thenAnswer((_) => Future.value(VoteState.upvoted));

        when(postRepository.getPost(testingPost.id))
            .thenAnswer((_) => Future.value(testingPost));

        final expectedVote = VotesDetails(
          upvoteState: VoteState.upvoted,
          votes: testingPost.data.voteScore,
        );

        final actualVote = await container.read(voteViewModelProvider.future);

        expect(actualVote, expectedVote);
      });

      test("Error is thrown is the user is not logged in", () async {
        // Update the container to have a null user id
        container.updateOverrides([
          postRepositoryServiceProvider.overrideWithValue(postRepository),
          postUpvoteRepositoryServiceProvider.overrideWithValue(voteRepository),
          loggedInUserIdProvider.overrideWithValue(null),
        ]);

        expect(
          () async => await container.read(voteViewModelProvider.future),
          throwsA(isA<Exception>()),
        );
      });
    });

    group("Voting logic testing", () {
      setUp(() {
        // Setup the initial state of the vote
        when(voteRepository.getUpvoteState(userId, testingPost.id))
            .thenAnswer((_) => Future.value(VoteState.none));

        when(postRepository.getPost(testingPost.id))
            .thenAnswer((_) => Future.value(testingPost));

        when(
          voteRepository.setUpvoteState(
            any,
            any,
            any,
          ),
        ).thenAnswer((_) => Future.value());
      });

      test(
        "Upvote is triggered correctly when there was no vote before",
        () async {
          await container.read(voteViewModelProvider.notifier).triggerUpVote();

          final expectedVote = VotesDetails(
            upvoteState: VoteState.upvoted,
            votes: testingPost.data.voteScore + 1,
          );

          final actualVote = await container.read(voteViewModelProvider.future);

          expect(actualVote, expectedVote);

          verify(
            voteRepository.setUpvoteState(
              userId,
              testingPost.id,
              VoteState.upvoted,
            ),
          );
        },
      );

      test(
        "Downvote is triggered correctly when there was no vote before",
        () async {
          await container
              .read(voteViewModelProvider.notifier)
              .triggerDownVote();

          final expectedVote = VotesDetails(
            upvoteState: VoteState.downvoted,
            votes: testingPost.data.voteScore - 1,
          );

          final actualVote = await container.read(voteViewModelProvider.future);

          expect(actualVote, expectedVote);

          verify(
            voteRepository.setUpvoteState(
              userId,
              testingPost.id,
              VoteState.downvoted,
            ),
          );
        },
      );

      test(
        "Upvote is triggered correctly when there was a downvote before",
        () async {
          // Set the initial state to downvoted
          when(voteRepository.getUpvoteState(userId, testingPost.id))
              .thenAnswer((_) => Future.value(VoteState.downvoted));

          await container.read(voteViewModelProvider.notifier).triggerUpVote();

          final expectedVote = VotesDetails(
            upvoteState: VoteState.upvoted,
            votes: testingPost.data.voteScore + 2,
          );

          final actualVote = await container.read(voteViewModelProvider.future);

          expect(actualVote, expectedVote);

          verify(
            voteRepository.setUpvoteState(
              userId,
              testingPost.id,
              VoteState.upvoted,
            ),
          );
        },
      );

      test(
        "Downvote is triggered correctly when there was an upvote before",
        () async {
          // Set the initial state to upvoted
          when(voteRepository.getUpvoteState(userId, testingPost.id))
              .thenAnswer((_) => Future.value(VoteState.upvoted));

          await container
              .read(voteViewModelProvider.notifier)
              .triggerDownVote();

          final expectedVote = VotesDetails(
            upvoteState: VoteState.downvoted,
            votes: testingPost.data.voteScore - 2,
          );

          final actualVote = await container.read(voteViewModelProvider.future);

          expect(actualVote, expectedVote);

          verify(
            voteRepository.setUpvoteState(
              userId,
              testingPost.id,
              VoteState.downvoted,
            ),
          );
        },
      );

      test(
        "Upvote correctly removes the vote when there was an upvote before",
        () async {
          // Set the initial state to upvoted
          when(voteRepository.getUpvoteState(userId, testingPost.id))
              .thenAnswer((_) => Future.value(VoteState.upvoted));

          await container.read(voteViewModelProvider.notifier).triggerUpVote();

          final expectedVote = VotesDetails(
            upvoteState: VoteState.none,
            // The -1 is normal because we consider that the user already had an upvote
            votes: testingPost.data.voteScore - 1,
          );

          final actualVote = await container.read(voteViewModelProvider.future);

          expect(actualVote, expectedVote);

          verify(
            voteRepository.setUpvoteState(
              userId,
              testingPost.id,
              VoteState.none,
            ),
          );
        },
      );

      test("Throw error if the user is not logged in", () async {
        // Update the container to have a null user id
        container.updateOverrides([
          postRepositoryServiceProvider.overrideWithValue(postRepository),
          postUpvoteRepositoryServiceProvider.overrideWithValue(voteRepository),
          loggedInUserIdProvider.overrideWithValue(null),
        ]);

        expect(
          () async => await container
              .read(voteViewModelProvider.notifier)
              .triggerUpVote(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

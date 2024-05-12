import "dart:async";

import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/vote/vote_state.dart";
import "package:proxima/models/ui/votes_details.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/database/post_upvote_repository_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";

/// This view model is used to handle the upvoting and downvoting of a post.
/// It exposes a [VotesDetails] object that contains the current vote state and the
/// number of votes.
/// The [PostFirestore] parameter is used to identify the post for which is responsible
/// this view model.
///
/// To avoid unnecessary database fetches, the [VotesDetails] state is queried
/// from the database only once at build time and then updated locally after the
/// user triggers an upvote or downvote action.
///
/// This view model must be AutoDisposed because it is created on the fly
/// for each post that is displayed on the screen.
/// Thus, when the post is removed from the screen, the view model is disposed.
class PostVotesViewModel
    extends AutoDisposeFamilyAsyncNotifier<VotesDetails, PostIdFirestore> {
  @override
  FutureOr<VotesDetails> build(PostIdFirestore arg) async {
    final postId = arg;
    final uid = ref.watch(validLoggedInUserIdProvider);

    final voteRepository = ref.watch(postUpvoteRepositoryServiceProvider);
    final postRepository = ref.watch(postRepositoryServiceProvider);

    final postFuture = postRepository.getPost(postId);
    final upvoteStateFuture = voteRepository.getUpvoteState(uid, postId);

    // Await the futures in parallel for better responsiveness
    final results = await Future.wait([postFuture, upvoteStateFuture]);
    final post = results[0] as PostFirestore;
    final upvoteState = results[1] as VoteState;

    return VotesDetails(
      upvoteState: upvoteState,
      votes: post.data.voteScore,
    );
  }

  /// This method is used to perform the upvote action of a post.
  /// If the post is already upvoted, it will remove the upvote.
  Future<void> triggerUpVote() => _triggerVote(VoteState.upvoted);

  /// This method is used to perform the downvote action of a post.
  /// If the post is already downvoted, it will remove the downvote.
  Future<void> triggerDownVote() => _triggerVote(VoteState.downvoted);

  Future<void> _triggerVote(VoteState selectedUpVoteState) async {
    final postId = arg;
    final uid = ref.watch(validLoggedInUserIdProvider);

    final voteRepository = ref.read(postUpvoteRepositoryServiceProvider);

    final currPostVote = await future;
    final currUpVoteState = currPostVote.upvoteState;

    // If the user trigger the same vote state, we remove the vote.
    // (For instance, double clicking the upvote button should add then remove the upvote)
    final newVoteState = currUpVoteState == selectedUpVoteState
        ? VoteState.none
        : selectedUpVoteState;

    final newVotes =
        currPostVote.votes + newVoteState.increment - currUpVoteState.increment;

    // Here, we update the state manually because we only want to update the state
    // locally without fetching the data from the database again.
    state = AsyncData(
      VotesDetails(
        upvoteState: newVoteState,
        votes: newVotes,
      ),
    );

    await voteRepository.setUpvoteState(uid, postId, newVoteState);
  }
}

final postVotesProvider = AsyncNotifierProvider.autoDispose
    .family<PostVotesViewModel, VotesDetails, PostIdFirestore>(
  () => PostVotesViewModel(),
);

import "dart:async";

import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/vote/upvote_state.dart";
import "package:proxima/models/ui/post_vote.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/database/post_upvote_repository_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";

/// This view model is used to handle the upvoting and downvoting of a post.
/// It exposes a [PostVote] object that contains the current vote state and the
/// number of votes.
/// The [postId] parameter is used to identify the post for which is responsible
/// this view model.
///
/// To avoid unnecessary database fetches, the [PostVote] state is queried
/// from the database only once at build time and then updated locally after the
/// user triggers an upvote or downvote action.
///
/// This view model must be AutoDisposed because it is created on the fly
/// for each post that is displayed on the screen.
/// Thus, when the post is removed from the screen, the view model is disposed.
class UpVoteViewModel extends AutoDisposeFamilyAsyncNotifier<PostVote,
    ({PostIdFirestore postId})> {
  @override
  FutureOr<PostVote> build(({PostIdFirestore postId}) arg) async {
    final postId = arg.postId;
    final uid = ref.watch(uidProvider);
    if (uid == null) {
      throw Exception("User is not logged in");
    }

    final voteRepository = ref.watch(postUpvoteRepositoryProvider);
    final postRepository = ref.watch(postRepositoryProvider);

    final post = await postRepository.getPost(postId);
    final upvoteState = await voteRepository.getUpvoteState(uid, postId);

    return PostVote(
      upvoteState: upvoteState,
      votes: post.data.voteScore,
    );
  }

  /// This method is used to perform the upvote action of a post.
  /// If the post is already upvoted, it will remove the upvote.
  Future<void> triggerUpVote() => _triggerVote(UpvoteState.upvoted);

  /// This method is used to perform the downvote action of a post.
  /// If the post is already downvoted, it will remove the downvote.
  Future<void> triggerDownVote() => _triggerVote(UpvoteState.downvoted);

  Future<void> _triggerVote(UpvoteState selectedUpVoteState) async {
    final postId = arg.postId;
    final uid = ref.watch(uidProvider);
    if (uid == null) {
      throw Exception("User is not logged in");
    }

    final voteRepository = ref.read(postUpvoteRepositoryProvider);

    final currPostVote = await future;
    final currUpVoteState = currPostVote.upvoteState;

    // If the user trigger the same vote state, we remove the vote.
    // (For instance, double clicking the upvote button should add then remove the upvote)
    final newVoteState = currUpVoteState == selectedUpVoteState
        ? UpvoteState.none
        : selectedUpVoteState;

    final newVotes =
        currPostVote.votes + newVoteState.increment - currUpVoteState.increment;

    // Here, we update the state manually because we only want to update the state
    // locally without fetching the data from the database again.
    state = AsyncData(
      PostVote(
        upvoteState: newVoteState,
        votes: newVotes,
      ),
    );

    await voteRepository.setUpvoteState(uid, postId, newVoteState);
  }
}

final postVoteProvider = AsyncNotifierProvider.autoDispose
    .family<UpVoteViewModel, PostVote, ({PostIdFirestore postId})>(
  UpVoteViewModel.new,
);

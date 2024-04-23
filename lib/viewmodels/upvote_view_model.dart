import "dart:async";

import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/vote/upvote_state.dart";
import "package:proxima/models/ui/post_vote.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/database/post_upvote_repository_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";

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

  Future<void> triggerUpVote() => _triggerVote(UpvoteState.upvoted);

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

    final newVoteState = currUpVoteState == selectedUpVoteState
        ? UpvoteState.none
        : selectedUpVoteState;

    final newVotes =
        currPostVote.votes + newVoteState.increment - currUpVoteState.increment;

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

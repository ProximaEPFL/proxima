import "dart:async";

import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/vote/upvote_state.dart";
import "package:proxima/models/ui/post_vote.dart";
import "package:proxima/services/database/post_upvote_repository_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";

class UpVoteViewModel
    extends FamilyAsyncNotifier<PostVote, ({PostIdFirestore postId})> {
  @override
  FutureOr<PostVote> build(({PostIdFirestore postId}) arg) async {
    final postId = arg.postId;
    final uid = ref.watch(uidProvider);
    if (uid == null) {
      return const PostVote(
        upvoteState: UpvoteState.none,
        incrementToBaseState: 0,
      );
    }

    final voteRepository = ref.watch(postUpvoteRepositoryProvider);

    final upvoteState = await voteRepository.getUpvoteState(uid, postId);

    return PostVote(upvoteState: upvoteState, incrementToBaseState: 0);
  }

  Future<void> triggerUpVote() => _triggerVote(UpvoteState.upvoted);

  Future<void> triggerDownVote() => _triggerVote(UpvoteState.downvoted);

  Future<void> _triggerVote(UpvoteState selectedUpVoteState) async {
    final postId = arg.postId;
    final uid = ref.watch(uidProvider);
    if (uid == null) {
      return;
    }

    final voteRepository = ref.read(postUpvoteRepositoryProvider);

    final currPostVote = await future;
    final currUpVoteState = currPostVote.upvoteState;

    final newVoteState = currUpVoteState == selectedUpVoteState
        ? UpvoteState.none
        : selectedUpVoteState;

    final newIncrementToBase = currPostVote.incrementToBaseState +
        newVoteState.increment -
        currUpVoteState.increment;

    state = AsyncData(
      PostVote(
        upvoteState: newVoteState,
        incrementToBaseState: newIncrementToBase,
      ),
    );

    await voteRepository.setUpvoteState(uid, postId, newVoteState);
  }
}

final upvoteStateProvider = AsyncNotifierProvider.family<UpVoteViewModel,
    PostVote, ({PostIdFirestore postId})>(UpVoteViewModel.new);

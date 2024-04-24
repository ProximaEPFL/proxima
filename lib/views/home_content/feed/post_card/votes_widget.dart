import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/vote/upvote_state.dart";
import "package:proxima/viewmodels/upvote_view_model.dart";

/// This widget is used to display the votes of a post.
/// It contains two buttons to upvote and downvote the post and the number of votes.
class VotesWidget extends HookConsumerWidget {
  final PostIdFirestore postId;

  const VotesWidget({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPostVote = ref.watch(postVoteProvider(postId));
    final upvoteNotifier = ref.read(postVoteProvider(postId).notifier);

    final votes = asyncPostVote.valueOrNull?.votes ?? 0;
    final upvoteState =
        asyncPostVote.valueOrNull?.upvoteState ?? UpvoteState.none;

    final upvote = IconButton(
      //Used to reduce the padding and InkWell created by the IconButton widget
      //https://stackoverflow.com/questions/50381157/how-do-i-remove-flutter-iconbutton-big-padding
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icon(
        Icons.expand_less,
        size: 30,
        color: upvoteState == UpvoteState.upvoted ? Colors.blue : null,
      ),
      style: const ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () => upvoteNotifier.triggerUpVote(),
    );

    final downvote = IconButton(
      //Used to reduce the padding and InkWell created by the IconButton widget
      //https://stackoverflow.com/questions/50381157/how-do-i-remove-flutter-iconbutton-big-padding
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icon(
        Icons.expand_more,
        size: 30,
        color: upvoteState == UpvoteState.downvoted ? Colors.blue : null,
      ),
      style: const ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () => upvoteNotifier.triggerDownVote(),
    );

    final voteCount = Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Text(_votesString(votes)),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            upvote,
            downvote,
            voteCount,
          ],
        ),
      ),
    );
  }

  String _votesString(int votes) {
    if (votes >= 0) {
      return "+ $votes";
    } else {
      votes = -votes;

      return "- $votes";
    }
  }
}

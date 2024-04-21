import "package:flutter/foundation.dart";
import "package:proxima/models/database/vote/upvote_state.dart";

@immutable
class PostVote {
  final UpvoteState upvoteState;

  final int votes;

  const PostVote({
    required this.upvoteState,
    required this.votes,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostVote &&
        other.upvoteState == upvoteState &&
        other.votes == votes;
  }

  @override
  int get hashCode => Object.hash(upvoteState, votes);
}

import "package:flutter/foundation.dart";
import "package:proxima/models/database/vote/vote_state.dart";

@immutable
class VotesDetails {
  final VoteState upvoteState;

  final int votes;

  const VotesDetails({
    required this.upvoteState,
    required this.votes,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VotesDetails &&
        other.upvoteState == upvoteState &&
        other.votes == votes;
  }

  @override
  int get hashCode => Object.hash(upvoteState, votes);
}

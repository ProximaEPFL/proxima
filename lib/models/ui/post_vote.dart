import "package:flutter/foundation.dart";
import "package:proxima/models/database/vote/upvote_state.dart";

@immutable
class PostVote {
  final UpvoteState upvoteState;

  // This represents the value that needs to be added in order to get the right
  // vote score of the post after the user has performed an up/downvote action.
  // This is used to update the vote score of the post in the UI without querying
  // the post document from the database.
  // This allows for a more responsive UI while limiting interaction with the database.
  final int incrementToBaseState;

  const PostVote({
    required this.upvoteState,
    required this.incrementToBaseState,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostVote &&
        other.upvoteState == upvoteState &&
        other.incrementToBaseState == incrementToBaseState;
  }

  @override
  int get hashCode => Object.hash(upvoteState, incrementToBaseState);
}

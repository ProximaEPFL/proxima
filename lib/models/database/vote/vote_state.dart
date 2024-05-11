/// Enum to represent the state of an upvote. A user can either
/// be not voting, upvoting or downvoting on a post/comment.
enum VoteState {
  none,
  upvoted,
  downvoted;

  /// Returns the increment that should be applied to the upvote count
  /// of a post/comment when the user applies this vote.
  int get increment {
    switch (this) {
      case VoteState.none:
        return 0;
      case VoteState.upvoted:
        return 1;
      case VoteState.downvoted:
        return -1;
    }
  }

  /// Returns the name of the enum value, without the `UpvoteState.` prefix.
  /// For example, `UpvoteState.none.name` will return `"none"`
  String get name => toString().split(".").last;
}

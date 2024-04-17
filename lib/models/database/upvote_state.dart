/// Enum to represent the state of an upvote. A user can either
/// be not voting, upvoting or downvoting on a post/comment.
enum UpvoteState {
  none,
  upvoted,
  downvoted;

  /// Returns the increment that should be applied to the upvote count
  /// of a post/comment when the user applies this vote.
  int get increment {
    switch (this) {
      case UpvoteState.none:
        return 0;
      case UpvoteState.upvoted:
        return 1;
      case UpvoteState.downvoted:
        return -1;
    }
  }

  /// Returns the name of the enum value, without the `UpvoteState.` prefix.
  /// For example, `UpvoteState.none.name` will return `"none"`
  String get name => toString().split(".").last;
}

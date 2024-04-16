/// Enum to represent the state of an upvote. A user can either
/// be not voting, upvoting or downvoting on a post/comment.
enum UpvoteState {
  none,
  upvoted,
  downvoted;

  /// Returns the name of the enum value, without the `UpvoteState.` prefix.
  /// For example, `UpvoteState.none.name` will return `"none"`
  String get name => toString().split(".").last;
}

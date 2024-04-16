enum UpvoteState {
  none,
  upvoted,
  downvoted;

  String get name => toString().split(".").last;
}

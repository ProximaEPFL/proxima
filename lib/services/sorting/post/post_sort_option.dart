import "package:proxima/services/sorting/post/post_score_functions.dart";

/// This enum is used to describe how to sort posts, notably in the feed.
enum PostSortOption {
  hottest("Hottest", hotScore, false),
  top("Top", voteScore, false),
  latest("Latest", dayScore, true),
  nearest("Nearest", distanceScore, true);

  final String name;
  final PostScoreFunction scoreFunction;
  final bool sortIncreasing;

  /// This constructor creates a new instance of [PostSortOption].
  /// It has a [name] for the ui, a [scoreFunction] to calculate the score of a post
  /// when sorting it and a [sortIncreasing] to know if the sort should be done in
  /// increasing order of score or not.
  /// The exact value of the score does not matter, only their relative values. For
  /// instance, adding 100'000 to all scores would not change anything.
  const PostSortOption(this.name, this.scoreFunction, this.sortIncreasing);
}

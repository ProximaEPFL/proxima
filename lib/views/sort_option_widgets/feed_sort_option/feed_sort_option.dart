/// This enum is used to create the timeline sort options.
/// It contains the name of the sort options.
enum FeedSortOption {
  top("Top"),
  nearest("Nearest"),
  latest("New"),
  hot("Hot");

  final String name;

  const FeedSortOption(this.name);
}

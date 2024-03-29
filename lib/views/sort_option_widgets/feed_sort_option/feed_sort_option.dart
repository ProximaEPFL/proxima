/// This enum is used to create the timeline sort options.
/// It contains the name of the sort options.
enum SortOptions {
  top("Top"),
  nearest("Nearest"),
  latest("New"),
  hot("Hot");

  final String name;

  const SortOptions(this.name);
}

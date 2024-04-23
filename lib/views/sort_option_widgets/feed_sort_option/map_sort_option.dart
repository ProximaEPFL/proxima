/// This enum is used to create the map sort options.
/// It contains the name of the sort options.
enum MapSortOption {
  heatMap("Heat map"),
  nearby("Nearby"),
  myPosts("My posts"),
  challenges("Challenges");

  final String name;

  const MapSortOption(this.name);
}

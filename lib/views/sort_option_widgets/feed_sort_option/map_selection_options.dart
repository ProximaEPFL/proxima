/// This enum is used to create the map sort options.
/// It contains the name of the sort options.
enum MapSelectionOptions {
  heatMap("Heat map"),
  nearby("Nearby"),
  myPosts("My posts"),
  challenges("Challenges");

  final String name;

  const MapSelectionOptions(this.name);
}

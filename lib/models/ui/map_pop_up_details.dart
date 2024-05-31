///Details to be displayed in the map pop up (which is diplay when a map pin is clicked)
class MapPopUpDetails {
  const MapPopUpDetails({
    required this.title,
    this.description,
    this.route,
    this.routeArguments,
  });

  final String title;

  final String? description;

  final String? route;

  final Object? routeArguments;

  @override
  bool operator ==(Object other) {
    return other is MapPopUpDetails &&
        other.title == title &&
        other.description == description &&
        other.route == route &&
        other.routeArguments == routeArguments;
  }

  @override
  int get hashCode {
    return Object.hash(
      title,
      description,
      route,
      routeArguments,
    );
  }
}

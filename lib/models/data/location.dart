final class Location {
  static const double minLatitude = -90;
  static const double maxLatitude = 90;

  static const double minLongitude = -180;
  static const double maxLongitude = 180;

  final double longitude;
  final double latitude;

  Location({required this.longitude, required this.latitude}) {
    if (longitude < minLongitude || longitude > maxLongitude) {
      throw ArgumentError("Longitude is out of bounds");
    }
    if (latitude < minLatitude || latitude > maxLatitude) {
      throw ArgumentError("Latitude is out of bounds");
    }
  }
}

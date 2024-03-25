import "package:geolocator/geolocator.dart";

class GeoLocationService {
  /// We do not perform dependency injection of [Geolocator] here because the
  /// [GeoLocationService] methods cannot be used with an instance of [Geolocator]

  /// Also, this class is not a singleton on purpose. This is to allow for
  /// dependency injection of the [GeoLocationService] in the repository that
  /// uses it. This is useful for testing purposes.

  // Source: Flutter Documentation (https://pub.dev/packages/geolocator)
  // This code is adapted from the Flutter documentation
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      throw Exception("Location services are disabled.");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        throw Exception("Location permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      throw Exception(
        "Location permissions are permanently denied, we cannot request permissions.",
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}

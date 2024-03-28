import "package:cloud_firestore/cloud_firestore.dart";
import "package:geolocator/geolocator.dart";

class GeoLocationService {
  final GeolocatorPlatform _geoLocator;

  // Settings to get the most accurate location
  final LocationSettings locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.best,
  );

  GeoLocationService({
    required GeolocatorPlatform geoLocator,
  }) : _geoLocator = geoLocator;

  Future<GeoPoint> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geoLocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    // Check location permissions
    permission = await _geoLocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geoLocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied after requesting
        throw Exception("Location permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      throw Exception(
        "Location permissions are permanently denied, we cannot request permissions.",
      );
    }

    final position = await _geoLocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    return GeoPoint(position.latitude, position.longitude);
  }
}

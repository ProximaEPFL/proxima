import "package:cloud_firestore/cloud_firestore.dart";
import "package:geolocator/geolocator.dart";

class GeoLocationService {
  final GeolocatorPlatform _geoLocator;

  /// Here we use the LocationAccuracy.best setting to get the most accurate location possible. (~0m on IOS, 0-100m on Android)
  /// We do not use the LocationAccuracy.high setting because the accuracy is lower
  /// and given that we are dealing with small distances (< 100m), it is more beneficial to use the best accuracy possible.
  ///
  /// We also do not use the LocationAccuracy.bestForNavigation as the user is most
  /// likely not moving at high speeds considering the goal of the app.
  /// Also, the bestForNavigation setting is the same as best on Android.
  ///
  /// Source : https://pub.dev/documentation/geolocator_android/latest/geolocator_android/LocationAccuracy.html
  final LocationSettings locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.best,
  );

  GeoLocationService({
    required GeolocatorPlatform geoLocator,
  }) : _geoLocator = geoLocator;

  // This code is adapted from the geolocator package documentation
  // Source : https://pub.dev/packages/geolocator

  /// This method will retrieve the current position of the user.
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
      // Permissions are denied forever
      // TODO : Handle this case to notify the user that the location permissions are denied forever
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

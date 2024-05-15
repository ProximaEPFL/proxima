import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:mockito/mockito.dart";

/// This is a mock class for the [GoogleMapController] class
class MockGoogleMapController extends Mock implements GoogleMapController {
  @override
  Future<void> animateCamera(CameraUpdate cameraUpdate) {
    return super.noSuchMethod(
      Invocation.method(#animateCamera, [cameraUpdate]),
      returnValue: Future.value(),
    );
  }
}

import "package:flutter_test/flutter_test.dart";
import "package:proxima/viewmodels/map/map_view_model.dart";

import "../../mocks/services/mock_google_map_controller.dart";

void main() {
  late MockGoogleMapController mockMapController;
  late MapViewModel mapViewModel;

  setUp(() {
    mockMapController = MockGoogleMapController();
    mapViewModel = MapViewModel();

    mapViewModel.onMapCreated(mockMapController);
  });

  group("Camera", () {
    test("Camera follows user's live location by default", () async {
      // Check if the map controller is created
      expect(mapViewModel.mapController.isCompleted, true);

      expect(mapViewModel.followUser, true);
    });

    test("Camera stops following after user interaction", () {});
  });
}

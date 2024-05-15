import "package:flutter_test/flutter_test.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:proxima/viewmodels/map/map_view_model.dart";

import "../../mocks/services/mock_google_map_controller.dart";

void main() {
  //test the redraw circle method
  test("Redraw circle", () {
    //create a new instance of the map view model
    final mapViewModel = MapViewModel();

    //new position for the circle
    const newLocation = LatLng(1, 1);

    //redraw the circle
    mapViewModel.redrawCircle(newLocation);

    //check if the circle is redrawn in the new location
    expect(mapViewModel.circles.elementAt(0).center, newLocation);
  });

  test("On map create", () async {
    //create a new instance of the map view model
    final mapViewModel = MapViewModel();

    final mockGoogleMapController = MockGoogleMapController();

    //create a new instance of the map controller
    mapViewModel.onMapCreated(mockGoogleMapController);

    //check if the map controller is created
    expect(mapViewModel.mapController.isCompleted, true);
  });
}

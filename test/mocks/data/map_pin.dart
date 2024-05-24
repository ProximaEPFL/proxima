import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:proxima/models/ui/map_pin_details.dart";
import "package:proxima/models/ui/map_pop_up_details.dart";

class MapPinGenerator {
  //generate a list of MapPin
  static List<MapPinDetails> generateMapPins(int numberOfPins) {
    List<MapPinDetails> mapPins = List.generate(
      numberOfPins,
      (index) => MapPinDetails(
        id: MarkerId(index.toString()),
        position: LatLng(index.toDouble(), index.toDouble()),
        mapPopUpDetails: MapPopUpDetails(
          title: "Title $index",
          description: "Description $index",
        ),
      ),
    );

    return mapPins;
  }
}

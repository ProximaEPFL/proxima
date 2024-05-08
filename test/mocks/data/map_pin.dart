import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:proxima/models/ui/map_pin.dart";

class MapPinGenerator {
  //generate a list of MapPin
  static List<MapPin> generateMapPins(int numberOfPins) {
    List<MapPin> mapPins = List.generate(
      numberOfPins,
      (index) => MapPin(
        id: MarkerId(index.toString()),
        position: LatLng(index.toDouble(), index.toDouble()),
        callbackFunction: () {},
      ),
    );

    return mapPins;
  }
}

import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:proxima/models/ui/map_pin.dart";

//mock data to test the MapPin viewmodel
List<MapPin> testPins = [
  MapPin(
    id: const MarkerId("1"),
    position: const LatLng(0, 0),
    callbackFunction: () {},
  ),
  MapPin(
    id: const MarkerId("2"),
    position: const LatLng(1, 1),
    callbackFunction: () {},
  ),
  MapPin(
    id: const MarkerId("3"),
    position: const LatLng(2, 2),
    callbackFunction: () {},
  ),
  MapPin(
    id: const MarkerId("4"),
    position: const LatLng(3, 3),
    callbackFunction: () {},
  ),
  MapPin(
    id: const MarkerId("5"),
    position: const LatLng(4, 4),
    callbackFunction: () {},
  ),
];

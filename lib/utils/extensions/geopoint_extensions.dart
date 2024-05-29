import "package:cloud_firestore/cloud_firestore.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";

extension ToLatLng on GeoPoint {
  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }
}

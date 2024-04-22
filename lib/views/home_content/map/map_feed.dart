import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class MapFeed extends ConsumerStatefulWidget {
  const MapFeed({super.key});

  @override
  MapFeedState createState() => MapFeedState();
}

class MapFeedState extends ConsumerState<MapFeed> {
  late LatLng? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    double lat = position.latitude;
    double long = position.longitude;

    LatLng location = LatLng(lat, long);

    setState(() {
      _currentPosition = location;
      _isLoading = false;
    });
  }

  static const mapKey = Key("map");

  static const double _initialZoom = 14;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              key: mapKey,
              initialCameraPosition:
                  CameraPosition(target: _currentPosition!, zoom: _initialZoom),
            ),
    );
  }
}

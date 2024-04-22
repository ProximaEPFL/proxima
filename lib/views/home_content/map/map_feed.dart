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
  //key for testing
  static const mapKey = Key("map");

  //current position of the user
  late LatLng? _currentPosition;

  //current zoom level of the map
  static const double _currentZoom = 14;

  //radius of the circle (in km)
  static const double _radius = 1;

  //loading state of the map
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  //get the current location of the user
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //display a loading indicator while the map is loading
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              key: mapKey,
              initialCameraPosition:
                  CameraPosition(target: _currentPosition!, zoom: _currentZoom),
              //the user sees their current location on the map
              myLocationEnabled: true,
              //no need for this button because the user can't scroll the map
              myLocationButtonEnabled: false,
              zoomGesturesEnabled: false,
              //no need for these gestures because the user can't scroll the map
              zoomControlsEnabled: false,
              //we can't scroll the map
              scrollGesturesEnabled: false,
              circles: {
                Circle(
                  circleId: const CircleId("1"),
                  center: _currentPosition!,
                  radius: _radius * 1000,
                  fillColor: Colors.black12,
                  strokeWidth: 0,
                ),
              },
            ),
    );
  }
}

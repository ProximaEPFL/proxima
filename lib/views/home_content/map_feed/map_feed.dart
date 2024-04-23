import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/home_content/map_feed/maps/nearby_posts_map.dart";
import "package:proxima/views/sort_option_widgets/feed_sort_option/map_sort_option_chips.dart";

class MapFeed extends ConsumerStatefulWidget {
  const MapFeed({super.key});

  @override
  MapFeedState createState() => MapFeedState();
}

class MapFeedState extends ConsumerState<MapFeed> {
  //key for testing
  static const mapKey = Key("map");

  //current position of the user
  late LatLng _currentPosition;

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
    return
        //display a loading indicator while the map is loading
        _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  const MapSortOptionChips(),
                  const Divider(),
                  //display the map
                  Expanded(
                    child: NearbyPostsMap(
                        currentPosition: _currentPosition,
                        currentZoom: _currentZoom,
                        radius: _radius),
                  ),
                ],
              );
  }
}

import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/views/home_content/map_feed/maps/nearby_posts_map.dart";
import "package:proxima/views/sort_option_widgets/feed_sort_option/map_sort_option_chips.dart";

class MapFeed extends ConsumerStatefulWidget {
  const MapFeed({super.key});

  @override
  MapFeedState createState() => MapFeedState();
}

class MapFeedState extends ConsumerState<MapFeed> {
  //key for testing
  static const mapScreenKey = Key("map");
  static const dividerKey = Key("Divider");

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
    ref.read(geoLocationServiceProvider).getCurrentPosition().then((value) {
      setState(() {
        _currentPosition = LatLng(value.latitude, value.longitude);
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //get the geolocator service
    return
        //display a loading indicator while the map is loading
        _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                key: mapScreenKey,
                body: Column(
                  children: [
                    const MapSortOptionChips(),
                    const Divider(key: dividerKey),
                    //display the map
                    Expanded(
                      //TODO: change the type of map when selecting a sort option
                      child: NearbyPostsMap(
                        currentPosition: _currentPosition,
                        currentZoom: _currentZoom,
                        radius: _radius,
                      ),
                    ),
                  ],
                ),
              );
  }
}

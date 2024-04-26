import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/geolocation_service.dart";

class MapInfo {
  MapInfo({
    required this.currentLocation,
    required this.markers,
  });
  final LatLng currentLocation;
  final Set<Marker> markers;
}

final asyncMapProvider = AsyncNotifierProvider<MapNotifier, MapInfo>(
  () => MapNotifier(),
);

class MapNotifier extends AsyncNotifier<MapInfo> {
  @override
  Future<MapInfo> build() async {
    GeoPoint position =
        await ref.read(geoLocationServiceProvider).getCurrentPosition();

    Set<Marker> markers = {};
    //get the nearest posts
    List<PostFirestore> newposts =
        await ref.watch(postRepositoryProvider).getNearPosts(position, 0.1);
    //add the markers to the map
    for (var post in newposts) {
      markers.add(Marker(
        markerId: MarkerId(post.id.value),
        position: LatLng(
            post.location.geoPoint.latitude, post.location.geoPoint.longitude),
        infoWindow: InfoWindow(
          title: post.data.title,
          snippet: post.data.description,
        ),
      ));
    }

    return MapInfo(
      currentLocation: LatLng(position.latitude, position.longitude),
      markers: markers,
    );
  }

  final Completer<GoogleMapController> _mapController = Completer();

  void onMapCreated(GoogleMapController controller) {
    if (!_mapController.isCompleted) _mapController.complete(controller);
  }

  Future<void> getCurrentLocation() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await build());
  }
}

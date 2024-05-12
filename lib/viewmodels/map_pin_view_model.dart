import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/map_pin_details.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/viewmodels/posts_feed_view_model.dart";

class MapPinViewModel extends AsyncNotifier<List<MapPinDetails>> {
  @override
  Future<List<MapPinDetails>> build() async {
    final postrepository = ref.watch(postRepositoryServiceProvider);
    final position = await ref.watch(livePositionStreamProvider.future);

    if (position == null) {
      return List.empty();
    }

    final nearPosts = await postrepository.getNearPosts(
      position,
      PostsFeedViewModel.kmPostRadius,
    );
    final pinList = nearPosts.map((post) {
      final postPosition = post.location.geoPoint;
      return MapPinDetails(
        id: MarkerId(post.id.value),
        position: LatLng(postPosition.latitude, postPosition.longitude),
        callbackFunction: () {},
      );
    }).toList();

    return pinList;
  }
}

// This provider is used to store the list of map pins that are displayed in the map page.
final mapPinViewModelProvider =
    AsyncNotifierProvider<MapPinViewModel, List<MapPinDetails>>(
  () => MapPinViewModel(),
);

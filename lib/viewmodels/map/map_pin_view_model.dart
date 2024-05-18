import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/ui/map_pin_details.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/viewmodels/option_selection/map_selection_options_view_model.dart";
import "package:proxima/viewmodels/posts_feed_view_model.dart";
import "package:proxima/views/components/options/map/map_selection_options.dart";

/// This view model is used to fetch the list of map pins that
/// needs to be displayed in the map page.
class MapPinViewModel extends AsyncNotifier<List<MapPinDetails>> {
  @override
  Future<List<MapPinDetails>> build() async {
    final currentOption = ref.watch(mapSelectionOptionsViewModelProvider);

    switch (currentOption) {
      case MapSelectionOptions.nearby:
        return _getNearbyPosts();
      case MapSelectionOptions.myPosts:
        return _getUserPosts();
      default:
        return List.empty();
    }
  }

  /// Get nearby posts
  Future<List<MapPinDetails>> _getNearbyPosts() async {
    final postRepository = ref.watch(postRepositoryServiceProvider);
    final position = await ref.watch(livePositionStreamProvider.future);

    if (position == null) {
      return List.empty();
    }

    final nearPosts = await postRepository.getNearPosts(
      position,
      PostsFeedViewModel.kmPostRadius,
    );
    return nearPosts.map(_toMapPinDetails).toList();
  }

  /// Get user posts
  Future<List<MapPinDetails>> _getUserPosts() async {
    final postRepository = ref.watch(postRepositoryServiceProvider);
    final userId = ref.watch(validLoggedInUserIdProvider);
    final userPosts = await postRepository.getUserPosts(userId);

    return userPosts.map(_toMapPinDetails).toList();
  }

  /// Convert a [post] to a map pin details
  MapPinDetails _toMapPinDetails(
    PostFirestore post, {
    void Function()? callback,
  }) {
    final postPosition = post.location.geoPoint;

    return MapPinDetails(
      id: MarkerId(post.id.value),
      position: LatLng(postPosition.latitude, postPosition.longitude),
      callbackFunction: callback ?? () => (),
    );
  }
}

final mapPinViewModelProvider =
    AsyncNotifierProvider<MapPinViewModel, List<MapPinDetails>>(
  () => MapPinViewModel(),
);

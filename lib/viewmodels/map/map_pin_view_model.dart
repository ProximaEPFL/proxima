import "package:collection/collection.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/ui/map_pin_details.dart";
import "package:proxima/models/ui/map_pop_up_details.dart";
import "package:proxima/models/ui/post_details.dart";
import "package:proxima/services/database/challenge_repository_service.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/viewmodels/option_selection/map_selection_options_view_model.dart";
import "package:proxima/viewmodels/posts_feed_view_model.dart";
import "package:proxima/views/components/options/map/map_selection_options.dart";
import "package:proxima/views/navigation/routes.dart";

/// This view model is used to fetch the list of map pins that
/// needs to be displayed in the map page.
/// This needs the "AutoDispose" in [AutoDisposeAsyncNotifier] so that
/// the pins are refreshed when navigating away from the map page. This
/// may allow to catch some bugs that may occur when the pins are not
/// refreshed when the user adds/deletes a post or completes a challenge.
class MapPinViewModel extends AutoDisposeAsyncNotifier<List<MapPinDetails>> {
  @override
  Future<List<MapPinDetails>> build() async {
    final currentOption = ref.watch(mapSelectionOptionsViewModelProvider);

    switch (currentOption) {
      case MapSelectionOptions.nearby:
        return _getNearbyPosts();
      case MapSelectionOptions.myPosts:
        return _getUserPosts();
      case MapSelectionOptions.challenges:
        return _getUserChallenges();
      default:
        return List.empty();
    }
  }

  /// Refreshes the map pins
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  /// Get nearby posts
  Future<List<MapPinDetails>> _getNearbyPosts() async {
    //checking if the location services are enabled directly here so that
    //we throw the same exception as the challenge case
    final locationCheck =
        await ref.read(geolocationServiceProvider).checkLocationServices();

    if (locationCheck != null) {
      throw locationCheck;
    }

    try {
      await ref.watch(livePositionStreamProvider.future);
    } catch (e) {
      ref.invalidate(livePositionStreamProvider);
    }

    final position = await ref.watch(livePositionStreamProvider.future);
    final postRepository = ref.watch(postRepositoryServiceProvider);
    final userRepository = ref.watch(userRepositoryServiceProvider);

    if (position == null) {
      return List.empty();
    }

    final nearPosts = await postRepository.getNearPosts(
      position,
      PostsFeedViewModel.kmPostRadius,
    );

    final users = await Future.wait(
      nearPosts.map((post) => userRepository.getUser(post.data.ownerId)),
    );

    return nearPosts
        .mapIndexed(
          (index, post) => _toMapPinDetails(
            post,
            MapPopUpDetails(
              title: post.data.title,
              description: post.data.description,
              route: Routes.post.name,
              routeArguments: PostDetails.fromFirestoreData(
                post,
                users[index],
                GeoFirePoint(position),
                false,
              ),
            ),
          ),
        )
        .toList();
  }

  /// Get user posts
  Future<List<MapPinDetails>> _getUserPosts() async {
    final postRepository = ref.watch(postRepositoryServiceProvider);
    final userId = ref.watch(validLoggedInUserIdProvider);
    final userPosts = await postRepository.getUserPosts(userId);

    return userPosts
        .map(
          (post) => _toMapPinDetails(
            post,
            MapPopUpDetails(
              title: post.data.title,
              description: post.data.description,
              route: Routes.profile.name,
            ),
          ),
        )
        .toList();
  }

  /// Get user active challenges
  Future<List<MapPinDetails>> _getUserChallenges() async {
    // Only doing a read here, to decrease the number of database reads
    // (we don't want to re-read the challenges when the position changes).
    final position =
        await ref.read(geolocationServiceProvider).getCurrentPosition();

    final postRepository = ref.watch(postRepositoryServiceProvider);
    final challengeRepostory = ref.watch(challengeRepositoryServiceProvider);
    final userId = ref.watch(validLoggedInUserIdProvider);

    final userChallenges = await challengeRepostory.getChallenges(
      userId,
      position,
    );
    final activeChallenges = userChallenges.whereNot(
      (challenge) => challenge.data.isCompleted,
    );
    final posts = await Future.wait(
      activeChallenges.map(
        (challenge) => postRepository.getPost(challenge.postId),
      ),
    );

    return posts
        .map(
          (post) => _toMapPinDetails(
            post,
            MapPopUpDetails(
              title: post.data.title,
            ),
          ),
        )
        .toList();
  }

  /// Convert a [post] to a map pin details
  MapPinDetails _toMapPinDetails(
    PostFirestore post,
    MapPopUpDetails mapPopUpDetails,
  ) {
    final postPosition = post.location.geoPoint;

    return MapPinDetails(
      id: MarkerId(post.id.value),
      position: LatLng(postPosition.latitude, postPosition.longitude),
      mapPopUpDetails: mapPopUpDetails,
    );
  }
}

final mapPinViewModelProvider =
    AutoDisposeAsyncNotifierProvider<MapPinViewModel, List<MapPinDetails>>(
  () => MapPinViewModel(),
);

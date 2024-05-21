import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/ui/map_pin_details.dart";
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
import "package:proxima/views/pages/home/content/map/components/map_pin_pop_up.dart";

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

  BuildContext? context;

  //setter for the context
  void setContext(BuildContext context) {
    this.context = context;
  }

  /// Refreshes the map pins
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  /// Get nearby posts
  Future<List<MapPinDetails>> _getNearbyPosts() async {
    final position = await ref.watch(livePositionStreamProvider.future);
    final postRepository = ref.watch(postRepositoryServiceProvider);
    final userRepository = ref.watch(userRepositoryServiceProvider);
    final userId = ref.watch(validLoggedInUserIdProvider);

    if (position == null) {
      return List.empty();
    }

    final user = await userRepository.getUser(userId);

    final nearPosts = await postRepository.getNearPosts(
      position,
      PostsFeedViewModel.kmPostRadius,
    );

    return nearPosts
        .map(
          (post) => _toMapPinDetails(
            post,
            callback: () => showDialog(
              context: context!,
              builder: (context) {
                return MapPinPopUp(
                  title: post.data.title,
                  content: post.data.description,
                  displayButton: true,
                  navigationAction: () {
                    Navigator.pushNamed(
                      context,
                      Routes.post.name,
                      arguments: PostDetails(
                        postId: post.id,
                        title: post.data.title,
                        description: post.data.description,
                        ownerCentauriPoints: user.data.centauriPoints,
                        ownerDisplayName: user.data.displayName,
                        ownerUsername: user.data.username,
                        publicationDate: post.data.publicationTime.toDate(),
                        commentNumber: post.data.commentCount,
                        voteScore: post.data.voteScore,
                        distance: (GeoFirePoint(position).distanceBetweenInKm(
                                  geopoint: post.location.geoPoint,
                                ) *
                                1000)
                            .round(),
                      ),
                    );
                  },
                );
              },
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
            callback: () => showDialog(
              context: context!,
              builder: (context) {
                return MapPinPopUp(
                  title: post.data.title,
                  content: post.data.description,
                  displayButton: true,
                  navigationAction: () {
                    Navigator.pushNamed(
                      context,
                      Routes.profile.name,
                    );
                  },
                );
              },
            ),
          ),
        )
        .toList();
  }

  /// Get user active challenges
  Future<List<MapPinDetails>> _getUserChallenges() async {
    final postRepository = ref.watch(postRepositoryServiceProvider);
    final challengeRepostory = ref.watch(challengeRepositoryServiceProvider);
    final userId = ref.watch(validLoggedInUserIdProvider);
    // Only doing a read here, to decrease the number of database reads
    // (we don't want to re-read the challenges when the position changes).
    final position =
        await ref.read(geolocationServiceProvider).getCurrentPosition();

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
            callback: () => showDialog(
              context: context!,
              builder: (context) {
                return MapPinPopUp(
                  title: post.data.title,
                );
              },
            ),
          ),
        )
        .toList();
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
    AutoDisposeAsyncNotifierProvider<MapPinViewModel, List<MapPinDetails>>(
  () => MapPinViewModel(),
);

import "dart:async";

import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/ui/linear_segmented_hsv_colormap.dart";
import "package:proxima/models/ui/user_avatar_details.dart";
import "package:proxima/services/database/challenge_repository_service.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";

/// View model for the dynamic user avatar.
/// This view model is used to fetch the user's display name given its id.
/// If the id is null, the current user's display name is fetched.
class DynamicUserAvatarViewModel extends AutoDisposeFamilyAsyncNotifier<
    UserAvatarDetails, UserIdFirestore?> {
  DynamicUserAvatarViewModel();

  /// Stops for the colormap used to color the user's avatar based on their centauri points.
  /// The stops are defined as the number of challenges completed.
  static const _challengesStops = [
    // sqrt(10) ~= 3, which is the approximate step between each stop
    0,
    10, // ~ 3 days of daily challenge
    30,
    100,
    300, // ~ 3 months of daily challenge
    1000,
    3000, // ~ 3 years of daily challenge
    10000,
  ];

  /// Converts some amount of [centauriPoints] to a color, based on a uniform
  /// [LinearSegmentedHSVColormap] (defined by _challengesStop). [brightness]
  /// defines the value and saturation of the colormap.
  /// If [centauriPoints] is null, the color is transparent.
  static Color centauriToColor(int? centauriPoints, Brightness brightness) {
    if (centauriPoints == null) return Colors.transparent;

    final hsvValue = switch (brightness) {
      Brightness.light => 0.9,
      Brightness.dark => 0.5,
    };
    final hsvSaturation = switch (brightness) {
      Brightness.light => 0.4,
      Brightness.dark => 0.8,
    };

    const chalReward = ChallengeRepositoryService.soloChallengeReward;
    final colorMap = LinearSegmentedHSVColormap.uniform(
      _challengesStops.map((nChallenges) => nChallenges * chalReward).toList(),
      value: hsvValue,
      saturation: hsvSaturation,
    );

    return colorMap(centauriPoints).toColor();
  }

  @override
  Future<UserAvatarDetails> build(UserIdFirestore? arg) async {
    final currentUID = ref.watch(loggedInUserIdProvider);
    final userDataBase = ref.watch(userRepositoryServiceProvider);

    late final UserFirestore user;
    late final UserIdFirestore userID;

    if (arg == null) {
      if (currentUID == null) {
        throw Exception("User is not logged in.");
      }
      userID = currentUID;
    } else {
      userID = arg;
    }

    user = await userDataBase.getUser(userID);

    return UserAvatarDetails.fromUserData(
      user.data,
      userID,
    );
  }
}

//TODO: Extend to fetch the user's avatar image.
/// Flexible provider allowing to retrieve the user's display name given its id.
/// If the id is null, the current user's display name is fetched.
final dynamicUserAvatarViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<DynamicUserAvatarViewModel, UserAvatarDetails, UserIdFirestore?>(
  () => DynamicUserAvatarViewModel(),
);

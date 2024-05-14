import "dart:async";
import "dart:ui";

import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/user/user_data.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/ui/linear_segmented_colormap.dart";
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

  static const _chalReward = ChallengeRepositoryService.soloChallengeReward;
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
  static final centauriToHSVColor = LinearSegmentedHSVColormap.uniform(
    _challengesStops.map((nChallenges) => nChallenges * _chalReward).toList(),
  );

  static Color centauriToColor(int? centauriPoints) {
    if (centauriPoints == null) return Colors.transparent;
    return centauriToHSVColor(centauriPoints).toColor();
  }

  static UserAvatarDetails userDataToDetails(UserData userData) {
    return UserAvatarDetails(
      displayName: userData.displayName,
      userCentauriPoints: userData.centauriPoints,
    );
  }

  @override
  Future<UserAvatarDetails> build(UserIdFirestore? arg) async {
    final userID = arg;
    final currentUID = ref.watch(loggedInUserIdProvider);
    final userDataBase = ref.watch(userRepositoryServiceProvider);

    late final UserFirestore user;

    if (userID == null) {
      if (currentUID == null) {
        throw Exception("User is not logged in.");
      }

      user = await userDataBase.getUser(currentUID);
    } else {
      user = await userDataBase.getUser(userID);
    }

    return userDataToDetails(user.data);
  }
}

//TODO: Extend to fetch the user's avatar image.
/// Flexible provider allowing to retrieve the user's display name given its id.
/// If the id is null, the current user's display name is fetched.
final dynamicUserAvatarViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<DynamicUserAvatarViewModel, UserAvatarDetails, UserIdFirestore?>(
  () => DynamicUserAvatarViewModel(),
);

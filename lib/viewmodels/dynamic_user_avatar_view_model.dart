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

  static final centauriToColor = LinearSegmentedColormap({
    0 * _chalReward: const Color.fromARGB(255, 79, 73, 255),
    10 * _chalReward: const Color.fromARGB(255, 20, 146, 20),
    50 * _chalReward: const Color.fromARGB(255, 135, 199, 31),
    100 * _chalReward: const Color.fromARGB(255, 209, 206, 9),
    500 * _chalReward: const Color.fromARGB(255, 220, 146, 17),
    1000 * _chalReward: const Color.fromARGB(255, 216, 31, 31),
    5000 * _chalReward: const Color.fromARGB(255, 175, 10, 117),
    10000 * _chalReward: const Color.fromARGB(255, 175, 10, 158),
  });

  static UserAvatarDetails userDataToDetails(UserData userData) {
    return UserAvatarDetails(
      displayName: userData.displayName,
      backgroundColor: centauriToColor(userData.centauriPoints),
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

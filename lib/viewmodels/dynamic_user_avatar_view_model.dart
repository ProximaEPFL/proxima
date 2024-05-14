import "dart:async";
import "dart:ui";

import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/user/user_data.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/ui/user_avatar_details.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";

/// View model for the dynamic user avatar.
/// This view model is used to fetch the user's display name given its id.
/// If the id is null, the current user's display name is fetched.
class DynamicUserAvatarViewModel extends AutoDisposeFamilyAsyncNotifier<
    UserAvatarDetails, UserIdFirestore?> {
  DynamicUserAvatarViewModel();

  static UserAvatarDetails userDataToDetails(UserData userData) {
    return UserAvatarDetails(
      displayName: userData.displayName,
      backgroundColor: Colors.transparent,
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

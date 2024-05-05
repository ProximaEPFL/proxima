import "dart:async";

import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";

class DynamicUserAvatarViewModel
    extends AutoDisposeFamilyAsyncNotifier<String, UserIdFirestore?> {
  DynamicUserAvatarViewModel();

  @override
  Future<String> build(UserIdFirestore? arg) async {
    final userID = arg;
    final currentUID = ref.watch(uidProvider);
    final userDataBase = ref.watch(userRepositoryProvider);

    if (userID == null) {
      if (currentUID == null) {
        return Future.error("User id was not found.");
      }

      final userData = await userDataBase.getUser(currentUID);

      return userData.data.displayName;
    } else {
      final userData = await userDataBase.getUser(userID);

      return userData.data.displayName;
    }
  }
}

//Flexible provider allowing to retrieve the user's display name given its id.
final userDisplayNameProvider = AsyncNotifierProvider.autoDispose
    .family<DynamicUserAvatarViewModel, String, UserIdFirestore?>(
  () => DynamicUserAvatarViewModel(),
);
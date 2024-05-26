import "dart:async";

import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/services/database/user_repository_service.dart";

/// A view model that provides the number of centauri points of a user
/// given its user id. Allow a null [arg] (user id) to return null, which
/// is useful for loading states.
class UserCentauriPointsViewModel
    extends FamilyAsyncNotifier<int?, UserIdFirestore?> {
  UserCentauriPointsViewModel();

  @override
  Future<int?> build(UserIdFirestore? arg) async {
    final userDataBase = ref.watch(userRepositoryServiceProvider);

    if (arg == null) {
      return null;
    }
    final userID = arg;

    final user = await userDataBase.getUser(userID);
    final userCentauri = user.data.centauriPoints;
    return userCentauri;
  }

  /// Refresh the number of centauri points of the user.
  Future<void> refresh() async {
    state = await AsyncValue.guard(() => build(arg));
  }
}

final userCentauriPointsViewModelProvider = AsyncNotifierProvider.family<
    UserCentauriPointsViewModel, int?, UserIdFirestore?>(
  () => UserCentauriPointsViewModel(),
);

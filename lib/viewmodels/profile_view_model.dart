import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/user_profile_details.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/views/components/async/circular_value.dart";

/// User profile view model
class ProfileViewModel extends AutoDisposeAsyncNotifier<UserProfileDetails> {
  ProfileViewModel();

  @override
  Future<UserProfileDetails> build() async {
    final user = ref.watch(userProvider).valueOrNull;
    final userDataBase = ref.watch(userRepositoryServiceProvider);
    final uid = ref.watch(validUidProvider);

    if (user == null) {
      return Future.error(
        "${CircularValue.debugErrorTag} User must be logged in before displaying the profile page.",
      );
    }

    final userData = await userDataBase.getUser(uid);

    return UserProfileDetails(loginUser: user, firestoreUser: userData);
  }
}

/// Profile view model of the currently logged in user
final profileProvider =
    AutoDisposeAsyncNotifierProvider<ProfileViewModel, UserProfileDetails>(
  () => ProfileViewModel(),
);

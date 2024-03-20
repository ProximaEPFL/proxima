import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/profile_data.dart";
import "package:proxima/viewmodels/login_view_model.dart";

/// User profile view model
class ProfileViewModel extends AsyncNotifier<ProfileData> {
  ProfileViewModel();

  @override
  Future<ProfileData> build() async {
    final user = ref.watch(userProvider).valueOrNull;
    if (user == null) {
      return Future.error(
        "User must be logged in before displaying the home page.",
      );
    }

    return ProfileData(user: user);
  }
}

/// Profile view model of the currently logged in user
final profileProvider = AsyncNotifierProvider<ProfileViewModel, ProfileData>(
  () => ProfileViewModel(),
);

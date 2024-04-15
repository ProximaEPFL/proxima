import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/profile_data.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";

/// User profile view model
class ProfileViewModel extends AsyncNotifier<ProfileData> {
  ProfileViewModel();

  Future<ProfileData> _fetchData() async {
    final user = ref.watch(userProvider).valueOrNull;
    final userDataBase = ref.watch(userRepositoryProvider);
    final uid = ref.watch(uidProvider);

    if (user == null) {
      return Future.error(
        "User must be logged in before displaying the home page.",
      );
    }
    if (uid == null) {
      return Future.error(
        "User id was not found.",
      );
    }
    final userData = await userDataBase.getUser(uid);

    return ProfileData(loginUser: user, firestoreUser: userData);
  }

  @override
  Future<ProfileData> build() async {
    return _fetchData();
  }

  Future<void> addPoints(int points) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final uid = ref.watch(uidProvider);
      final userDataBase = ref.watch(userRepositoryProvider);

      if (uid == null) {
        return Future.error(
          "User id was not found.",
        );
      }
      await userDataBase.addPoints(uid, points);
      return _fetchData();
    });
  }
}

/// Profile view model of the currently logged in user
final profileProvider = AsyncNotifierProvider<ProfileViewModel, ProfileData>(
  () => ProfileViewModel(),
);

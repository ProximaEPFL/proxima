import "package:firebase_auth/firebase_auth.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "package:proxima/models/login_user.dart";
import "package:proxima/models/ui/profile_data.dart";
import "package:proxima/services/implementations/login_service_firebase.dart";
import "package:proxima/services/login_service.dart";

/// Firebase authentication change provider
final userProvider = StreamProvider<LoginUser?>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((user) {
    if (user == null) {
      return null;
    }

    return LoginUser(id: user.uid, email: user.email);
  });
});

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

/// Login Service provider, dependency injection
final loginServiceProvider = Provider<LoginService>((_) {
  return LoginServiceFirebase();
});

/// Profile view model of the currently logged in user
final profileProvider = AsyncNotifierProvider<ProfileViewModel, ProfileData>(
  () => ProfileViewModel(),
);

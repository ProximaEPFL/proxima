import "package:proxima/models/auth/auth_logged_in_user.dart";
import "package:proxima/models/database/user/user_firestore.dart";

// TODO (model team) convert to freezed
// TODO see with UI team what will be displayed for profile
class ProfileData {
  final AuthLoggedInUser loginUser;
  final UserFirestore firestoreUser;

  const ProfileData({
    required this.loginUser,
    required this.firestoreUser,
  });
}

import "package:proxima/models/auth/auth_logged_in_user.dart";
import "package:proxima/models/database/user/user_firestore.dart";

// TODO see with UI team what will be displayed for profile
class UserProfileDetails {
  final AuthLoggedInUser loginUser;
  final UserFirestore firestoreUser;

  const UserProfileDetails({
    required this.loginUser,
    required this.firestoreUser,
  });
}

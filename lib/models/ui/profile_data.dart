import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/login_user.dart";

// TODO (model team) convert to freezed
// TODO see with UI team what will be displayed for profile
class ProfileData {
  final LoginUser loginUser;
  final UserFirestore firestoreUser;

  const ProfileData({
    required this.loginUser,
    required this.firestoreUser,
  });
}

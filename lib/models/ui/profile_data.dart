import "package:proxima/models/login_user.dart";

// TODO (model team) convert to freezed
// TODO see with UI team what will be displayed for profile
class ProfileData {
  final LoginUser user;

  const ProfileData({
    required this.user,
  });
}

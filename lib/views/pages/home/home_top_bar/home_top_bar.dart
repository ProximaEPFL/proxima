import "package:flutter/material.dart";
import "package:proxima/views/components/content/user_avatar/dynamic_user_avatar.dart";
import "package:proxima/views/navigation/routes.dart";

/// This widget is the top bar of the home page
/// It contains the feed sort option and the user profile picture
class HomeTopBar extends StatelessWidget {
  static const homeTopBarKey = Key("homeTopBar");
  static const profilePictureKey = Key("profilePicture");

  final String labelText;

  const HomeTopBar({super.key, required this.labelText});

  @override
  Widget build(BuildContext context) {
    final title = Text(
      labelText,
      style: Theme.of(context).textTheme.headlineMedium,
    );

    final userAvatar = DynamicUserAvatar(
      key: profilePictureKey,
      uid: null,
      radius: 20,
      onTap: () => {
        Navigator.pushNamed(context, Routes.profile.name),
      },
    );

    return Row(
      key: homeTopBarKey,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        title,
        userAvatar,
      ],
    );
  }
}

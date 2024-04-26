import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/utils/ui/user_avatar.dart";
import "package:proxima/views/navigation/routes.dart";

/// This widget is the top bar of the home page
/// It contains the feed sort option and the user profile picture
class AppTopBar extends HookConsumerWidget {
  static const homeTopBarKey = Key("homeTopBar");
  static const profilePictureKey = Key("profilePicture");

  final String labelText;

  const AppTopBar({super.key, required this.labelText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = Text(
      labelText,
      style: Theme.of(context).textTheme.headlineMedium,
    );

    //TODO: add user display name to UserAvatar
    Widget userAvatar = UserAvatar(
      key: profilePictureKey,
      displayName: "Proxima",
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

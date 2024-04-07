import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/navigation/routes.dart";

/// This widget is the top bar of the home page
/// It contains the feed sort option and the user profile picture
class HomeTopBar extends HookConsumerWidget {
  static const homeTopBarKey = Key("homeTopBar");
  static const profilePictureKey = Key("profilePicture");

  static const titleText = "Proxima";

  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = Text(
      titleText,
      style: Theme.of(context).textTheme.headlineMedium,
    );

    Widget userAvatar = CircleAvatar(
      child: Stack(
        children: [
          const Center(child: Text("PR")),
          Material(
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            color: Colors.transparent,
            child: InkWell(
              onTap: () => {
                Navigator.pushNamed(context, Routes.profile.name),
              },
            ),
          ),
        ],
      ),
    );

    return Row(
      key: homeTopBarKey,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        title,
        // Temporary logout button
        userAvatar,
      ],
    );
  }
}

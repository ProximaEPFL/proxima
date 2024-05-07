import "package:flutter/material.dart";

/// A widget that displays the user's avatar.
/// It provides a [onTap] parameter to handle the user's tap,
/// which adds an InkWell response.
/// The [radius] parameter is the radius of the avatar.
class UserAvatar extends StatelessWidget {
  static const initialDisplayNameKey = Key("initialDisplayName");

  const UserAvatar({
    super.key,
    required this.displayName,
    required this.radius,
    this.onTap,
  });

  final String displayName;
  final double radius;
  final VoidCallback? onTap;

  //TODO: Add a parameter to display the user's profile picture.
  //Note that the [backgroundImage] parameter on the [CircleAvatar] widget is
  // working and displays the user's profile picture behind the InkWell response.

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      child: Stack(
        children: [
          Center(
            child: Text(
              key: initialDisplayNameKey,
              // Display the first letter of the [displayName] parameter (user's initial).
              // If the display name is empty, display an empty string (because
              // it causes an error if it is empty).
              displayName.isEmpty ? "" : displayName.substring(0, 1),
            ),
          ),
          Material(
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

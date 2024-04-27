import "package:flutter/material.dart";

/// A widget that displays the user's avatar.
/// It provides a [onTap] parameter to handle the user's tap,
/// which adds an InkWell response.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.displayName,
    this.radius,
    this.onTap,
  });

  final String displayName;
  final double? radius;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      child: Stack(
        children: [
          Center(child: Text(displayName.substring(0, 1))),
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

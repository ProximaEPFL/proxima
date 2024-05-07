import "package:flutter/material.dart";
import "package:proxima/utils/ui/user_avatar.dart";

/// The avatar of the current user on the left of the new comment text field.
class NewCommentUserAvatar extends StatelessWidget {
  static const commentUserAvatarKey = Key("commentUserAvatar");

  const NewCommentUserAvatar({
    super.key,
    required this.currentDisplayName,
  });

  final String currentDisplayName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: UserAvatar(
        key: commentUserAvatarKey,
        displayName: currentDisplayName,
        radius: 22,
      ),
    );
  }
}

import "package:flutter/material.dart";
import "package:proxima/views/components/content/user_avatar/dynamic_user_avatar.dart";

/// The avatar of the current user on the left of the new comment text field.
class NewCommentUserAvatar extends StatelessWidget {
  static const commentUserAvatarKey = Key("commentUserAvatar");

  const NewCommentUserAvatar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(right: 8),
      child: DynamicUserAvatar(
        key: commentUserAvatarKey,
        uid: null,
        radius: 22,
      ),
    );
  }
}

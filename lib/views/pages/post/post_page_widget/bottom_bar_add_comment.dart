import "package:flutter/material.dart";
import "package:proxima/utils/ui/user_avatar/dynamic_user_avatar.dart";

class BottomBarAddComment extends StatelessWidget {
  static const commentUserAvatarKey = Key("commentUserAvatar");
  static const addCommentTextFieldKey = Key("addCommentTextField");
  static const postCommentButtonKey = Key("postCommentButton");

  static const _textFieldHintAddComment = "Add a comment";

  final String currentDisplayName;

  const BottomBarAddComment({
    super.key,
    required this.currentDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      // Align items to the start of the cross axis
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 8),
          child: DynamicUserAvatar(
            key: commentUserAvatarKey,
            uid: null,
            radius: 22,
          ),
        ),
        const Expanded(
          child: TextField(
            key: addCommentTextFieldKey,
            minLines: 1,
            maxLines: 5,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(8),
              border: OutlineInputBorder(),
              hintText: _textFieldHintAddComment,
            ),
          ),
        ),
        Align(
          // Keeps the IconButton centered in the cross axis
          alignment: Alignment.center,
          child: IconButton(
            key: postCommentButtonKey,
            icon: const Icon(Icons.send),
            onPressed: () {
              //TODO: handle add comment
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ),
        ),
      ],
    );
  }
}

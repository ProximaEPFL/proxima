import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/utils/ui/circular_value.dart";
import "package:proxima/utils/ui/user_avatar.dart";
import "package:proxima/viewmodels/comment_view_model.dart";
import "package:proxima/viewmodels/new_comment_view_model.dart";

class BottomBarAddComment extends HookConsumerWidget {
  static const commentUserAvatarKey = Key("commentUserAvatar");
  static const addCommentTextFieldKey = Key("addCommentTextField");
  static const postCommentButtonKey = Key("postCommentButton");

  static const _textFieldHintAddComment = "Add a comment";

  final String currentDisplayName;
  final PostIdFirestore parentPostId;

  const BottomBarAddComment({
    super.key,
    required this.parentPostId,
    required this.currentDisplayName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentController = useTextEditingController();

    final asyncNewCommentState = ref.watch(
      newCommentStateProvider(parentPostId),
    );

    return CircularValue(
      value: asyncNewCommentState,
      builder: (context, newCommentState) {
        // The avatar of the current user on the left
        final userAvatar = Padding(
          padding: const EdgeInsets.only(right: 8),
          child: UserAvatar(
            key: commentUserAvatarKey,
            displayName: currentDisplayName,
            radius: 22,
          ),
        );

        // The field in which the user can write a comment
        final commentTextField = Expanded(
          child: TextField(
            key: addCommentTextFieldKey,
            minLines: 1,
            maxLines: 5,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(8),
              border: const OutlineInputBorder(),
              hintText: _textFieldHintAddComment,
              errorText: newCommentState.contentError,
            ),
            controller: contentController,
          ),
        );

        // The button to post the comment
        final addCommentButton = Align(
          alignment: Alignment.center,
          child: IconButton(
            key: postCommentButtonKey,
            icon: const Icon(Icons.send),
            onPressed: () async {
              final newCommentViewModel = ref.read(
                newCommentStateProvider(parentPostId).notifier,
              );

              final commentPosted = await newCommentViewModel.tryAddComment(
                contentController.text,
              );

              // If the comment was posted, refresh the comment list
              // and reset the new comment view model
              if (commentPosted) {
                await ref
                    .read(commentListProvider(parentPostId).notifier)
                    .refresh();
                await newCommentViewModel.reset();
                contentController.clear();
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
          ),
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            userAvatar,
            commentTextField,
            addCommentButton,
          ],
        );
      },
    );
  }
}

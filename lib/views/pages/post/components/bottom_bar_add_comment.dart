import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/viewmodels/new_comment_view_model.dart";
import "package:proxima/views/components/async/circular_value.dart";
import "package:proxima/views/pages/post/components/new_comment/new_comment_button.dart";
import "package:proxima/views/pages/post/components/new_comment/new_comment_textfield.dart";
import "package:proxima/views/pages/post/components/new_comment/new_comment_user_avatar.dart";

class BottomBarAddComment extends ConsumerWidget {
  final PostIdFirestore parentPostId;

  const BottomBarAddComment({
    super.key,
    required this.parentPostId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newCommentViewModel = ref.read(
      newCommentViewModelProvider(parentPostId).notifier,
    );

    final asyncNewCommentState = ref.watch(
      newCommentViewModelProvider(parentPostId),
    );

    final contentController = newCommentViewModel.contentController;

    return CircularValue(
      value: asyncNewCommentState,
      builder: (context, newCommentState) {
        // The avatar of the current user on the left
        const userAvatar = NewCommentUserAvatar();

        // The field in which the user can write a comment
        final commentTextField = NewCommentTextField(
          commentContentController: contentController,
          newCommentState: newCommentState,
        );

        // The button to post the comment
        final addCommentButton = NewCommentButton(
          commentContentController: contentController,
          parentPostId: parentPostId,
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

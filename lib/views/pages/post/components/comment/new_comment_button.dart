import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/viewmodels/comments_view_model.dart";
import "package:proxima/viewmodels/new_comment_view_model.dart";

/// The button on which the user can click to post a new comment.
class NewCommentButton extends HookConsumerWidget {
  static const postCommentButtonKey = Key("postCommentButton");

  const NewCommentButton({
    super.key,
    required this.commentContentController,
    required this.parentPostId,
  });

  final TextEditingController commentContentController;
  final PostIdFirestore parentPostId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newCommentViewModel = ref.read(
      newCommentViewModelProvider(parentPostId).notifier,
    );

    final commentListViewModel =
        ref.read(commentsViewModelProvider(parentPostId).notifier);

    return Align(
      alignment: Alignment.center,
      child: IconButton(
        key: postCommentButtonKey,
        icon: const Icon(Icons.send),
        onPressed: () async {
          final commentPosted = await newCommentViewModel.tryAddComment(
            commentContentController.text,
          );

          // If the comment was posted, refresh the comment list
          // and reset the new comment view model
          if (commentPosted) {
            await commentListViewModel.refresh();
            await newCommentViewModel.reset();
            commentContentController.clear();
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
      ),
    );
  }
}

import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/user_comments_view_model.dart";
import "package:proxima/views/components/async/circular_value.dart";
import "package:proxima/views/pages/profile/components/info_cards/profile_info_card.dart";
import "package:proxima/views/pages/profile/components/info_cards/profile_info_column.dart";

class ProfileUserComments extends ConsumerWidget {
  static const commentsColumnKey = Key("commentColumn");

  static const noCommentsInfoText = "You don't have any comments yet.";

  const ProfileUserComments({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userComments = ref.watch(userCommentsViewModelProvider);

    return CircularValue(
      value: userComments,
      builder: (context, value) {
        final comments = value
            .map(
              (p) => ProfileInfoCard(
                content: p.description,
                onDelete: () => ref
                    .read(userCommentsViewModelProvider.notifier)
                    .deleteComment(
                        p.userCommentId, p.parentPostId, p.commentId),
              ),
            )
            .toList();

        return ProfileInfoColumn(
          key: commentsColumnKey,
          onRefresh: ref.read(userCommentsViewModelProvider.notifier).refresh,
          itemList: comments,
          emptyInfoText: noCommentsInfoText,
        );
      },
    );
  }
}

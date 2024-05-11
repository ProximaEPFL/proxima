import "package:flutter/widgets.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/user_posts_view_model.dart";
import "package:proxima/views/components/async/circular_value.dart";
import "package:proxima/views/pages/profile/info_cards/profile_info_card.dart";
import "package:proxima/views/pages/profile/info_cards/profile_info_column.dart";

class ProfileUserPosts extends HookConsumerWidget {
  static const postColumnKey = Key("postColumn");

  static const noPostsInfoText = "You don't have any post yet.";

  const ProfileUserPosts({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPosts = ref.watch(userPostsProvider);

    return CircularValue(
      value: userPosts,
      builder: (context, value) {
        final posts = value
            .map(
              (p) => ProfileInfoCard(
                title: p.title,
                content: p.description,
                onDelete: () =>
                    ref.read(userPostsProvider.notifier).deletePost(p.postId),
              ),
            )
            .toList();

        return ProfileInfoColumn(
          key: postColumnKey,
          onRefresh: ref.read(userPostsProvider.notifier).refresh,
          itemList: posts,
          emptyInfoText: noPostsInfoText,
        );
      },
    );
  }
}

import "package:flutter/widgets.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/user_posts_view_model.dart";
import "package:proxima/views/components/async/circular_value.dart";
import "package:proxima/views/helpers/types/result.dart";
import "package:proxima/views/pages/profile/components/info_cards/profile_info_card.dart";
import "package:proxima/views/pages/profile/components/info_cards/profile_info_column.dart";

class ProfileUserPosts extends ConsumerWidget {
  static const postColumnKey = Key("postColumn");

  static const noPostsInfoText = "You don't have any post yet.";

  const ProfileUserPosts({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPosts = ref.watch(userPostsViewModelProvider.future).mapRes();

    return CircularValue(
      future: userPosts,
      builder: (context, value) {
        final posts = value
            .map(
              (p) => ProfileInfoCard(
                title: p.title,
                content: p.description,
                onDelete: () => ref
                    .read(userPostsViewModelProvider.notifier)
                    .deletePost(p.postId),
              ),
            )
            .toList();

        return ProfileInfoColumn(
          key: postColumnKey,
          onRefresh: ref.read(userPostsViewModelProvider.notifier).refresh,
          itemList: posts,
          emptyInfoText: noPostsInfoText,
        );
      },
    );
  }
}

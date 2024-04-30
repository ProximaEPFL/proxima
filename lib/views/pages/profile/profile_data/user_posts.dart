import "package:flutter/widgets.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/utils/ui/circular_value.dart";
import "package:proxima/viewmodels/user_posts_view_model.dart";
import "package:proxima/views/pages/profile/info_cards/profile_info_card.dart";
import "package:proxima/views/pages/profile/info_cards/profile_info_column.dart";

class UserPosts extends HookConsumerWidget {
  static const postColumnKey = Key("postColumn");

  // TODO replace by Shadow
  final BoxShadow? shadow;

  const UserPosts({
    super.key,
    this.shadow,
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
                shadow: shadow,
                onDelete: () async {
                  // TODO handle post deletion
                },
              ),
            )
            .toList();

        return ProfileInfoColumn(
          itemList: posts,
          columnKey: postColumnKey,
        );
      },
    );
  }
}

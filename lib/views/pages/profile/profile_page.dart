import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/utils/ui/circular_value.dart";
import "package:proxima/viewmodels/profile_view_model.dart";
import "package:proxima/views/pages/profile/posts_info/info_card_badge.dart";
import "package:proxima/views/pages/profile/posts_info/info_card_comment.dart";
import "package:proxima/views/pages/profile/posts_info/info_card_post.dart";
import "package:proxima/views/pages/profile/posts_info/info_column.dart";
import "package:proxima/views/pages/profile/posts_info/info_row.dart";
import "package:proxima/views/pages/profile/profile_app_bar.dart";

/// This widget is used to display the profile page
/// It contains the user info, centauri points, badges, posts and comments
class ProfilePage extends HookConsumerWidget {
  static const postTabKey = Key("postTab");
  static const commentTabKey = Key("commentTab");
  static const tabKey = Key("tab");
  static const postColumnKey = Key("postColumn");
  static const commentColumnKey = Key("commentColumn");

  static const _badgesTitle = "Your badges:";
  static const _postsTab = "Posts";
  static const _commentsTab = "Comments";

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUserData = ref.watch(profileProvider);

    final itemListBadge = <Widget>[];
    final itemListPosts = <Widget>[];
    final itemListComments = <Widget>[];

    final shadow = BoxShadow(
      color: Theme.of(context).colorScheme.shadow.withOpacity(0.4),
      offset: const Offset(0, 1),
      blurRadius: 0.1,
      spreadRadius: 0.01,
    );

    // This is a MOCK list of cards
    // TODO replace by viewmodel
    for (var i = 0; i < 10; i++) {
      itemListBadge.add(
        InfoCardBadge(shadow: shadow),
      );

      itemListPosts.add(
        InfoCardPost(
          shadow: shadow,
          title: "Post title",
          description:
              "My super post that talks about something that is super cool and is located in a super spot",
        ),
      );

      itemListComments.add(
        InfoCardComment(
          shadow: shadow,
          comment:
              "Here is a super comment on a super post that talks about something that is super cool and is located in a super spot that is very cosy and nice",
        ),
      );
    }
    final badges = InfoRow(
      title: _badgesTitle,
      itemList: itemListBadge,
    );

    const tabs = TabBar(
      key: tabKey,
      tabs: [
        Tab(text: _postsTab, key: postTabKey),
        Tab(text: _commentsTab, key: commentTabKey),
      ],
    );

    final posts = InfoColumn(
      itemList: itemListPosts,
      colKey: postColumnKey,
    );
    final comments = InfoColumn(
      itemList: itemListComments,
      colKey: commentColumnKey,
    );

    return CircularValue(
      value: asyncUserData,
      builder: (context, value) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: ProfileAppBar(userData: value.firestoreUser.data),
            body: Container(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: Column(
                children: [
                  badges,
                  tabs,
                  Expanded(
                    child: TabBarView(
                      children: [
                        posts,
                        comments,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

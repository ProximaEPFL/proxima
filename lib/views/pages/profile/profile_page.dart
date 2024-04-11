import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/profile_view_model.dart";
import "package:proxima/views/pages/profile/posts_info/info_card_badge.dart";
import "package:proxima/views/pages/profile/posts_info/info_card_comment.dart";
import "package:proxima/views/pages/profile/posts_info/info_card_post.dart";
import "package:proxima/views/pages/profile/posts_info/info_column.dart";
import "package:proxima/views/pages/profile/posts_info/info_row.dart";
import "package:proxima/views/pages/profile/user_info/user_account.dart";

/// This widget is used to display the profile page
/// It contains the user info, centauri points, badges, posts and comments
class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});
  static const postTabKey = Key("postTab");
  static const commentTabKey = Key("commentTab");
  static const tabKey = Key("tab");
  static const postColumnKey = Key("postColumn");
  static const commentColumnKey = Key("commentColumn");

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUserData = ref.watch(profileProvider);

    var itemListBadge = <InfoCardBadge>[];
    var itemListPosts = <InfoCardPost>[];
    var itemListComments = <InfoCardComment>[];

    BoxShadow shadow = BoxShadow(
      color: Theme.of(context).colorScheme.shadow.withOpacity(0.4),
      offset: const Offset(0, 1),
      blurRadius: 0.1,
      spreadRadius: 0.01,
    );

    //this is a MOCK list of cards
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

    return switch (asyncUserData) {
      AsyncData(:final value) => DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: UserAccount(
                userEmail: value.user.email ?? "default@mail.com",
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {},
                ),
              ],
            ),
            body: Container(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: Column(
                children: [
                  InfoRow(
                    itemList: itemListBadge,
                    title: "Your badges:",
                  ),
                  const TabBar(
                    key: tabKey,
                    tabs: [
                      Tab(
                        text: "Posts",
                        key: postTabKey,
                      ),
                      Tab(
                        text: "Comments",
                        key: commentTabKey,
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        InfoColumn(
                          itemList: itemListPosts,
                          colKey: postColumnKey,
                        ),
                        InfoColumn(
                          itemList: itemListComments,
                          colKey: commentColumnKey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      AsyncError(:final error) => Text(
          "Error: $error",
        ),
      _ => const Center(
          child: CircularProgressIndicator(),
        ),
    };
  }
}

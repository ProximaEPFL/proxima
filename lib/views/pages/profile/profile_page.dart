import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/profile_view_model.dart";
import "package:proxima/views/pages/profile/posts_info/info_card.dart";
import "package:proxima/views/pages/profile/posts_info/info_column.dart";
import "package:proxima/views/pages/profile/posts_info/info_row.dart";
import "package:proxima/views/pages/profile/user_info/user_account.dart";

/// This widget is used to display the profile page
/// It contains the user info, centauri points, badges, posts and comments
class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});
  static const postTabKey = Key("post tab");
  static const commentTabKey = Key("comment tab");
  static const tabKey = Key("tab");
  static const postColumnKey = Key("post column");
  static const commentColumnKey = Key("comment column");

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUserData = ref.watch(profileProvider);

    var itemList = <InfoCard>[];

    for (var i = 0; i < 10; i++) {
      itemList.add(
        const InfoCard(),
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
              title: UserAccount(userEmail: value.user.email),
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
                  const SizedBox(height: 8),
                  InfoRow(
                    itemList: itemList,
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
                  const SizedBox(height: 8),
                  Expanded(
                    child: TabBarView(
                      children: [
                        InfoColumn(
                          itemList: itemList,
                          colKey: postColumnKey,
                        ),
                        InfoColumn(
                          itemList: itemList,
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

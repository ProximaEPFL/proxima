import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/profile_view_model.dart";
import "package:proxima/views/components/async/circular_value.dart";
import "package:proxima/views/pages/profile/components/profile_app_bar.dart";
import "package:proxima/views/pages/profile/components/profile_data/profile_user_comments.dart";
import "package:proxima/views/pages/profile/components/profile_data/profile_user_posts.dart";

/// This widget is used to display the profile page
/// It contains the user info, centauri points, badges, user posts and user comments
class ProfilePage extends ConsumerWidget {
  static const postTabKey = Key("postTab");
  static const commentTabKey = Key("commentTab");
  static const tabKey = Key("tab");
  static const commentColumnKey = Key("commentColumn");

  static const _postsTab = "Posts";
  static const _commentsTab = "Comments";

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUserData = ref.watch(profileViewModelProvider);

    const tabsTitle = TabBar(
      key: tabKey,
      tabs: [
        Tab(text: _postsTab, key: postTabKey),
        Tab(text: _commentsTab, key: commentTabKey),
      ],
    );

    const tabsContent = Expanded(
      child: TabBarView(
        children: [
          ProfileUserPosts(),
          ProfileUserComments(),
        ],
      ),
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
              child: const Column(
                children: [
                  tabsTitle,
                  tabsContent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/home_view_model.dart";
import "package:proxima/views/content/feed/post_card/post_card.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/sort_option_widgets/feed_sort_option/feed_sort_option_chips.dart";

/// This widget is the feed of the home page
/// It contains the posts
class HomeFeed extends HookConsumerWidget {
  static const feedSortOptionKey = Key("feedSortOption");
  static const homeFeedKey = Key("homeFeed");
  static const emptyHomeFeedKey = Key("emptyHomeFeed");
  static const newPostButtonTextKey = Key("newPostButtonTextKey");
  const HomeFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postList);

    final emptyHelper = Center(
      key: emptyHomeFeedKey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("No post to display, "),
          InkWell(
            onTap: () => {
              Navigator.pushNamed(context, Routes.newPost.name),
            },
            child: const Text(
              key: newPostButtonTextKey,
              "create one",
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );

    final postsCards = ListView(
      key: homeFeedKey,
      children: posts.map((post) => PostCard(post: post)).toList(),
    );

    return Column(
      children: [
        const FeedSortOptionChips(
          key: feedSortOptionKey,
        ),
        const Divider(),
        Expanded(child: posts.isEmpty ? emptyHelper : postsCards),
      ],
    );
  }
}

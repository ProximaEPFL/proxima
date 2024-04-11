import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/home_view_model.dart";
import "package:proxima/views/home_content/feed/post_card/post_card.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/sort_option_widgets/feed_sort_option/feed_sort_option_chips.dart";

/// This widget is the feed of the home page
/// It contains the posts
class PostFeed extends HookConsumerWidget {
  static const feedSortOptionKey = Key("feedSortOption");
  static const feedKey = Key("feed");
  static const emptyfeedKey = Key("emptyFeed");
  static const newPostButtonTextKey = Key("newPostButtonTextKey");
  const PostFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postList);

    final emptyHelper = Center(
      key: emptyfeedKey,
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
      key: feedKey,
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

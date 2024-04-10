import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/post_overview.dart";
import "package:proxima/utils/ui/circular_value.dart";
import "package:proxima/viewmodels/home_view_model.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/home/posts/post_card/post_card.dart";
import "package:proxima/views/sort_option_widgets/feed_sort_option/feed_sort_option_chips.dart";

/// This widget is the feed of the home page
/// It contains the posts
class HomeFeed extends HookConsumerWidget {
  static const feedSortOptionKey = Key("feedSortOption");
  static const emptyHomeFeedKey = Key("emptyHomeFeed");
  static const refreshButtonKey = Key("refreshButton");
  const HomeFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPosts = ref.watch(postOverviewProvider);

    final newPostButton = InkWell(
      onTap: () {
        Navigator.pushNamed(context, Routes.newPost.name);
      },
      child: const Text(
        "create one!",
        style: TextStyle(color: Colors.blue),
      ),
    );
    final refreshButton = ElevatedButton(
      key: refreshButtonKey,
      onPressed: () async {
        ref.read(postOverviewProvider.notifier).refresh();
      },
      child: const Text("Refresh"),
    );
    final emptyHelper = Center(
      key: emptyHomeFeedKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("No post in this area, "),
              newPostButton,
            ],
          ),
          const SizedBox(height: 10),
          refreshButton,
        ],
      ),
    );

    return Column(
      children: [
        const FeedSortOptionChips(
          key: feedSortOptionKey,
        ),
        const Divider(),
        CircularValue(
          value: asyncPosts,
          builder: (context, posts) {
            final postsList = PostList(
              posts: posts,
              onRefresh: () async {
                return ref.read(postOverviewProvider.notifier).refresh();
              },
            );

            return Expanded(
              child: posts.isEmpty ? emptyHelper : postsList,
            );
          },
        ),
      ],
    );
  }
}

class PostList extends StatelessWidget {
  static const homeFeedKey = Key("homeFeed");

  const PostList({
    super.key,
    required this.posts,
    required this.onRefresh,
  });

  final List<PostOverview> posts;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        key: homeFeedKey,
        children: posts.map((post) => PostCard(post: post)).toList(),
      ),
    );
  }
}

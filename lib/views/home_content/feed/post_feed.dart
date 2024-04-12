import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/post_overview.dart";
import "package:proxima/viewmodels/home_view_model.dart";
import "package:proxima/views/home_content/feed/post_card/post_card.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/sort_option_widgets/feed_sort_option/feed_sort_option_chips.dart";

/// This widget is the feed of the home page
/// It contains the posts
class PostFeed extends HookConsumerWidget {
  static const feedSortOptionKey = Key("feedSortOption");

  static const refreshButtonKey = Key("refreshButton");
  static const feedKey = Key("feed");
  static const emptyfeedKey = Key("emptyFeed");
  static const newPostButtonTextKey = Key("newPostButtonTextKey");
  const PostFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPosts = ref.watch(postOverviewProvider);

    final newPostButton = InkWell(
      onTap: () {
        Navigator.pushNamed(context, Routes.newPost.name);
      },
      child: const Text(
        key: newPostButtonTextKey,
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
      key: emptyfeedKey,
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
        asyncPosts.when(
          data: (posts) {
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
          loading: () {
            return const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          error: (error, _) {
            return Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("An error occurred"),
                    const SizedBox(height: 10),
                    refreshButton,
                  ],
                ),
              ),
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
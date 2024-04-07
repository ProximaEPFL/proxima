import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/post_overview.dart";
import "package:proxima/utils/ui/circular_value.dart";
import "package:proxima/viewmodels/home_view_model.dart";
import "package:proxima/views/pages/home/posts/post_card/post_card.dart";
import "package:proxima/views/sort_option_widgets/feed_sort_option/feed_sort_option_chips.dart";

/// This widget is the feed of the home page
/// It contains the posts
class HomeFeed extends HookConsumerWidget {
  static const feedSortOptionKey = Key("feedSortOption");
  static const emptyHomeFeedKey = Key("emptyHomeFeed");
  const HomeFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPosts = ref.watch(postOverviewProvider);

    final emptyHelper = Center(
      key: emptyHomeFeedKey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("No post to display, "),
          InkWell(
            onTap: () => {
              //TODO: Add navigation to create post page
            },
            child: const Text(
              "create one",
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
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
            return PostList(
              emptyHelper: emptyHelper,
              posts: posts,
              onRefresh: () async {
                return ref.refresh(postOverviewProvider);
              },
            );
          },
        ),
      ],
    );
  }
}

class PostList extends StatelessWidget {
  const PostList({
    super.key,
    required this.emptyHelper,
    required this.posts,
    required this.onRefresh,
  });
  static const homeFeedKey = Key("homeFeed");

  final Center emptyHelper;
  final List<PostOverview> posts;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final postsCards = RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        key: homeFeedKey,
        children: posts.map((post) => PostCard(post: post)).toList(),
      ),
    );

    return Expanded(child: posts.isEmpty ? emptyHelper : postsCards);
  }
}

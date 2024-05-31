import "package:flutter/material.dart";
import "package:proxima/models/ui/post_details.dart";
import "package:proxima/views/helpers/types/future_void_callback.dart";
import "package:proxima/views/pages/home/content/feed/components/post_card.dart";

class PostList extends StatelessWidget {
  static const homeFeedKey = Key("homeFeed");

  const PostList({
    super.key,
    required this.posts,
    required this.onRefresh,
  });

  final List<PostDetails> posts;
  final FutureVoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        key: homeFeedKey,
        children: posts.map((post) => PostCard(postDetails: post)).toList(),
      ),
    );
  }
}

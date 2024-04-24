import "package:flutter/material.dart";
import "package:proxima/models/ui/post_overview.dart";

import "package:proxima/views/home_content/feed/post_card/user_bar_widget.dart";
import "package:proxima/views/home_content/feed/post_card/votes_widget.dart";

class EntirePostWidget extends StatelessWidget {
  static const postTitleKey = Key("postTitle");
  static const postDescriptionKey = Key("postDescription");
  static const postVoteWidgetKey = Key("postVoteWidget");
  static const postUserBarKey = Key("postUserAvatar");

  final PostOverview post;

  const EntirePostWidget({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final postBottomBar = Padding(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            VotesWidget(
              key: postVoteWidgetKey,
              votes: post.voteScore,
            ),
          ],
        ),
      ),
    );

    final postBody = ListTile(
      title: Text(
        key: postTitleKey,
        post.title,
      ),
      subtitle: Text(
        key: postDescriptionKey,
        post.description,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 8),
          child: UserBarWidget(
            key: postUserBarKey,
            posterUsername: post.ownerDisplayName,
          ),
        ),
        postBody,
        postBottomBar,
      ],
    );
  }
}

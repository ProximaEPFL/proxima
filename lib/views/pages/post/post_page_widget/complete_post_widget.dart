import "package:flutter/material.dart";
import "package:proxima/models/ui/post_overview.dart";
import "package:proxima/views/pages/home/content/feed/post_card/post_header_widget.dart";
import "package:proxima/views/pages/home/content/feed/post_card/votes_widget.dart";

class CompletePostWidget extends StatelessWidget {
  static const postTitleKey = Key("postTitle");
  static const postDescriptionKey = Key("postDescription");
  static const postVoteWidgetKey = Key("postVoteWidget");
  static const postUserBarKey = Key("postUserAvatar");

  final PostOverview post;

  const CompletePostWidget({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final postBottomBar = Padding(
      padding: const EdgeInsets.all(8),
      child: VotesWidget(
        key: postVoteWidgetKey,
        postId: post.postId,
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
          child: PostHeaderWidget(
            key: postUserBarKey,
            posterUsername: post.ownerDisplayName,
            publicationDate: post.publicationDate,
          ),
        ),
        postBody,
        postBottomBar,
      ],
    );
  }
}

import "package:flutter/material.dart";
import "package:proxima/models/ui/post_overview.dart";

import "package:proxima/views/home_content/feed/post_card/comment_widget.dart";
import "package:proxima/views/home_content/feed/post_card/user_bar_widget.dart";
import "package:proxima/views/home_content/feed/post_card/votes_widget.dart";

/// This widget is used to display the post card in the home feed.
/// It contains the post title, description, votes, comments
/// and the user (profile picture and username).
class PostCard extends StatelessWidget {
  static const postCardKey = Key("postCard");
  static const postCardTitleKey = Key("postCardTitle");
  static const postCardDescriptionKey = Key("postCardDescription");
  static const postCardVotesKey = Key("postCardVotes");
  static const postCardCommentsKey = Key("postCardComments");
  static const postCardUserKey = Key("postCardUser");

  final PostOverview post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final postBottomBar = Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          VotesWidget(key: postCardVotesKey, votes: post.voteScore),
          InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            //TODO: Implement the logic to navigate to the post
            onTap: () => {},
            child: CommentWidget(
              key: postCardCommentsKey,
              commentNumber: post.commentNumber,
            ),
          ),
        ],
      ),
    );

    final postBody = ListTile(
      title: Text(
        key: postCardTitleKey,
        post.title,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: Text(
        key: postCardDescriptionKey,
        post.description,
        overflow: TextOverflow.ellipsis,
        maxLines: 7,
      ),
    );

    return Card(
      //Note: This card has two onTap actions, one for the card and one for the comment widget.
      key: postCardKey,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        //TODO: Implement the logic to navigate to the post
        onTap: () => {},
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 0.8, top: 8),
              child: UserBarWidget(
                key: postCardUserKey,
                posterUsername: post.ownerDisplayName,
              ),
            ),
            postBody,
            postBottomBar,
          ],
        ),
      ),
    );
  }
}

import "package:flutter/material.dart";
import "package:proxima/models/ui/post_overview.dart";
import "package:proxima/views/home_content/feed/post_card/comment_widget.dart";
import "package:proxima/views/home_content/feed/post_card/post_header_widget.dart";
import "package:proxima/views/home_content/feed/post_card/votes_widget.dart";
import "package:proxima/views/navigation/routes.dart";

/// This widget is used to display the post card in the home feed.
/// It contains the post title, description, votes, comments
/// and the user (profile picture and username).
class PostCard extends StatelessWidget {
  static const postCardKey = Key("postCard");
  static const postCardTitleKey = Key("postCardTitle");
  static const postCardDescriptionKey = Key("postCardDescription");
  static const postCardVotesKey = Key("postCardVotes");
  static const postCardCommentsNumberKey = Key("postCardCommentsNumber");
  static const postCardUserKey = Key("postCardUser");

  final PostOverview postOverview;

  const PostCard({
    super.key,
    required this.postOverview,
  });

  void _onPostSelect(BuildContext context, PostOverview post) {
    Navigator.pushNamed(context, Routes.post.name, arguments: post);
  }

  @override
  Widget build(BuildContext context) {
    final postBody = ListTile(
      title: Text(
        key: postCardTitleKey,
        postOverview.title,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: Text(
        key: postCardDescriptionKey,
        postOverview.description,
        overflow: TextOverflow.ellipsis,
        maxLines: 7,
      ),
    );

    final postBottomBar = Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          VotesWidget(
            key: postCardVotesKey,
            postId: postOverview.postId,
          ),
          InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onTap: () => _onPostSelect(context, postOverview),
            child: CommentWidget(
              key: postCardCommentsNumberKey,
              commentNumber: postOverview.commentNumber,
            ),
          ),
        ],
      ),
    );

    return Card(
      //Note: This card has two onTap actions, one for the card and one for the comment widget.
      key: postCardKey,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => _onPostSelect(context, postOverview),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: PostHeaderWidget(
                key: postCardUserKey,
                posterUsername: postOverview.ownerDisplayName,
                postTimestamp: postOverview.publicationTime,
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

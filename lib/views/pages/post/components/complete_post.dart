import "package:flutter/material.dart";
import "package:proxima/models/ui/post_details.dart";
import "package:proxima/views/components/content/post_votes.dart";
import "package:proxima/views/components/content/publication_header.dart";

class CompletePost extends StatelessWidget {
  static const postTitleKey = Key("postTitle");
  static const postDescriptionKey = Key("postDescription");
  static const postVoteWidgetKey = Key("postVoteWidget");
  static const postUserBarKey = Key("postUserAvatar");

  final PostDetails post;

  const CompletePost({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final postBottomBar = Padding(
      padding: const EdgeInsets.all(8),
      child: PostVotes(
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
          child: PublicationHeader(
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

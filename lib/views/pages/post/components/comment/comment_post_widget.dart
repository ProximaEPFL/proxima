import "package:flutter/material.dart";
import "package:proxima/models/ui/comment_details.dart";
import "package:proxima/views/components/content/publication_header.dart";

class CommentPostWidget extends StatelessWidget {
  static const commentWidgetKey = Key("commentWidget");
  static const commentUserWidgetKey = Key("commentUserWidget");
  static const commentContentKey = Key("commentContent");

  final CommentDetails commentPost;

  const CommentPostWidget({
    super.key,
    required this.commentPost,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: commentWidgetKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PublicationHeader(
          key: commentUserWidgetKey,
          posterUsername: commentPost.ownerDisplayName,
          posterUid: commentPost.ownerUid,
          publicationDate: commentPost.publicationDate,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32, top: 8),
          child: Text(
            key: commentContentKey,
            commentPost.content,
          ),
        ),
      ],
    );
  }
}

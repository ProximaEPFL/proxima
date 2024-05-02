import "package:flutter/material.dart";
import "package:proxima/models/ui/comment_post.dart";
import "package:proxima/views/home_content/feed/post_card/post_header_widget.dart";

class CommentPostWidget extends StatelessWidget {
  static const commentWidgetKey = Key("commentWidget");
  static const commentUserWidgetKey = Key("commentUserWidget");
  static const commentContentKey = Key("commentContent");

  final CommentPost commentPost;

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
        PostHeaderWidget(
          key: commentUserWidgetKey,
          posterUsername: commentPost.ownerDisplayName,
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

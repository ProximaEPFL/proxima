import "package:flutter/material.dart";
import "package:proxima/models/ui/comment_post.dart";

import "package:proxima/views/home_content/feed/post_card/user_bar_widget.dart";

class CommentPostWidget extends StatelessWidget {
  final CommentPost commentPost;

  const CommentPostWidget({
    super.key,
    required this.commentPost,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserBarWidget(
          posterUsername: commentPost.ownerDisplayName,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32, top: 8),
          child: Text(
            commentPost.content,
          ),
        ),
      ],
    );
  }
}

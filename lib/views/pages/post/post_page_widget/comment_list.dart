import "package:flutter/material.dart";
import "package:proxima/models/ui/comment_post.dart";
import "package:proxima/views/pages/post/post_page_widget/comment_post_widget.dart";

class CommentList extends StatelessWidget {
  static const commentWidgetKey = Key("commentWidget");

  const CommentList({
    super.key,
    required this.comments,
  });

  final List<CommentPost> comments;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Wrap(
        runSpacing: 15,
        children: comments
            .map(
              (comment) => CommentPostWidget(
                key: commentWidgetKey,
                commentPost: comment,
              ),
            )
            .toList(),
      ),
    );
  }
}

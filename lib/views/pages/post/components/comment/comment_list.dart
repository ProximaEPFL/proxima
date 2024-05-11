import "package:flutter/material.dart";
import "package:proxima/models/ui/comment_details.dart";
import "package:proxima/views/pages/post/components/comment/comment_post_widget.dart";

class CommentList extends StatelessWidget {
  const CommentList({
    super.key,
    required this.comments,
  });

  final List<CommentDetails> comments;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Wrap(
        runSpacing: 15,
        children: comments
            .map((comment) => CommentPostWidget(commentPost: comment))
            .toList(),
      ),
    );
  }
}

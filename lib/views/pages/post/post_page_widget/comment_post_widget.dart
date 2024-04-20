import "package:flutter/material.dart";

import "package:proxima/views/home_content/feed/post_card/user_bar_widget.dart";

class CommentPostWidget extends StatelessWidget {
  final String comment;
  final String posterUsername;

  const CommentPostWidget({
    super.key,
    required this.comment,
    required this.posterUsername,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserBarWidget(
          posterUsername: posterUsername,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32, top: 8),
          child: Text(
            comment,
          ),
        ),
      ],
    );
  }
}

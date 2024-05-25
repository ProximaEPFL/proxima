import "package:flutter/material.dart";

/// This widget is used to display the comment number in the post card.
/// It contains the comment icon and the number of comments.
class CommentCount extends StatelessWidget {
  final int count;
  final bool setBlue;

  const CommentCount({
    super.key,
    required this.count,
    required this.setBlue,
  });

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      Icons.comment,
      size: 20,
      color: setBlue ? Colors.blue : null,
    );
    final countText = Text(count.toString());

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: icon,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: countText,
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: content,
      ),
    );
  }
}

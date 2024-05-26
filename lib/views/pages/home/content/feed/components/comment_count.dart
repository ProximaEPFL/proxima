import "package:flutter/material.dart";

/// This widget is used to display the comment number in the post card.
/// It contains the comment icon and the number of comments.
class CommentCount extends StatelessWidget {
  final int count;

  const CommentCount({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    const icon = Icon(Icons.comment, size: 20);
    final countText = Text(count.toString());

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Padding(
          padding: EdgeInsets.all(4),
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

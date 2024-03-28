import "package:flutter/material.dart";

/// This widget is used to display the comment number in the post card.
/// It contains the comment icon and the number of comments.
class CommentWidget extends StatelessWidget {
  final int commentNumber;
  const CommentWidget({
    super.key,
    required this.commentNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.comment, size: 20),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Text(commentNumber.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

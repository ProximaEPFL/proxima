import "package:flutter/material.dart";

class BottomBarAddComment extends StatelessWidget {
  final String currentDisplayName;

  const BottomBarAddComment({
    super.key,
    required this.currentDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment
          .start, // Align items to the start of the cross axis
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: CircleAvatar(
            radius: 22,
            child: Text(currentDisplayName.substring(0, 1)),
          ),
        ),
        const Expanded(
          child: TextField(
            minLines: 1,
            maxLines: 5,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(8),
              border: OutlineInputBorder(),
              hintText: "Add a comment",
            ),
          ),
        ),
        Align(
          alignment: Alignment
              .center, // Keeps the IconButton centered in the cross axis
          child: IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

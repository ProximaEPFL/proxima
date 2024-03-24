import "package:flutter/material.dart";

class VotesWidget extends StatelessWidget {
  final int votes;
  const VotesWidget({
    super.key,
    required this.votes,
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
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.expand_less, size: 30),
              style: const ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                print("Clicked on upvote");
              },
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.expand_more, size: 30),
              style: const ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                print("Clicked on downvote");
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text(getVotesString(votes)),
            ),
          ],
        ),
      ),
    );
  }

  String getVotesString(int votes) {
    if (votes >= 0) {
      return "+ $votes";
    } else {
      return "- $votes";
    }
  }
}

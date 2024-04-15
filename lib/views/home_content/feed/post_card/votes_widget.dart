import "package:flutter/material.dart";

/// This widget is used to display the votes of a post.
/// It contains two buttons to upvote and downvote the post and the number of votes.
class VotesWidget extends StatelessWidget {
  final int votes;

  const VotesWidget({
    super.key,
    required this.votes,
  });

  @override
  Widget build(BuildContext context) {
    final upvote = IconButton(
      //Used to reduce the padding and InkWell created by the IconButton widget
      //https://stackoverflow.com/questions/50381157/how-do-i-remove-flutter-iconbutton-big-padding
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: const Icon(Icons.expand_less, size: 30),
      style: const ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () {
        //TODO: Implement the logic to upvote the post
      },
    );

    final downvote = IconButton(
      //Used to reduce the padding and InkWell created by the IconButton widget
      //https://stackoverflow.com/questions/50381157/how-do-i-remove-flutter-iconbutton-big-padding
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: const Icon(Icons.expand_more, size: 30),
      style: const ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () {
        //TODO: Implement the logic to downvote the post
      },
    );

    final voteCount = Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Text(_votesString(votes)),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            upvote,
            downvote,
            voteCount,
          ],
        ),
      ),
    );
  }

  String _votesString(int votes) {
    if (votes >= 0) {
      return "+ $votes";
    } else {
      votes = -votes;

      return "- $votes";
    }
  }
}

import "package:flutter/material.dart";
import "package:proxima/views/home/posts/post_card/comment_widget.dart";
import "package:proxima/views/home/posts/post_card/user_bar_widget.dart";
import "package:proxima/views/home/posts/post_card/votes_widget.dart";

/*
  This widget is used to display the post card in the home feed.
  It contains the post title, description, votes, comments 
  and the user (profile picture and username).
*/
class PostCard extends StatelessWidget {
  final String title;
  final String description;
  final int votes;
  final int commentNumber;
  final String posterUsername;

  const PostCard({
    super.key,
    required this.title,
    required this.description,
    required this.votes,
    required this.commentNumber,
    required this.posterUsername,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        //TODO: Implement the logic to navigate to the post
        onTap: () => {},
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 0.8, top: 8.0),
              child: UserBarWidget(posterUsername: posterUsername),
            ),
            ListTile(
              title: Text(
                title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              subtitle: Text(
                description,
                overflow: TextOverflow.ellipsis,
                maxLines: 7,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  VotesWidget(votes: votes),
                  InkWell(
                    customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    //TODO: Implement the logic to navigate to the post
                    onTap: () => {},
                    child: CommentWidget(
                      commentNumber: commentNumber,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

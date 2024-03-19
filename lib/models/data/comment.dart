import "package:proxima/models/data/user.dart";

final class Comment {
  final String id;
  final String content;
  final User owner;
  final int voteScore;
  final DateTime publicationTime;
  final List<Comment> answers;

  Comment({
    required this.id,
    required this.content,
    required this.owner,
    required this.voteScore,
    required this.publicationTime,
    required this.answers,
  });
}

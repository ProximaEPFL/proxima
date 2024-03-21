import "package:proxima/models/data/user_data.dart";

final class Comment {
  final String id;
  final String content;
  final ForeignUserData owner;
  final int voteScore;
  final DateTime publicationTime;
  final int numberOfDirectAnswers;
  final List<Comment> loadedAnswers;

  Comment({
    required this.id,
    required this.content,
    required this.owner,
    required this.voteScore,
    required this.publicationTime,
    required this.numberOfDirectAnswers,
    required this.loadedAnswers,
  });
}

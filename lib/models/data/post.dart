import "package:proxima/models/data/comment.dart";
import "package:proxima/models/data/location.dart";
import "package:proxima/models/data/user.dart";

final class Post {
  final String id;
  final String title;
  final String description;
  final Location location;
  final DateTime publicationTime;
  final int voteScore;
  final int totalNumberOfComments;
  final List<Comment> loadedComments;
  final User owner;

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.publicationTime,
    required this.voteScore,
    required this.totalNumberOfComments,
    required this.loadedComments,
    required this.owner,
  });
}

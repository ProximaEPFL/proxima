class Post {
  final String title;
  final String description;
  final int votes;
  final int commentNumber;
  final String posterUsername;

  const Post({
    required this.title,
    required this.description,
    required this.votes,
    required this.commentNumber,
    required this.posterUsername,
  });
}

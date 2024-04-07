import "package:flutter/foundation.dart";

@immutable
class PostOverview {
  final String title;
  final String description;
  final int votes;
  final int commentNumber;
  final String posterUsername;

  const PostOverview({
    required this.title,
    required this.description,
    required this.votes,
    required this.commentNumber,
    required this.posterUsername,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostOverview &&
        other.title == title &&
        other.description == description &&
        other.votes == votes &&
        other.commentNumber == commentNumber &&
        other.posterUsername == posterUsername;
  }

  @override
  int get hashCode {
    return Object.hash(
      title,
      description,
      votes,
      commentNumber,
      posterUsername,
    );
  }
}

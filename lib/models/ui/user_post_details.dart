import "package:flutter/foundation.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";

/// A post that belongs to the current logged in user.
/// Used in their profile page.
@immutable
class UserPostDetails {
  final PostIdFirestore postId;
  final String title;
  final String description;
  // TODO add the location to be able to redirect to the map (see #184)

  const UserPostDetails({
    required this.postId,
    required this.title,
    required this.description,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserPostDetails &&
        other.postId == postId &&
        other.title == title &&
        other.description == description;
  }

  @override
  int get hashCode {
    return Object.hash(
      postId,
      title,
      description,
    );
  }
}

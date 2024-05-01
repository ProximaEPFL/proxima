import "package:cloud_firestore/cloud_firestore.dart";
import "package:geolocator/geolocator.dart";
import "package:proxima/models/database/post/post_firestore.dart";

/// This enum is used to describe how to sort posts, notably in the feed.
enum PostSortOption {
  hottest("Hottest", hotScore, false),
  top("Top", voteScore, false),
  latest("Latest", dayScore, false),
  nearest("Nearest", distanceScore, true);

  final String name;
  final double Function(PostFirestore post, GeoPoint position) scoreFunction;
  final bool sortIncreasing;

  /// This constructor creates a new instance of [PostSortOption].
  /// It has a [name] for the ui, a [scoreFunction] to calculate the score of a post
  /// when sorting it and a [sortIncreasing] to know if the sort should be done in
  /// increasing order of score or not.
  /// The exact value of the score does not matter, only their relative values. For
  /// instance, adding 100'000 to all scores would not change anything.
  const PostSortOption(this.name, this.scoreFunction, this.sortIncreasing);
}

// Increases by 1 every upvote, but decreases by 1 every day
double hotScore(PostFirestore post, GeoPoint position) {
  return voteScore(post, position) - dayScore(post, position);
}

// Increase by 1 every upvote
double voteScore(PostFirestore post, GeoPoint position) {
  return post.data.voteScore.toDouble();
}

// Increase by 1 every day
double dayScore(PostFirestore post, GeoPoint position) {
  final timeInMs = post.data.publicationTime.millisecondsSinceEpoch;
  final timeInDays = timeInMs / (1000.0 * 60.0 * 60.0 * 24);
  return timeInDays;
}

// Increases by 1 every meters
double distanceScore(PostFirestore post, GeoPoint position) {
  final postPosition = post.location.geoPoint;
  return Geolocator.distanceBetween(
    position.latitude,
    position.longitude,
    postPosition.latitude,
    postPosition.longitude,
  );
}
import "package:cloud_firestore/cloud_firestore.dart";
import "package:geolocator/geolocator.dart";
import "package:proxima/models/database/post/post_firestore.dart";

typedef PostScoreFunction = double Function(
  PostFirestore post, [
  GeoPoint? position,
]);

/// Increases by 1 every upvote, but decreases by 1 every day
double hotScore(PostFirestore post, [GeoPoint? position]) {
  return voteScore(post) - dayScore(post);
}

/// Increase by 1 every upvote
double voteScore(PostFirestore post, [GeoPoint? position]) {
  return post.data.voteScore.toDouble();
}

/// Increase by 1 every day.
/// The formula should be currentDate - postCreationDate, but we can simplify
/// it to -postDate since the same constant added to all scores (currentDate)
/// does not matter. See [PostSortOption] constructor documentation for more
/// details.
double dayScore(PostFirestore post, [GeoPoint? position]) {
  final timeInMs = post.data.publicationTime.millisecondsSinceEpoch;
  final timeInDays = timeInMs / (1000.0 * 60.0 * 60.0 * 24);

  return -timeInDays;
}

/// Increases by 1 every meters
double distanceScore(PostFirestore post, [GeoPoint? userPosition]) {
  final postPosition = post.location.geoPoint;

  return Geolocator.distanceBetween(
    userPosition!.latitude,
    userPosition.longitude,
    postPosition.latitude,
    postPosition.longitude,
  );
}

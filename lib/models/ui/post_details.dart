import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/foundation.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

@immutable

/// This class contains all the details of a post that are needed to display it in the UI.
class PostDetails {
  final PostIdFirestore postId;
  final String title;
  final String description;
  final int voteScore;
  final int commentNumber;
  final String ownerDisplayName;
  final String ownerUsername;
  final UserIdFirestore ownerUserID;
  final int ownerCentauriPoints;
  final DateTime publicationDate;
  final int distance; // in meters
  final bool isChallenge;
  final GeoPoint location;

  const PostDetails({
    required this.postId,
    required this.title,
    required this.description,
    required this.voteScore,
    required this.commentNumber,
    required this.ownerDisplayName,
    required this.ownerUsername,
    required this.ownerUserID,
    required this.ownerCentauriPoints,
    required this.publicationDate,
    required this.distance,
    required this.location,
    this.isChallenge = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostDetails &&
        other.postId == postId &&
        other.title == title &&
        other.description == description &&
        other.voteScore == voteScore &&
        other.commentNumber == commentNumber &&
        other.ownerDisplayName == ownerDisplayName &&
        other.ownerUsername == ownerUsername &&
        other.ownerUserID == ownerUserID &&
        other.ownerCentauriPoints == ownerCentauriPoints &&
        other.publicationDate == publicationDate &&
        other.distance == distance &&
        other.isChallenge == isChallenge;
  }

  @override
  int get hashCode {
    return Object.hash(
      postId,
      title,
      description,
      voteScore,
      commentNumber,
      ownerDisplayName,
      ownerUsername,
      ownerUserID,
      ownerCentauriPoints,
      publicationDate,
      distance,
      isChallenge,
    );
  }

  /// This method creates a [PostDetails] object from the data of some [postFirestore],
  /// a firestore [userFirestore], its owner, the [geoFirePoint] of the post and a boolean
  /// [isChallenge] that indicates if the post is a challenge.
  factory PostDetails.fromFirestoreData(
    PostFirestore postFirestore,
    UserFirestore userFirestore,
    GeoFirePoint geoFirePoint,
    bool isChallenge,
  ) {
    return PostDetails(
      postId: postFirestore.id,
      title: postFirestore.data.title,
      description: postFirestore.data.description,
      voteScore: postFirestore.data.voteScore,
      commentNumber: postFirestore.data.commentCount,
      ownerDisplayName: userFirestore.data.displayName,
      ownerUsername: userFirestore.data.username,
      ownerUserID: userFirestore.uid,
      ownerCentauriPoints: userFirestore.data.centauriPoints,
      publicationDate: postFirestore.data.publicationTime.toDate(),
      distance: (geoFirePoint.distanceBetweenInKm(
                geopoint: postFirestore.location.geoPoint,
              ) *
              1000)
          .round(),
      location: postFirestore.location.geoPoint,
      isChallenge: isChallenge,
    );
  }
}

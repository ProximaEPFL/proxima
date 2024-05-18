import "package:flutter/foundation.dart";

/// A class that stores data for each ranking UI element.
/// The [userRank] is nullable to allow the current user to not have a rank.
@immutable
class RankingElementDetails {
  const RankingElementDetails({
    required this.userDisplayName,
    required this.centauriPoints,
    required this.userRank,
  });

  /// Display name of the user.
  final String userDisplayName;

  /// Centauri points of the user.
  final int centauriPoints;

  /// Rank of the user.
  final int? userRank;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RankingElementDetails &&
        other.userDisplayName == userDisplayName &&
        other.centauriPoints == centauriPoints &&
        other.userRank == userRank;
  }

  @override
  int get hashCode => Object.hash(
        userDisplayName,
        centauriPoints,
        userRank,
      );
}

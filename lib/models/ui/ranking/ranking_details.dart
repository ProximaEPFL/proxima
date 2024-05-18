import "package:flutter/foundation.dart";
import "package:proxima/models/ui/ranking/ranking_element_details.dart";

/// A class that stores data for the ranking widget.
@immutable
class RankingDetails {
  const RankingDetails({
    required this.userRankElementDetails,
    required this.rankElementDetailsList,
  });

  /// Details of the user's rank.
  final RankingElementDetails userRankElementDetails;

  /// List containing details the ranking elements.
  final List<RankingElementDetails> rankElementDetailsList;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RankingDetails &&
        other.userRankElementDetails == userRankElementDetails &&
        other.rankElementDetailsList == rankElementDetailsList;
  }

  @override
  int get hashCode => Object.hash(
        userRankElementDetails,
        rankElementDetailsList,
      );
}

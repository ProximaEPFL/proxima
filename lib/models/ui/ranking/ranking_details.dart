import "package:flutter/foundation.dart";
import "package:proxima/models/ui/ranking/ranking_element_details.dart";

/// A class that stores data for the ranking widget.
/// Elements in [rankElementDetailsList] should have non-null [userRank].
@immutable
class RankingDetails {
  RankingDetails({
    required this.userRankElementDetails,
    required this.rankElementDetailsList,
  }) : assert(
          rankElementDetailsList.every(
            (elementDetailsList) => elementDetailsList.userRank != null,
          ),
        );

  /// Details of the user's rank.
  /// The [userRank] parameter of [userRankElementDetails] can be null.
  final RankingElementDetails userRankElementDetails;

  /// List containing details the ranking elements.
  /// The [userRank] parameter of every [RankingElementDetails] instances
  /// in [rankElementDetailsList] are non-null.
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

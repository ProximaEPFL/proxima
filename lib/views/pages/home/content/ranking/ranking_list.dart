import "package:flutter/material.dart";
import "package:proxima/models/ui/ranking/ranking_details.dart";
import "package:proxima/views/helpers/types.dart";
import "package:proxima/views/pages/home/content/ranking/ranking_card.dart";

/// A class that displays a list of ranking cards.
class RankingList extends StatelessWidget {
  const RankingList({
    super.key,
    required this.rankingDetails,
    required this.onRefresh,
  });

  final RankingDetails rankingDetails;
  final FutureVoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    // Build the ranking cards
    final rankingCards = rankingDetails.rankElementDetailsList
        .map(
          (rankingElementDetails) => RankingCard(
            rankingElementDetails: rankingElementDetails,
          ),
        )
        .toList();

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(children: rankingCards),
    );
  }
}

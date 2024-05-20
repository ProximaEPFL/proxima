import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/ranking/ranking_details.dart";
import "package:proxima/viewmodels/users_ranking_view_model.dart";
import "package:proxima/views/pages/home/content/ranking/ranking_card.dart";
import "package:proxima/views/pages/home/content/ranking/ranking_list.dart";

/// A widget that displays the ranking widget.
class RankingWidget extends ConsumerWidget {
  static const rankingListKey = Key("rankingList");
  static const userRankingCardKey = Key("userRankingCard");

  final RankingDetails ranking;

  const RankingWidget({
    super.key,
    required this.ranking,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Flexible(
          child: RankingList(
            key: rankingListKey,
            rankingDetails: ranking,
            onRefresh: ref.read(usersRankingViewModelProvider.notifier).refresh,
          ),
        ),
        const Divider(),
        RankingCard(
          key: userRankingCardKey,
          rankingElementDetails: ranking.userRankElementDetails,
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}

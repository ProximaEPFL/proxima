import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/users_ranking_view_model.dart";
import "package:proxima/views/components/async/circular_value.dart";
import "package:proxima/views/helpers/types.dart";
import "package:proxima/views/pages/home/content/ranking/components/ranking_widget.dart";

/// The Ranking page home content that is accessible via the bottom
/// navigation bar on the home screen.
/// It displays a leaderboard of top centauri points users.
class RankingPage extends ConsumerWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ranking = ref.watch(usersRankingViewModelProvider.future).mapRes();

    return CircularValue(
      future: ranking,
      builder: (context, value) => RankingWidget(ranking: value),
    );
  }
}

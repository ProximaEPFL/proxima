import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/users_ranking_view_model.dart";
import "package:proxima/views/components/async/circular_value.dart";
import "package:proxima/views/pages/home/content/ranking/components/ranking_widget.dart";

class RankingPage extends ConsumerWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ranking = ref.read(usersRankingViewModelProvider);

    return CircularValue(
      value: ranking,
      builder: (context, value) => RankingWidget(ranking: value),
    );
  }
}

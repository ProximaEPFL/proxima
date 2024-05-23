import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/challenge_view_model.dart";
import "package:proxima/views/components/async/circular_value.dart";
import "package:proxima/views/components/async/error_refresh_page.dart";
import "package:proxima/views/pages/home/content/challenge/challenge_card.dart";

class ChallengeList extends ConsumerWidget {
  const ChallengeList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncChallenges = ref.watch(challengeViewModelProvider);

    const emptyChallenge = Center(
      child: Text("No challenge available here!"),
    );

    final onRefresh = ref.read(challengeViewModelProvider.notifier).refresh;
    return CircularValue(
      value: asyncChallenges,
      builder: (context, challenges) {
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: challenges.isEmpty
              ? emptyChallenge
              : ListView(
                  children: challenges
                      .map((challenge) => ChallengeCard(challenge))
                      .toList(),
                ),
        );
      },
      fallbackBuilder: (context, error) {
        return ErrorRefreshPage(
          onRefresh: onRefresh,
        );
      },
    );
  }
}

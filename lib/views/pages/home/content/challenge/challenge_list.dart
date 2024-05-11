import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/challenge_view_model.dart";
import "package:proxima/views/components/async/circular_value.dart";
import "package:proxima/views/pages/home/content/challenge/challenge_card.dart";

class ChallengeList extends ConsumerWidget {
  const ChallengeList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncChallenges = ref.watch(challengeViewModelProvider);

    Widget emptyChallenge = const Center(
      child: Text("No challenge available here!"),
    );

    return CircularValue(
      value: asyncChallenges,
      builder: (context, challenges) {
        return RefreshIndicator(
          onRefresh: () => ref.read(challengeViewModelProvider.notifier).refresh(),
          child: challenges.isEmpty
              ? emptyChallenge
              : ListView(
                  children: challenges
                      .map((challenge) => ChallengeCard(challenge))
                      .toList(),
                ),
        );
      },
    );
  }
}

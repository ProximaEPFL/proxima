import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/utils/ui/circular_value.dart";
import "package:proxima/viewmodels/challenge_view_model.dart";
import "package:proxima/views/home_content/challenge/challenge_card.dart";

class ChallengeList extends ConsumerWidget {
  const ChallengeList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncChallenges = ref.watch(challengeProvider);

    return CircularValue(
      value: asyncChallenges,
      builder: (context, challenges) {
        return ListView(
          children:
              challenges.map((challenge) => ChallengeCard(challenge)).toList(),
        );
      },
    );
  }
}
import "package:flutter/material.dart";
import "package:proxima/models/ui/challenge_card_data.dart";
import "package:proxima/utils/ui/key_value_list_generator.dart";

class ChallengeCard extends StatelessWidget {
  static const opacityWhenFinished = 0.3;

  final ChallengeCardData challenge;

  const ChallengeCard(this.challenge, {super.key});

  @override
  Widget build(BuildContext context) {
    KeyValueListGenerator listGenerator = KeyValueListGenerator(
      style: DefaultTextStyle.of(context).style,
    );

    if (!challenge.isFinished) {
      listGenerator.addPair("Distance to post", "${challenge.distance} meters");
    } else {
      listGenerator.addLine("Challenged finished!");
    }
    if (!challenge.isGroupChallenge) {
      listGenerator.addPair("Time left", "${challenge.timeLeft} hours");
    }
    listGenerator.addPair("Reward", "${challenge.reward} Centauri");

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => (),
        child: Opacity(
          opacity: challenge.isFinished ? opacityWhenFinished : 1.0,
          child: ListTile(
            title: Text(
              challenge.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: SizedBox(
              height: 75,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  listGenerator.generate(),
                  const Icon(Icons.star),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

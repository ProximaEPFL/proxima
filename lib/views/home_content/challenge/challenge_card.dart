import "package:flutter/material.dart";
import "package:flutter_svg/svg.dart";
import "package:proxima/models/ui/challenge_card_data.dart";
import "package:proxima/utils/ui/key_value_list_generator.dart";

class ChallengeCard extends StatelessWidget {
  static const challengeGroupIconKey = Key("challenge_group_icon");
  static const challengeSingleIconKey = Key("challenge_single_icon");

  static const _opacityWhenChallengedFinished = 0.3;
  static const _challengeGroupAsset = "assets/icons/challenge_group.svg";
  static const _challengeSingleAsset = "assets/icons/challenge_single.svg";

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

    final icon = Opacity(
      opacity: 0.8, // to make the icon less prominent
      child: SvgPicture.asset(
        challenge.isGroupChallenge
            ? _challengeGroupAsset
            : _challengeSingleAsset,
        height: 50,
        colorFilter: ColorFilter.mode(
          IconTheme.of(context).color!,
          BlendMode.srcIn,
        ),
        key: challenge.isGroupChallenge
            ? challengeGroupIconKey
            : challengeSingleIconKey,
      ),
    );

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => (),
        child: Opacity(
          opacity: challenge.isFinished ? _opacityWhenChallengedFinished : 1.0,
          child: ListTile(
            title: Text(
              challenge.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: SizedBox(
              height: 75,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  listGenerator.generate(),
                  icon,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

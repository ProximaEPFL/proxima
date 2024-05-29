import "package:flutter/material.dart";
import "package:flutter_svg/svg.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/challenge_details.dart";
import "package:proxima/views/components/options/map/map_selection_options.dart";
import "package:proxima/views/helpers/key_value_list_builder.dart";
import "package:proxima/views/navigation/map_action.dart";

class ChallengeCard extends ConsumerWidget {
  static const challengeGroupIconKey = Key("challenge_group_icon");
  static const challengeSingleIconKey = Key("challenge_single_icon");

  static const _opacityWhenChallengedFinished = 0.3;
  static const _challengeGroupAsset = "assets/icons/challenge_group.svg";
  static const _challengeSingleAsset = "assets/icons/challenge_single.svg";

  final ChallengeDetails challenge;

  const ChallengeCard(this.challenge, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listGenerator = KeyValueListBuilder(
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
        onTap: () {
          MapAction.openMap(
            ref,
            context,
            MapSelectionOptions.challenges,
            0,
            challenge.location,
          );
        },
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
                  // This `Expanded` allows text to clip if it is too long.
                  // This never happens on real phones (not even the small phone
                  // emulator), but it does happen for flutter unit tests.
                  Expanded(
                    child: listGenerator.generate(),
                  ),
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

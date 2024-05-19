import "package:flutter/material.dart";
import "package:proxima/models/ui/ranking/ranking_element_details.dart";
import "package:proxima/models/ui/user_avatar_details.dart";
import "package:proxima/views/components/content/publication_header/user_profile_pop_up.dart";
import "package:proxima/views/components/content/user_avatar/user_avatar.dart";

/// A widget that displays a ranking card.
/// The card displays the user's rank, display name, and centauri points.
/// The card is clickable and opens a user profile pop-up.
/// The card's color can be customized.
class RankingCard extends StatelessWidget {
  static const userRankrankTextKey = Key("userRankrankText");
  static const userRankDisplayNameTextKey = Key("userRankDisplayNameText");
  static const userRankCentauriPointsTextKey =
      Key("userRankCentauriPointsText");
  static const userRankAvatarKey = Key("userRankAvatar");

  // Sized box for the rank text to make sure that the text is centered
  // and that surrounding element spacing is consistent.
  // This width is allow to display three digits.
  static const _sizedBoxRankWidth = 50.0;

  static const _rankOneColor = Color.fromARGB(255, 255, 218, 75);
  static const _rankSecondColor = Color.fromARGB(255, 217, 218, 204);
  static const _rankThirdColor = Color.fromARGB(255, 229, 153, 137);

  // This text is used when the parameter [userRank] of the
  // provided [RankingElementDetails] is null.
  static const _nullRankText = "---";

  const RankingCard({
    super.key,
    required this.rankingElementDetails,
  });

  final RankingElementDetails rankingElementDetails;

  @override
  Widget build(BuildContext context) {
    void onTapUserPopUp() {
      showDialog(
        context: context,
        builder: (BuildContext context) => UserProfilePopUp(
          displayName: rankingElementDetails.userDisplayName,
          username: rankingElementDetails.userUserName,
          centauriPoints: rankingElementDetails.centauriPoints,
        ),
      );
    }

    final cardColor = switch (rankingElementDetails.userRank) {
      1 => _rankOneColor,
      2 => _rankSecondColor,
      3 => _rankThirdColor,
      _ => null,
    };

    final userRankText = Padding(
      padding: const EdgeInsets.only(left: 10),
      child: SizedBox(
        width: _sizedBoxRankWidth,
        child: Text(
          key: userRankrankTextKey,
          textAlign: TextAlign.center,
          rankingElementDetails.userRank == null
              ? _nullRankText
              : rankingElementDetails.userRank.toString(),
          style: const TextStyle(
            fontSize: 24,
          ),
        ),
      ),
    );

    final userDisplayNameText = Padding(
      padding: const EdgeInsets.only(left: 12, right: 16),
      child: Text(
        key: userRankDisplayNameTextKey,
        rankingElementDetails.userDisplayName,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 18,
        ),
      ),
    );

    final userDetails = UserAvatarDetails(
      displayName: rankingElementDetails.userDisplayName,
      userCentauriPoints: rankingElementDetails.centauriPoints,
    );
    final userInfo = Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          UserAvatar(
            key: userRankAvatarKey,
            details: userDetails,
            radius: 22,
          ),
          Flexible(child: userDisplayNameText),
        ],
      ),
    );

    final centauriPointsText = Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Text(
        key: userRankCentauriPointsTextKey,
        rankingElementDetails.centauriPoints.toString(),
        style: const TextStyle(
          fontSize: 18,
        ),
      ),
    );

    return Card(
      clipBehavior: Clip.hardEdge,
      color: cardColor,
      child: InkWell(
        onTap: () => onTapUserPopUp(),
        child: Row(
          children: [
            userRankText,
            Expanded(
              child: userInfo,
            ),
            centauriPointsText,
          ],
        ),
      ),
    );
  }
}

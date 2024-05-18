import "package:flutter/material.dart";
import "package:proxima/models/ui/ranking/ranking_element_details.dart";
import "package:proxima/models/ui/user_avatar_details.dart";
import "package:proxima/views/components/content/publication_header/user_profile_pop_up.dart";
import "package:proxima/views/components/content/user_avatar/user_avatar.dart";

/// A class that displays a ranking card.
/// The card displays the user's rank, display name, and centauri points.
/// The card is clickable and opens a user profile pop-up.
/// The card's color can be customized.
class RankingCard extends StatelessWidget {
  const RankingCard({
    super.key,
    required this.rankingElementDetails,
  });

  // Sized box for the rank text to make sure that the text is centered
  // and that surrounding element spacing is consistent.
  // This width is allow to display three digits.
  static const sizedBoxRankWidth = 50.0;

  static const rankOneColor = Color.fromARGB(255, 255, 218, 75);
  static const rankSecondColor = Color.fromARGB(255, 217, 218, 204);
  static const rankThirdColor = Color.fromARGB(255, 229, 153, 137);

  final RankingElementDetails rankingElementDetails;

  void onTapUserPopUp(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => UserProfilePopUp(
        displayName: rankingElementDetails.userDisplayName,
        username: rankingElementDetails.userUserName,
        centauriPoints: rankingElementDetails.centauriPoints,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = switch (rankingElementDetails.userRank) {
      1 => rankOneColor,
      2 => rankSecondColor,
      3 => rankThirdColor,
      _ => null,
    };

    final userRankText = Padding(
      padding: const EdgeInsets.only(left: 10),
      child: SizedBox(
        width: sizedBoxRankWidth,
        child: Text(
          textAlign: TextAlign.center,
          rankingElementDetails.userRank == null
              ? "---"
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
        onTap: () => onTapUserPopUp(context),
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

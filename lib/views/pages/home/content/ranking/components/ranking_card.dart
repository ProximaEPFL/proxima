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
  static const _sizedBoxRankWidth = 35.0;

  // Colors for the ranking card.
  // The colors are different for light and dark mode.
  // The first element of the tuple is the color for light mode,
  // the second element is the color for dark mode.
  //
  // This list is ordered by rank.
  static const _rankingColors = [
    (
      Color.fromARGB(255, 255, 218, 75),
      Color.fromARGB(255, 206, 176, 60)
    ), // Rank 1
    (
      Color.fromARGB(255, 217, 218, 204),
      Color.fromARGB(255, 161, 161, 151)
    ), // Rank 2
    (
      Color.fromARGB(255, 229, 153, 137),
      Color.fromARGB(255, 138, 89, 80)
    ), // Rank 3
  ];

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
    final ThemeData themeData = Theme.of(context);
    final isLightMode = themeData.brightness == Brightness.light;
    final userRank = rankingElementDetails.userRank;

    /// On tap function to open the user profile pop-up.
    onTapUserPopUp() => {
          showDialog(
            context: context,
            builder: (BuildContext context) => UserProfilePopUp(
              displayName: rankingElementDetails.userDisplayName,
              username: rankingElementDetails.userUserName,
              centauriPoints: rankingElementDetails.centauriPoints,
            ),
          ),
        };

    final cardColorTuple =
        userRank != null ? _rankingColors.elementAtOrNull(userRank - 1) : null;
    final cardColor = isLightMode ? cardColorTuple?.$1 : cardColorTuple?.$2;

    final userRankText = Padding(
      padding: const EdgeInsets.only(left: 10),
      child: SizedBox(
        width: _sizedBoxRankWidth,
        child: Text(
          key: userRankrankTextKey,
          textAlign: TextAlign.center,
          userRank?.toString() ?? _nullRankText,
          style: themeData.textTheme.bodyLarge,
        ),
      ),
    );

    final userDisplayNameText = Padding(
      padding: const EdgeInsets.only(left: 12, right: 16),
      child: Text(
        key: userRankDisplayNameTextKey,
        rankingElementDetails.userDisplayName,
        overflow: TextOverflow.ellipsis,
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
      ),
    );

    final content = InkWell(
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
    );

    return Card(
      clipBehavior: Clip.hardEdge,
      color: cardColor,
      child: content,
    );
  }
}

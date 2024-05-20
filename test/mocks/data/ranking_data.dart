import "package:collection/collection.dart";
import "package:proxima/models/ui/ranking/ranking_details.dart";
import "package:proxima/models/ui/ranking/ranking_element_details.dart";

import "firestore_user.dart";

/// Mock user list for the ranking widget.
final List<Map<String, int>> _rankingUserList = [
  {"user123": 9420},
  {"johnDoe": 8370},
  {"janeSmith": 6550},
  {"coolGuy": 5280},
  {"happyGal": 3000},
  {"superman": 2310},
  {"batman": 1530},
  {"wonderWoman": 420},
];

/// Create a list of [RankingElementDetails] from the mock user list.
final List<RankingElementDetails> mockRankingElementDetailsList =
    _rankingUserList
        .mapIndexed(
          (index, user) => RankingElementDetails(
            userDisplayName: user.keys.first,
            userUserName: "u_${user.keys.first}",
            centauriPoints: user.values.first,
            userRank: index + 1,
          ),
        )
        .toList();

/// Create a [RankingDetails] with the mock user list and a non-null current [userRank].
final RankingDetails mockRankingDetailsWithtestUser = RankingDetails(
  rankElementDetailsList: mockRankingElementDetailsList,
  userRankElementDetails: testUserRankingElementDetails,
);

/// Create a [RankingElementDetails] for the testingUser with 0 centauri points.
/// to stay consistent with the user list used to create the mock ranking details.
final RankingElementDetails testUserRankingElementDetails =
    RankingElementDetails(
  userDisplayName: testingUserData.displayName,
  userUserName: testingUserData.username,
  centauriPoints: 0,
  userRank: 9,
);

import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:proxima/models/ui/ranking/ranking_details.dart";
import "package:proxima/models/ui/ranking/ranking_element_details.dart";
import "package:proxima/views/pages/home/content/ranking/ranking_card.dart";
import "package:proxima/views/pages/home/content/ranking/ranking_list.dart";

/// A widget that displays the ranking widget.
class RankingWidget extends StatelessWidget {
  static const rankingListKey = Key("rankingList");
  static const userRankingCardKey = Key("userRankingCard");

  RankingWidget({super.key});

  // Creating mock data for the ranking list
  static const List<Map<String, int>> userList = [
    {"user123": 9420},
    {"johnDoe": 8370},
    {"janeSmith": 6550},
    {"coolGuy": 5280},
    {"happyGal": 3000},
    {"superman": 2310},
    {"batman": 1530},
    {"wonderWoman": 420},
  ];

  final RankingElementDetails userRankElementDetails =
      const RankingElementDetails(
    userDisplayName: "You",
    userUserName: "U_You",
    centauriPoints: 100,
    userRank: null,
  );

  final rankElementDetailsList = userList
      .mapIndexed(
        (index, user) => RankingElementDetails(
          userDisplayName: user.keys.first,
          userUserName: "u_${user.keys.first}",
          centauriPoints: user.values.first,
          userRank: index + 1,
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    //TODO: Replace with view model RankingDetails getter logic
    final rankingDetails = RankingDetails(
      rankElementDetailsList: rankElementDetailsList,
      userRankElementDetails: userRankElementDetails,
    );

    //TODO: Add Circular value waiting on data.
    return Column(
      children: [
        Flexible(
          child: RankingList(
            key: rankingListKey,
            rankingDetails: rankingDetails,
            onRefresh: () async {
              //TODO: Add refresh logic
            },
          ),
        ),
        const Divider(),
        RankingCard(
          key: userRankingCardKey,
          rankingElementDetails: rankingDetails.userRankElementDetails,
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}

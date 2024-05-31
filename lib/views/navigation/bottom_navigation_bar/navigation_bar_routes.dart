import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/home/content/challenge/challenge_list.dart";
import "package:proxima/views/pages/home/content/feed/post_feed.dart";
import "package:proxima/views/pages/home/content/map/map_screen.dart";
import "package:proxima/views/pages/home/content/ranking/ranking_page.dart";

/// This enum is used to create the navigation bar routes.
/// It contains the name and icon of the routes.
enum NavigationBarRoutes {
  feed("Feed", Icon(Icons.home), null),
  challenge("Challenge", Icon(Icons.emoji_events), null),
  addPost(
    "New post",
    CircleAvatar(
      child: Icon(Icons.add),
    ),
    Routes.newPost,
  ),
  ranking("Ranking", Icon(Icons.leaderboard), null),
  map("Map", Icon(Icons.place), null);

  static const defaultLabelText = "Proxima";

  final String name;
  final Widget icon;

  // Non-null if it requires a push
  final Routes? routeDestination;

  const NavigationBarRoutes(
    this.name,
    this.icon,
    this.routeDestination,
  );

  Widget page([Object? args]) {
    if (routeDestination != null) {
      throw Exception("Route must be pushed.");
    }

    switch (this) {
      case feed:
        return const PostFeed();
      case map:
        if (args is LatLng) {
          return MapScreen(initialLocation: args);
        } else if (args == null) {
          return const MapScreen();
        } else {
          throw Exception("LatLng object required");
        }
      case challenge:
        return const ChallengeList();
      case ranking:
        return const RankingPage();
      case _:
        throw Exception("No page for this route.");
    }
  }

  String pageLabel() {
    switch (this) {
      case challenge:
        return "Challenges";
      case map:
        return "Map";
      case ranking:
        return "Ranking";
      case _:
        return defaultLabelText;
    }
  }
}

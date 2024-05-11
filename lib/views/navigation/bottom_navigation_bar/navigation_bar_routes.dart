import "package:flutter/material.dart";
import "package:proxima/views/components/feedback/not_implemented.dart";
import "package:proxima/views/home_content/challenge/challenge_list.dart";
import "package:proxima/views/home_content/feed/post_feed.dart";
import "package:proxima/views/home_content/map/map_screen.dart";
import "package:proxima/views/navigation/routes.dart";

/// This enum is used to create the navigation bar routes.
/// It contains the name and icon of the routes.
enum NavigationbarRoutes {
  feed("Feed", Icon(Icons.home), null),
  challenge("Challenge", Icon(Icons.emoji_events), null),
  addPost(
    "New post",
    CircleAvatar(
      child: Icon(Icons.add),
    ),
    Routes.newPost,
  ),
  group("Group", Icon(Icons.group), null),
  map("Map", Icon(Icons.place), null);

  static const defaultLabelText = "Proxima";

  final String name;
  final Widget icon;

  // Non-null if it requires a push
  final Routes? routeDestination;

  const NavigationbarRoutes(
    this.name,
    this.icon,
    this.routeDestination,
  );

  Widget page() {
    if (routeDestination != null) {
      throw Exception("Route must be pushed.");
    }

    // TODO implement other routes
    switch (this) {
      case feed:
        return const PostFeed();
      case map:
        return const MapScreen();
      case challenge:
        return const ChallengeList();
      case _:
        return const NotImplemented();
    }
  }

  String pageLabel() {
    switch (this) {
      case challenge:
        return "Challenges";
      case map:
        return "Map";
      case _:
        return defaultLabelText;
    }
  }
}

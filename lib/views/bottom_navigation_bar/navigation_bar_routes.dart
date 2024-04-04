import "package:flutter/material.dart";
import "package:proxima/views/navigation/routes.dart";

/// This enum is used to create the navigation bar routes.
/// It contains the name and icon of the routes.
enum NavigationbarRoutes {
  //TODO set the routes for the pages
  feed("Feed", Icon(Icons.home), Routes.home, false),
  challenge("Challenge", Icon(Icons.emoji_events), null, false),
  addPost(
    "New post",
    CircleAvatar(
      child: Icon(Icons.add),
    ),
    Routes.newPost,
    true,
  ),
  group("Group", Icon(Icons.group), null, false),
  map("Map", Icon(Icons.place), null, false);

  final String name;
  final Widget icon;

  //Temporary nullable for missing pages
  final Routes? routesDestination;
  final bool needPushNavigation;

  const NavigationbarRoutes(
    this.name,
    this.icon,
    this.routesDestination,
    this.needPushNavigation,
  );
}

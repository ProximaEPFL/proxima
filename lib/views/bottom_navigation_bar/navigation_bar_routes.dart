import "package:flutter/material.dart";

/// This enum is used to create the navigation bar routes.
/// It contains the name and icon of the routes.
enum NavigationbarRoutes {
  //TODO set the routes for the pages
  feed("Feed", Icon(Icons.home)),
  challenges("Challenges", Icon(Icons.emoji_events)),
  addPost(
    "Add post",
    CircleAvatar(
      child: Icon(Icons.add),
    ),
  ),
  groups("Groups", Icon(Icons.group)),
  map("Map", Icon(Icons.place));

  final String name;
  final Widget icon;

  const NavigationbarRoutes(this.name, this.icon);
}

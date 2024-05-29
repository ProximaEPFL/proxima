import "package:flutter/material.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bar_routes.dart";

class HomePageOptions {
  final NavigationBarRoutes route;
  final Object? args;

  const HomePageOptions({
    required this.route,
    this.args,
  });

  Widget page() {
    return route.page(args);
  }
}

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HomePageOptions &&
        other.route == route &&
        other.args == args;
  }

  @override
  int get hashCode {
    return Object.hash(route, args);
  }
}

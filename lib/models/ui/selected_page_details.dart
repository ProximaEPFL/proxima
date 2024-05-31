import "package:flutter/material.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bar_routes.dart";

/// A class that holds the currently open page in the home screen, with optional
/// arguments.
class SelectedPageDetails {
  final NavigationBarRoutes route;
  final Object? args;

  const SelectedPageDetails({
    required this.route,
    this.args,
  });

  Widget page() {
    return route.page(args);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SelectedPageDetails &&
        other.route == route &&
        other.args == args;
  }

  @override
  int get hashCode {
    return Object.hash(route, args);
  }
}

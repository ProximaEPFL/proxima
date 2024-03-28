import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/bottom_navigation_bar/navigation_bar_routes.dart";

/// This widget is the bottom navigation bar of the home page.
/// It contains the navigation routes to the different pages.
class NavigationBottomBar extends HookConsumerWidget {
  static const navigationBottomBarKey = Key("navigationBottomBar");

  const NavigationBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = NavigationbarRoutes.values.map((destination) {
      return NavigationDestination(
        icon: destination.icon,
        label: destination.name,
      );
    }).toList();

    return NavigationBar(
      key: navigationBottomBarKey,
      height: 90,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      // TODO set the index of the selected page depending on the page
      selectedIndex: 0,
      onDestinationSelected: (int index) {
        //TODO add the navigation to the pages
      },
      destinations: destinations,
    );
  }
}

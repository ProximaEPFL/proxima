import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/bottom_navigation_bar/navigation_bar_routes.dart";

/// This widget is the bottom navigation bar of the home page.
/// It contains the navigation routes to the different pages.
class NavigationBottomBar extends HookConsumerWidget {
  static const navigationBottomBarKey = Key("navigationBottomBar");
  static const selectedIndex = 0;

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
      selectedIndex: selectedIndex,
      onDestinationSelected: (int index) {
        NavigationbarRoutes selectedRoute = NavigationbarRoutes.values[index];
        if (index != selectedIndex && selectedRoute.routesDestination != null) {
          if (selectedRoute.needPushNavigation) {
            Navigator.pushNamed(context, selectedRoute.routesDestination!.name);
          } else {
            Navigator.pushReplacementNamed(context, selectedRoute.name);
          }
        }
      },
      destinations: destinations,
    );
  }
}

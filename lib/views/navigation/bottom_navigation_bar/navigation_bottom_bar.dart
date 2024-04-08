import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bar_routes.dart";

/// This widget is the bottom navigation bar of the home page.
/// It contains the navigation routes to the different pages.
class NavigationBottomBar extends HookConsumerWidget {
  static const navigationBottomBarKey = Key("navigationBottomBar");

  final ValueNotifier selectedIndex;

  const NavigationBottomBar({
    super.key,
    required this.selectedIndex,
  });

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
      selectedIndex: selectedIndex.value,
      onDestinationSelected: (int nextIndex) {
        final selectedRoute = NavigationbarRoutes.values[nextIndex];

        if (nextIndex != selectedIndex.value) {
          if (selectedRoute.routeDestination != null) {
            Navigator.pushNamed(context, selectedRoute.routeDestination!.name);
          } else {
            selectedIndex.value = nextIndex;
          }
        }
      },
      destinations: destinations,
    );
  }
}

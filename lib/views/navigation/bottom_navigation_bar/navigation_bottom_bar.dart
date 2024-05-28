import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/option_selection/selected_page_view_model.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bar_routes.dart";

/// This widget is the bottom navigation bar of the home page.
/// It contains the navigation routes to the different pages.
class NavigationBottomBar extends ConsumerWidget {
  static const navigationBottomBarKey = Key("navigationBottomBar");

  const NavigationBottomBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = NavigationBarRoutes.values.map((destination) {
      return NavigationDestination(
        icon: destination.icon,
        label: destination.name,
      );
    }).toList();

    final selectedRoute = ref.watch(selectedPageViewModelProvider);
    final selectedRouteIndex =
        NavigationBarRoutes.values.indexOf(selectedRoute);

    return NavigationBar(
      key: navigationBottomBarKey,
      height: 90,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      selectedIndex: selectedRouteIndex,
      onDestinationSelected: (int nextIndex) {
        ref
            .watch(selectedPageViewModelProvider.notifier)
            .navigate(NavigationBarRoutes.values[nextIndex], context);
      },
      destinations: destinations,
    );
  }
}

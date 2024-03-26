import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/home/bottom_navigation_bar/navigation_bar_routes.dart";

class NavigationBottomBar extends HookConsumerWidget {
  const NavigationBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NavigationBar(
      height: 90,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      selectedIndex:
          0, // TODO set the index of the selected page depending on the page
      onDestinationSelected: (int index) {
        //TODO add the navigation to the pages
      },
      destinations: createNavigationItems(),
    );
  }
}

import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bar_routes.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bottom_bar.dart";
import "package:proxima/views/pages/home/home_top_bar/home_top_bar.dart";

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    navigateToLoginPageOnLogout(context, ref);

    final currentPageIndex = useState(NavigationBarRoutes.feed.index);

    return Scaffold(
      appBar: AppBar(
        title: HomeTopBar(
          labelText:
              NavigationBarRoutes.values[currentPageIndex.value].pageLabel(),
        ),
      ),
      bottomNavigationBar: NavigationBottomBar(
        selectedIndex: currentPageIndex,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: NavigationBarRoutes.values[currentPageIndex.value].page(),
      ),
    );
  }
}

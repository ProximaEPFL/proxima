import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/viewmodels/option_selection/home_page_options.dart";
import "package:proxima/viewmodels/option_selection/selected_page_view_model.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bottom_bar.dart";
import "package:proxima/views/pages/home/home_top_bar/home_top_bar.dart";

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    navigateToLoginPageOnLogout(context, ref);

    final HomePageOptions currentPage =
        ref.watch(selectedPageViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: HomeTopBar(
          labelText: currentPage.route.pageLabel(),
        ),
      ),
      bottomNavigationBar: const NavigationBottomBar(),
      body: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: currentPage.page(),
      ),
    );
  }
}

import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/views/bottom_navigation_bar/navigation_bottom_bar.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/home/posts/home_feed.dart";
import "package:proxima/views/pages/home/top_bar/home_top_bar.dart";

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(isUserLoggedInProvider, (_, isLoggedIn) {
      if (!isLoggedIn) {
        // Go to login page when the user is logged out
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.login.name,
          (route) => false,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const HomeTopBar(),
      ),
      bottomNavigationBar: const NavigationBottomBar(),
      body: const Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: HomeFeed(),
      ),
    );
  }
}

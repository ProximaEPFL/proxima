import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/home/bottom_navigation_bar/navigation_bottom_bar.dart";
import "package:proxima/views/home/posts/home_feed.dart";
import "package:proxima/views/home/top_bar/home_top_bar.dart";

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const HomeTopBar(),
      ),
      bottomNavigationBar: const NavigationBottomBar(),
      body: const Padding(
        padding: EdgeInsets.only(left: 8.0, right: 8.0),
        child: HomeFeed(),
      ),
    );
  }
}

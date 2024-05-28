import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/option_selection/selected_page_view_model.dart";

import "bottom_navigation_bar/navigation_bar_routes.dart";

class MapAction extends ConsumerWidget {
  final int depth;

  const MapAction({super.key, required this.depth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () {
        for (var i = 0; i < depth; i++) {
          Navigator.pop(context);
        }
        ref.watch(selectedPageViewModelProvider.notifier).navigate(
              NavigationBarRoutes.map,
              context,
            );
      },
      icon: const Icon(Icons.map),
    );
  }
}

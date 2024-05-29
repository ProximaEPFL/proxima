import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/utils/extensions/geopoint_extensions.dart";
import "package:proxima/viewmodels/map/map_view_model.dart";
import "package:proxima/viewmodels/option_selection/map_selection_options_view_model.dart";
import "package:proxima/viewmodels/option_selection/selected_page_view_model.dart";
import "package:proxima/views/components/options/map/map_selection_options.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bar_routes.dart";

class MapAction extends ConsumerWidget {
  final int depth;

  final MapSelectionOptions mapOption;
  final GeoPoint? initialLocation;

  const MapAction({
    super.key,
    required this.depth,
    required this.mapOption,
    this.initialLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () {
        openMap(
          ref,
          context,
          mapOption,
          depth,
          initialLocation: initialLocation,
        );
      },
      icon: const Icon(Icons.map),
    );
  }

  static Future<void> openMap(
    WidgetRef ref,
    BuildContext context,
    MapSelectionOptions mapOption,
    int depth, {
    GeoPoint? initialLocation,
  }) async {
    final mapViewModelNotifier = ref.read(mapViewModelProvider(null).notifier);

    for (var i = 0; i < depth; i++) {
      Navigator.pop(context);
    }
    ref.watch(selectedPageViewModelProvider.notifier).setOption(
          NavigationBarRoutes.map,
        );

    ref.watch(mapSelectionOptionsViewModelProvider.notifier).setOption(
          mapOption,
        );

    if (initialLocation != null) {
      await Future.delayed(const Duration(seconds: 1));
      await mapViewModelNotifier.updateCamera(
        initialLocation.toLatLng(),
        followEvent: false,
      );
    }
  }
}

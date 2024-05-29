import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
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
      onPressed: () async {
        final mapViewModelNotifier = ref.read(mapViewModelProvider.notifier);

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
          mapViewModelNotifier.updateCamera(
            LatLng(initialLocation!.latitude, initialLocation!.longitude),
            followEvent: false,
          );
        }
      },
      icon: const Icon(Icons.map),
    );
  }
}

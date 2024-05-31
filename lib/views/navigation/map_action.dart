import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/option_selection/map_selection_options_view_model.dart";
import "package:proxima/viewmodels/option_selection/selected_page_view_model.dart";
import "package:proxima/views/components/options/map/map_selection_options.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bar_routes.dart";

/// An icon that opens the map with the given [mapOption] and [initialLocation]
/// when pressed. The [depth] is how many pop backs should be made to reach the
/// home page. This is useful when the map action is nested in a popup. Shows
/// the map icon.
class MapAction extends ConsumerWidget {
  static const mapActionKey = Key("MapAction");

  final int depth;

  final MapSelectionOptions mapOption;
  final LatLng initialLocation;

  const MapAction({
    super.key,
    required this.depth,
    required this.mapOption,
    required this.initialLocation,
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
          initialLocation,
        );
      },
      icon: NavigationBarRoutes.map.icon,
      key: mapActionKey,
    );
  }

  /// Open the map with the given [mapOption] and [initialLocation].
  /// The [depth] is used to pop the navigation stack back to the root page.
  static Future<void> openMap(
    WidgetRef ref,
    BuildContext context,
    MapSelectionOptions mapOption,
    int depth,
    LatLng initialLocation,
  ) async {
    for (var i = 0; i < depth; i++) {
      Navigator.pop(context);
    }
    ref.watch(selectedPageViewModelProvider.notifier).selectPage(
          NavigationBarRoutes.map,
          initialLocation,
        );

    ref.watch(mapSelectionOptionsViewModelProvider.notifier).setOption(
          mapOption,
        );
  }
}

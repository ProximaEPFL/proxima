import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/map/map_view_model.dart";
import "package:proxima/views/components/async/circular_value.dart";
import "package:proxima/views/components/async/error_refresh_page.dart";
import "package:proxima/views/components/options/map/map_selection_option_chips.dart";
import "package:proxima/views/helpers/types/result.dart";
import "package:proxima/views/pages/home/content/map/components/post_map.dart";

/// This widget displays a map with chips to select the type of map.
class MapScreen extends ConsumerWidget {
  final LatLng? initialLocation;

  const MapScreen({
    super.key,
    this.initialLocation,
  });

  static const mapScreenKey = Key("mapScreen");
  static const dividerKey = Key("divider");
  static const refreshButtonKey = Key("refreshButton");

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapInfo =
        ref.watch(mapViewModelProvider(initialLocation).future).mapRes();

    return CircularValue(
      future: mapInfo,
      builder: (context, value) {
        return Scaffold(
          key: mapScreenKey,
          body: Column(
            children: [
              MapSelectionOptionChips(mapInfo: value),
              const Divider(key: dividerKey),
              PostMap(mapInfo: value, initialLocation: initialLocation),
            ],
          ),
        );
      },
      fallbackBuilder: (context, error) {
        return ErrorRefreshPage(
          onRefresh:
              ref.read(mapViewModelProvider(initialLocation).notifier).refresh,
        );
      },
    );
  }
}

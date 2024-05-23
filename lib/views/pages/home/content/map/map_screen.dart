import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/map/map_view_model.dart";
import "package:proxima/views/components/async/circular_value.dart";
import "package:proxima/views/components/async/error_refresh_page.dart";
import "package:proxima/views/components/options/map/map_selection_option_chips.dart";
import "package:proxima/views/pages/home/content/map/post_map.dart";

/// This widget displays a map with chips to select the type of map.
class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  static const mapScreenKey = Key("mapScreen");
  static const dividerKey = Key("divider");
  static const refreshButtonKey = Key("refreshButton");

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapInfo = ref.watch(mapViewModelProvider);

    return CircularValue(
      value: mapInfo,
      builder: (context, value) {
        return Scaffold(
          key: mapScreenKey,
          body: Column(
            children: [
              MapSelectionOptionChips(mapInfo: value),
              const Divider(key: dividerKey),
              //TODO: change the map when clicking on a selection option
              PostMap(mapInfo: value),
            ],
          ),
        );
      },
      fallbackBuilder: (context, error) {
        return ErrorRefreshPage(
          onRefresh: ref.read(mapViewModelProvider.notifier).refresh,
        );
      },
    );
  }
}

import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/map_view_model.dart";
import "package:proxima/views/home_content/map/post_map.dart";
import "package:proxima/views/select_option_widgets/map_selection_option_chips.dart";

class MapScreen extends HookConsumerWidget {
  const MapScreen({super.key});

  static const mapScreenKey = Key("map");
  static const dividerKey = Key("Divider");

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapInfo = ref.watch(asyncMapProvider);

    final mapNotifier = ref.watch(asyncMapProvider.notifier);

    return switch (mapInfo) {
      AsyncData(:final value) => Scaffold(
          key: mapScreenKey,
          body: Column(
            children: [
              const MapSelectionOptionChips(),
              const Divider(key: dividerKey),
              //TODO: change the map when clicking on a selection option
              PostMap(
                mapInfo: value,
                onMapCreated: mapNotifier.onMapCreated,
              ),
            ],
          ),
        ),
      AsyncError(:final error) => Scaffold(
          key: mapScreenKey,
          body: Center(
            child: Text("Error: $error"),
          ),
        ),
      _ => const Center(
          child: CircularProgressIndicator(),
        )
    };
  }
}

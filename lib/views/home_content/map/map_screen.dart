import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/utils/ui/circular_value.dart";
import "package:proxima/viewmodels/map_view_model.dart";
import "package:proxima/views/home_content/map/post_map.dart";
import "package:proxima/views/select_option_widgets/map_selection_option_chips.dart";

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  static const mapScreenKey = Key("mapScreen");
  static const dividerKey = Key("divider");
  static const refreshButtonKey = Key("refreshButton");

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapInfo = ref.watch(mapProvider);

    final refreshButton = ElevatedButton(
      key: refreshButtonKey,
      onPressed: () => ref.read(mapProvider.notifier).refresh(),
      child: const Text("Refresh"),
    );

    final fallback = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("An error occurred"),
          const SizedBox(height: 10),
          refreshButton,
        ],
      ),
    );

    return CircularValue(
      value: mapInfo,
      builder: (context, value) {
        return Scaffold(
          key: mapScreenKey,
          body: Column(
            children: [
              const MapSelectionOptionChips(),
              const Divider(key: dividerKey),
              //TODO: change the map when clicking on a selection option
              PostMap(
                mapInfo: value,
              ),
            ],
          ),
        );
      },
      fallbackBuilder: (context, error) {
        return fallback;
      },
    );
  }
}

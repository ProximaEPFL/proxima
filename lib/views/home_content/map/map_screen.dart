import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/map/map_view_model.dart";
import "package:proxima/views/home_content/map/post_map.dart";
import "package:proxima/views/sort_option_widgets/feed_sort_option/map_selection_option_chips.dart";

class MapScreen extends HookConsumerWidget {
  const MapScreen({super.key});

  static const mapScreenKey = Key("map");
  static const dividerKey = Key("Divider");

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapNotifierProvider);
    final mapNotifier = ref.watch(mapNotifierProvider.notifier);

    useEffect(
      () {
        Future.microtask(() async {
          ref.watch(mapNotifierProvider.notifier).getCurrentLocation();
        });
        return;
      },
      const [],
    );

    return
        //display a loading indicator while the map is loading
        mapState.isBusy
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                key: mapScreenKey,
                body: Column(
                  children: [
                    const MapSelectionOptionChips(),
                    const Divider(key: dividerKey),
                    //TODO: change the map when selecting a sort option
                    PostMap(
                      mapState: mapState,
                      onMapCreated: mapNotifier.onMapCreated,
                    ),
                  ],
                ),
              );
  }
}

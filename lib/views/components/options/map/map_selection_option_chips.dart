import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/map_details.dart";
import "package:proxima/viewmodels/option_selection/map_selection_options_view_model.dart";
import "package:proxima/views/components/options/map/map_selection_options.dart";

class MapSelectionOptionChips extends ConsumerWidget {
  static const selectOptionsKey = Key("selectOptions");
  static final optionChipKeys = Map.fromIterables(
    MapSelectionOptions.values,
    MapSelectionOptions.values.map((option) => Key("optionChip${option.name}")),
  );

  const MapSelectionOptionChips({
    required this.mapInfo,
    super.key,
  });

  final MapDetails mapInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentOption = ref.watch(mapSelectionOptionsViewModelProvider);

    final selectOptions = MapSelectionOptions.values.map((selectOption) {
      return ChoiceChip(
        key: optionChipKeys[selectOption],
        selected: selectOption == currentOption,
        label: Text(selectOption.name),
        onSelected: (bool selected) {
          if (!selected) return;
          ref
              .read(mapSelectionOptionsViewModelProvider.notifier)
              .setOption(selectOption);
        },
      );
    }).toList();

    return Wrap(
      key: selectOptionsKey,
      alignment: WrapAlignment.center,
      spacing: 4,
      children: selectOptions,
    );
  }
}

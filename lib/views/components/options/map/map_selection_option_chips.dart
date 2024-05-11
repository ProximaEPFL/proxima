import "package:flutter/material.dart";
import "package:proxima/models/ui/map_details.dart";
import "package:proxima/views/components/options/map/map_selection_option.dart";

class MapSelectionOptionChips extends StatelessWidget {
  static const selectOptionsKey = Key("selectOptions");

  const MapSelectionOptionChips({
    required this.mapInfo,
    super.key,
  });

  final MapDetails mapInfo;

  @override
  Widget build(BuildContext context) {
    final selectOptions = MapSelectionOptions.values.map((selectOption) {
      return ChoiceChip(
        //TODO: Handle the selection of the options
        key: Key(selectOption.name),
        selected: selectOption == mapInfo.selectOption,
        label: Text(selectOption.name),
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

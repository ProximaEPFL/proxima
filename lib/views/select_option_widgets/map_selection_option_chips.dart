import "package:flutter/material.dart";
import "package:proxima/views/select_option_widgets/map_selection_options.dart";

class MapSelectionOptionChips extends StatelessWidget {
  const MapSelectionOptionChips({
    super.key,
  });
  static const selectOptionsKey = Key("Select options");

  @override
  Widget build(BuildContext context) {
    final selectOptions = MapSelectionOptions.values.map((selectOption) {
      return ChoiceChip(
        //TODO: Handle the selection of the options
        key: Key(selectOption.name),
        selected: selectOption == MapSelectionOptions.values[1],
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

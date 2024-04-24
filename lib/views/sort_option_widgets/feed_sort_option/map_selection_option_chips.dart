import "package:flutter/material.dart";
import "package:proxima/views/sort_option_widgets/feed_sort_option/map_selection_options.dart";

class MapSelectionOptionChips extends StatelessWidget {
  const MapSelectionOptionChips({
    super.key,
  });
  static const sortOptionsKey = Key("Sort options");

  @override
  Widget build(BuildContext context) {
    final sortOptions = MapSelectionOptions.values.map((sortOption) {
      return ChoiceChip(
        //TODO: Handle the sort option selection
        key: Key(sortOption.name),
        selected: sortOption == MapSelectionOptions.values[1],
        label: Text(sortOption.name),
      );
    }).toList();

    return Wrap(
      key: sortOptionsKey,
      alignment: WrapAlignment.center,
      spacing: 4,
      children: sortOptions,
    );
  }
}

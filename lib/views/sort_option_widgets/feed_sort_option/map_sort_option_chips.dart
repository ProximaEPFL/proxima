import "package:flutter/material.dart";
import "package:proxima/views/sort_option_widgets/feed_sort_option/map_sort_option.dart";

class MapSortOptionChips extends StatelessWidget {
  const MapSortOptionChips({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sortOptions = MapSortOption.values.map((sortOption) {
      return ChoiceChip(
        //TODO: Handle the sort option selection
        selected: sortOption == MapSortOption.values[1],
        label: Text(sortOption.name),
      );
    }).toList();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      children: sortOptions,
    );
  }
}

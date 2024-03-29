import "package:flutter/material.dart";
import "package:proxima/views/sort_option_widgets/timeline_sort_option/timeline_sort_option.dart";

/// This widget is the list of sort options for the timeline.
class TimeLineSortOptionChips extends StatelessWidget {
  const TimeLineSortOptionChips({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sortOptions = SortOptions.values.map((sortOption) {
      return ChoiceChip(
        //TODO: Handle the sort option selection
        selected: sortOption == SortOptions.values[0],
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

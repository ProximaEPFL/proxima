import "package:flutter/material.dart";
import "package:proxima/views/filter_widgets/timeline_filter/timeline_filters.dart";

/// This widget is the dropdown menu for the timeline filters.
class TimeLineFiltersChips extends StatelessWidget {
  const TimeLineFiltersChips({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final filters = TimeLineFilters.values.map((filter) {
      return ChoiceChip(
        //TODO: Handle the filter selection
        selected: filter.name == "Nearest",
        label: Text(filter.name),
      );
    }).toList();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      children: filters,
    );
  }
}

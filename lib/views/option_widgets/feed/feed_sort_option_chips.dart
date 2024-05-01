import "package:flutter/material.dart";
import "package:proxima/views/option_widgets/feed/feed_sort_option.dart";

/// This widget is the list of sort options for the timeline.
class FeedSortOptionChips extends StatelessWidget {
  const FeedSortOptionChips({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sortOptions = FeedSortOption.values.map((sortOption) {
      return ChoiceChip(
        //TODO: Handle the sort option selection
        selected: sortOption == FeedSortOption.values[0],
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

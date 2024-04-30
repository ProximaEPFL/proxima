import "package:flutter/material.dart";
import "package:proxima/services/sorting/post_sort_option.dart";

/// This widget is the list of sort options for the timeline.
class FeedSortOptionChips extends StatelessWidget {
  const FeedSortOptionChips({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sortOptions = PostSortOption.values.map((sortOption) {
      return ChoiceChip(
        //TODO: Handle the sort option selection
        selected: sortOption == PostSortOption.values[0],
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
